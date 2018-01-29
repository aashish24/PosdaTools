package Posda::BackgroundProcess;

use Modern::Perl;
use Method::Signatures::Simple;


use Posda::DB qw/ Query ResetDBHandles /;
use Posda::DownloadableFile;
use Posda::Inbox;
use Posda::DebugLog;

use File::Temp qw/ tempfile /;
use DateTime;


$| = 1; # Force unbuffered output, when this module is imported

sub new {
  my($class, $invoc_id, $notify) = @_;
  my $this = {
    invoc_id => $invoc_id,
    notify => $notify,
    child_pid => $$,
    command_line => $0,
    script_start_time => time,
    input_line_query => Query("CreateBackgroundInputLine"),
    input_line_no => 0,
    reports => {}
  };
  bless($this, $class);

  # convert $notify to username if it is an email
  if ($notify =~ /@/) {
    my $r = Query('InboxEmailToUsername')->FetchOneHash($notify);
    if (not defined $r) {
      die "Failed to convert email address ($notify) to username!";
    }
    $this->{notify} = $r->{user_name};
  }

  $this->_start_process($invoc_id, $this->{command_line},
                        $this->{child_pid}, $notify);

  return $this;
}

method CreateReport($report_name) {
  if (not defined $report_name) {
    $report_name = 'Default Report';
  }

  if (not defined $self->{reports}->{$report_name}) {
    my ($fh, $filename) = tempfile();
    if (not defined $fh) { die "Failed to open report handle!" }
    $self->{reports}->{$report_name}->{fh} = $fh;
    $self->{reports}->{$report_name}->{filename} = $filename;
  }

  return $self->{reports}->{$report_name}->{fh};
}

method Daemonize() {
  $self->ForkAndExit;
}

method ForkAndExit() {
  ResetDBHandles();
  $self->{input_line_query} = undef;

  # This appears to be the proper way to fork, and release discriptors 
  # so the parent is released but the child still functions
  shutdown STDOUT, 1;
  if(fork){
    close STDIN;
    close STDOUT;
    exit;
  }

  $self->{grandchild_pid} = $$;

  # Setup various queries for later use
  my($add_time_rows_to_bkgrnd, $add_bgrnd_sub_error, $add_comp_to_bgrnd_sub);

  eval {
    $add_bgrnd_sub_error = Query("AddErrorToBackgroundProcess");
  };
  if($@){
    die "############ Subprocess die-ing silently\n" .
        "Can't get query to record error:\n" .
        "\tCreateBackgroundSubprocessError\n" .
        "($@)\n" .
        "#######################################\n";
  }
  eval {
    $add_time_rows_to_bkgrnd = Query(
      "AddBackgroundTimeAndRowsToBackgroundProcess");
    $add_comp_to_bgrnd_sub = Query(
      "AddCompletionTimeToBackgroundProcess");
  };
  if($@){
    print STDERR "#######################################\n";
    print STDERR "Error: $@\n";
    print STDERR "#######################################\n";
    $add_bgrnd_sub_error->RunQuery(sub{},sub{},
      $@, $self->{background_id}
    );
    die "Script errored with update to table ($@)";
  }

  $self->{add_time_rows_query} = $add_time_rows_to_bkgrnd;
  $self->{add_comp_time_query} = $add_comp_to_bgrnd_sub;
  $self->{add_sub_error_query} = $add_bgrnd_sub_error;

  $self->{email_handle} = $self->CreateReport("Email");

  my $start_time = DateTime->from_epoch(epoch => $self->{script_start_time});
  $self->WriteToEmail(
    "Background process $0 begun at $start_time\n");

  $self->_log_input_count($self->{input_line_no});

  return; # only the grandchild returns
}

method WriteToEmail($line) {
  DEBUG "writing to email: $line";
  $self->{email_handle}->print($line);
}

method Finish() {
  DEBUG "called";
  # log completion time
  $self->{add_comp_time_query}->RunQuery(
    sub{}, sub{}, $self->{background_id});

  $self->{script_end_time} = time;
  DEBUG "script_end_time = $self->{script_end_time}";
  my $end_time = DateTime->from_epoch(epoch => $self->{script_end_time});
  $self->WriteToEmail("Background process ended at: $end_time\n");
  $self->WriteToEmail("Total time elapsed: " . 
    ($self->{script_end_time} - $self->{script_start_time}) . "\n");

  for my $h (sort keys %{$self->{reports}}) {
    if ($h ne 'Email') {
      my $rpt = $self->{reports}->{$h};

      # close report file handles (except email)
      close($rpt->{fh});

      # insert all reports (except email) into posda
      $rpt->{closed} = $self->_insert_report_file($rpt->{filename});

      # add download links for those reports to the mail
      $self->WriteToEmail("Report '$h': $rpt->{closed}->{url}\n");
    }
  }

  # close email file handle
  my $email_rpt = $self->{reports}->{Email};
  close($email_rpt->{fh});
  my $email_filename = $email_rpt->{filename};

  # add the email to posda
  $email_rpt->{closed} = $self->_insert_report_file($email_rpt->{filename});
  # add all reports to background_subprocess_report table
  my $add_report_query = Query('CreateBackgroundReport');

  for my $h (keys %{$self->{reports}}) {
    my $rpt = $self->{reports}->{$h};
    my $closed = $rpt->{closed};

    # FetchOneHash because CreateBackgroundReport returns the ID of the 
    # created report
    my $report = $add_report_query->FetchOneHash(
        $self->{background_id}, $closed->{file_id}, $h
    );

    if ($h eq 'Email') {
      # Add mail to user inbox
      my $inbox = Posda::Inbox->new('nobody');
      $inbox->SendMail(
        $self->{notify}, 
        $report->{background_subprocess_report_id},
        'Posda::BackgroundProcess'
      );
      DEBUG "email report's id is: $report->{background_subprocess_report_id}";
    }

    # $add_report_query->RunQuery(
    #     sub{}, sub{},
    #     $self->{background_id}, $closed->{file_id}, $h
    # );

    DEBUG "Unlinking report file: $rpt->{filename}";
    unlink $rpt->{filename};
  }
}

method LogError($error) {
  #TODO: something is wrong with this!
  print STDERR "Logging error: $error\n";
  $self->{add_sub_error_query}->RunQuery(sub{}, sub{},
      $error, $self->{background_id}
    );
}

sub LogInputLine {
  my ($this, $line) = @_;
  $this->{input_line_query}->RunQuery(
    sub{}, sub{}, $this->{background_id}, $this->{input_line_no}, $line);
  $this->{input_line_no} += 1;
}

sub GetBackgroundID{
  my ($this) = @_;
  return $this->{background_id};
}

method PrepareBackgroundReportBasedOnQuery(
  $query,
  $report_name,
  $max_rows
) {
  shift; shift; shift; # Discard first 3 params
  my @params = @_;     # The rest are query arguments

  my @rows;
  my $q = Query($query);
  my $header = $q->{columns};
  my $num_rows = 0;
  # TODO change this to use the simple row return method
  $q->RunQuery(sub {
    my($row) = @_;
    $num_rows += 1;
    my @fields = @$row;
    # move this test outside 
    unless($#fields == $#$header){
      my $num_fields = @fields;
      my $num_header = @$header;
      $self->WriteToEmail(
        "Error in PrepareBackgroundReportBasedOnQuery\n" .
        "Error:      row had $num_fields columns " .
        "vs header ($num_header) columns\n" .
        "Query:      $query\n" .
        "Row number: $num_rows\n");
      return;
    }
    push @rows, \@fields;
  }, sub {}, @params);

  $self->WriteToEmail(
    "Report $report_name has $num_rows generated rows\n");

  my @report_spec;
  if($num_rows > $max_rows){
    my $remaining = $num_rows;
    my $current_row = 1;
    while($remaining > 0){
      my $first_row = $current_row;
      my $last_row;
      if($remaining <= $max_rows){
        $last_row = $first_row + $remaining - 1;
        $remaining = 0;
        $current_row = $last_row + 1;
      } else {
        $last_row = $first_row + $max_rows - 1;
        $remaining = $remaining - $max_rows;
        $current_row = $last_row + 1;
      }
      my $d = {
        first_row => $first_row,
        last_row => $last_row,
        num_rows => $last_row - $first_row + 1,
      };
      push @report_spec, $d;
    }
  } else {
    push(@report_spec, {
      num_rows => $num_rows,
      first_row => 1,
      last_row => $num_rows,
    });
  }
  my $num_reports = @report_spec;
  if($num_reports > 1){
    $self->WriteToEmail("Splitting report $report_name into " .
      "$num_reports parts based on max rows: $max_rows\n");
    my $rept_num = 0;
    for my $i (@report_spec){
      $rept_num += 1;
      my $rept_num_text = sprintf("%03d", $rept_num);
      my $name = "$report_name [$rept_num_text] " .
        "($i->{first_row} -> $i->{last_row})";
      my @rpt_rows;
      for my $i (1 .. $i->{num_rows}){
        my $row = shift @rows;
        push @rpt_rows, $row;
      }
      $self->MakeBackgroundReport($header, \@rpt_rows, $name);
    }
  } else {
    $self->MakeBackgroundReport($header, \@rows, $report_name);
  }
}

method MakeBackgroundReport($header, $rows, $name){
  my $rpt = $self->CreateReport($name);
  for my $i (0 .. $#{$header}){
    my $f = $header->[$i];
    unless($i == 0) { $rpt->print(",") }
    $f =~ s/"/""/g;
    $rpt->print("\"$f\"");
  }
  $rpt->print("\n");
  for my $r (@$rows){
    for my $i (0 .. $#{$r}){
      my $f = $r->[$i];
      unless($i == 0) { $rpt->print(",") }
      $f =~ s/"/""/g;
      $rpt->print("\"$f\"");
    }
    $rpt->print("\n");
  }
}

# Private methods =============================================================

method _insert_report_file($file_path) {
  my $return = {};
  my $result = `ImportSingleFileIntoPosdaAndReturnId.pl "$file_path" "BackgroundProcess Report"`;
  if ($result =~ /File id: (.*)/) {
    my $new_id = $1;
    return {
      file_id => $new_id,
      url => Posda::DownloadableFile::make_csv($new_id)
    };
  } else {
    die "Error inserting file into posda! $result";
  }
}

method _log_input_count($count) {
  $self->{add_time_rows_query}->RunQuery(sub {}, sub{},
    $count, $self->{grandchild_pid}, $self->{background_id}
  );
}

sub _start_process {
  my ($this, $invoc_id, $command_line, $child_pid, $notify) = @_;

  my $bkgrnd_id;
  my $q1 = Query("CreateBackgroundSubprocess");
  $q1->RunQuery(sub{}, sub{}, $invoc_id, $command_line, $child_pid, $notify);


  # TODO: RunQuery currently won't return rows from an insert, even
  # if the query has a 'returning' clause. fix it?
  my $q2 = Query("GetBackgroundSubprocessId");
  $q2->RunQuery(sub{my($row) = @_;  $bkgrnd_id = $row->[0];}, sub{});

  unless(defined $bkgrnd_id){
    my $error = "Error: unable to create row in background_subprocess";
    print "$error\n";
    die $error;
  }

  my $q3 = Query("CreateBackgroundSubprocessParam");
  for my $i (0 .. $#ARGV){
    $q3->RunQuery(sub {}, sub {}, $bkgrnd_id, $i, $ARGV[$i]);
  }

  $this->{background_id} = $bkgrnd_id;
  return $bkgrnd_id;
}

# Deprecated methods ==========================================================

method LogCompletionTime() { # Deprecated
  say STDERR "LogCompletionTime() is deprecated! Use Finish() instead.";
  $self->Finish();
}

method LogInputCount($count) { # Deprecated
  say STDERR "LogInputCount is deprecated; it no longer needs to be called";
  return 1;
}

method GetReportFileID() { # Deprecated
  say STDERR "GetReportFileID() is deprecated, and no longer returns a valid value!";
  return 0;
}

method GetReportDownloadableURL() { # Deprecated
  return "DEPRECATED";
}

# This method is kept only for backwards compatability. It should not
# be used! Instead call CreateReport() to get a file handle for
# a named report and write to it instead.
method WriteToReport($line) {
  say STDERR "Posda::BackgroundProcess->WriteToReport() is deprecated!";

  my $fh = $self->CreateReport('Default Report');
  $fh->print($line);
}

1;
