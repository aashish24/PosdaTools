package DbIf::Application;
#
# A User Admin application
#

use Posda::DB::PosdaFilesQueries;
use Dispatch::BinFragReader;

use Modern::Perl '2010';
use Method::Signatures::Simple;
use Storable;
use File::Basename 'basename';

use Dispatch::LineReaderWriter;

use GenericApp::Application;

use Posda::Passwords;
use Posda::Config ('Config','Database');
use Posda::ConfigRead;
use DBI;

use Posda::DebugLog 'on';
use Data::Dumper;

use HTML::Entities;

use Posda::PopupImageViewer;
use Posda::PopupCompare;

use Debug;
my $dbg = sub {print STDERR @_ };

use vars '@ISA';
@ISA = ("GenericApp::Application");

func titlize($string) {
  join(' ', map {ucfirst} split('_', $string));
}

method SpecificInitialize($session) {

  # my $child_path = $self->child_path("TestPopup");
  # my $child_obj = Posda::PopupWindowTest->new($self->{session}, $child_path);
  # $self->{popup} = $child_obj;


  $self->{QueryFilterDisplay} = 1;
  $self->{AllArgs} = {};
  for my $a (@{PosdaDB::Queries->GetAllArgs()}) {
    $self->{AllArgs}->{$a} = 1;
  }
  ### change this to initialize from config
  my $m_reports = {
    caption => "Reports",
    op => 'SetMode',
    mode => 'Reports',
    sync => 'Update();'
  };
  $self->{MenuByMode} = {
    ListQueries => [
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
      $m_reports,
    ],
    NewQuery => [
      {
        caption => "Cancel",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Save",
        op => 'SetMode',
        mode => 'SaveQuery',
        sync => 'Update();'
      },
    ],
    QuerySuccessful => [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
      $m_reports,
    ],
    Files => [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
      $m_reports,
    ],
    TableSelected => [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
      $m_reports,
    ],
    Default => [
      {
        caption => 'List',
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Upload",
        op => 'SetMode',
        mode => 'Upload',
        sync => 'Update();'
      },
      {
        caption => "Files",
        op => 'SetMode',
        mode => 'Files',
        sync => 'Update();'
      },
      {
        caption => "Tables",
        op => 'SetMode',
        mode => 'Tables',
        sync => 'Update();'
      },
      $m_reports,
    ]
  };

  if ($self->{user_has_permission}('superuser')) {
    $self->{MenuByMode}->{ActiveQuery} = [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
      {
        caption => "Edit",
        op => 'SetMode',
        mode => 'EditQuery',
        sync => 'Update();'
      },
      {
        caption => "Clone",
        op => 'SetMode',
        mode => 'CloneQuery',
        sync => 'Update();'
      },
    ];
  } else {
    $self->{MenuByMode}->{ActiveQuery} = [
      {
        caption => "List",
        op => 'SetMode',
        mode => 'ListQueries',
        sync => 'Update();'
      },
    ];
  }

  $self->{Mode} = "ListQueries";
  $self->{Sequence} = 0;
  my $dbif_dir = "$self->{Environment}->{UserInfoDir}/DbIf";
  unless(-d $dbif_dir){
    unless(mkdir $dbif_dir) {
      die "Can't mkdir $dbif_dir";
    }
  }
  my $user_dir = "$dbif_dir/" . $self->get_user;
  unless(-d $user_dir){
    unless(mkdir $user_dir) {
      die "Can't mkdir $user_dir";
    }
  }
  $self->{SavedQueriesDir} = "$user_dir/SavedQueries";
  unless(-d $self->{SavedQueriesDir}){
    unless(mkdir $self->{SavedQueriesDir}){
      die "Can't mkdir $self->{SavedQueriesDir}";
    }
  }
  $self->{PreparedReportsDir} = "$user_dir/PreparedReports";
  unless(-d $self->{PreparedReportsDir}){
    unless(mkdir $self->{PreparedReportsDir}){
      die "Can't mkdir $self->{PreparedReportsDir}";
    }
  }

  $self->{PreparedReportsCommonDir} = "$dbif_dir/PreparedReports";
  unless(-d $self->{PreparedReportsCommonDir}){
    unless(mkdir $self->{PreparedReportsCommonDir}){
      die "Can't mkdir $self->{PreparedReportsCommonDir}";
    }
  }


  my $temp_dir = "$self->{Environment}->{LoginTemp}/$self->{session}";
  unless(-d $temp_dir) { die "$temp_dir doesn't exist" }
  $self->{TempDir} = $temp_dir;
  $self->{UploadCount} = 0;
  # $self->{DbLookUp} = $self->{Environment}->{DbSpec};

  if (-e "$self->{SavedQueriesDir}/bindingcache.pinfo") {
    $self->{BindingCache} = 
      retrieve("$self->{SavedQueriesDir}/bindingcache.pinfo");
  } else {
    $self->{BindingCache} = {};
  }

  # Build the command list from database
  my $commands = {};
  map {
    my ($name, $cmdline, $type, $input_line, $tags) = @$_;

    $commands->{$name} = { cmdline => $cmdline,
                           parms => [$cmdline =~ /<([^<>]+)>/g] };
    if (defined $input_line) {
      $commands->{$name}->{pipe_parms} = $input_line;
    }

  } sort @{PosdaDB::Queries->GetOperations()};

  $self->{Commands} = $commands;

  $self->ConfigureTagGroups();
}

method ConfigureTagGroups() {
  $self->{HTTP_APP_CONFIG} = $main::HTTP_APP_CONFIG;

  # Load the list of tag groups from the database
  my $db_handle = DBI->connect(Database('posda_queries'));

  my $qh = $db_handle->prepare(qq{
    select *
    from query_tag_filter
  });

  $qh->execute();
  my $rows = $qh->fetchall_arrayref();


  my %ht = map {
    $_->[0] => {map {
      $_ => 1
    } @{$_->[1]}}
  } @$rows;

  # DEBUG Dumper(\%ht);

  my $all_tag_groups = \%ht;

  $db_handle->disconnect();


  $self->{TagGroups} = {};

  for my $tag (keys %ht) {
    if ($self->{user_has_permission}($tag)) {
      $self->{TagGroups}->{$tag} = $ht{$tag};
    }
  }

  # titlize only after we have picked the correct ones
  my $titlized = {};
  for my $tag (keys %{$self->{TagGroups}}) {
    $titlized->{titlize($tag)} = $self->{TagGroups}->{$tag};
  }

  $self->{TagGroups} = $titlized;

  if ($self->{user_has_permission}('superuser')) {
    $self->{TagGroups}->{'.Unlimited'} = 1;
  }
  $self->{TagGroups}->{'.Show No Tags'} = 1;


  # just pick the first one
  $self->{SelectedTagGroup} = [sort keys %{$self->{TagGroups}}]->[0];

}

method MenuResponse($http, $dyn) {
  if(exists $self->{MenuByMode}->{$self->{Mode}}){
    $self->MakeMenu($http, $dyn, $self->{MenuByMode}->{$self->{Mode}});
  } else {
    $self->MakeMenu($http, $dyn, $self->{MenuByMode}->{Default});
 }
}
method SetMode($http, $dyn){
  $self->{Mode} = $dyn->{mode};
}

method ContentResponse($http, $dyn) {
  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{Mode}");
  }
}
my $tag_ops = {
  "Set All Tags" => "SetAllTags",
  "Clear All Tags" => "ClearAllTags",
};
my $tag_mode_list = [
  "Queries With Any Selected Tag Set",
  "Queries With No Tags Set", 
  "All Queries", 
];
my $tag_modes;
for my $i (@$tag_mode_list){
  $tag_modes->{$i} = 1;
}
method SetAllTags($http, $dyn){
  for my $t (keys %{$self->{TagsState}}){
    $self->{TagsState}->{$t} = "true";
  }
}
method ClearAllTags($http, $dyn){
  for my $t (keys %{$self->{TagsState}}){
    $self->{TagsState}->{$t} = "false";
  }
}

method ToggleQueryFilter($http, $dyn) {
  $self->{QueryFilterDisplay} = not $self->{QueryFilterDisplay};
}

method TagGroupSelector($http, $dyn) {
  $self->SelectByValue($http, {
    op => 'SetGroupSelector',
  });

  my $selected;
  for my $tg (sort keys %{$self->{TagGroups}}) {
    if ($self->{SelectedTagGroup} eq $tg) {
      $selected = q{selected="selected"};
    } else {
      $selected = '';
    }
    $http->queue(qq{<option value="$tg" $selected>$tg</option>});
  }

  $http->queue('</select>');
}

method SetGroupSelector($http, $dyn){
  my $value = $dyn->{value};
  $self->{SelectedTagGroup} = $value;

  my $group = $self->{TagGroups}->{$value};
  DEBUG "Selected group: $value";
  # DEBUG Dumper($group);

}

method TagSelection($http, $dyn){
  # (case-insenstivie alpha sort)
  my @tags = sort { "\L$a" cmp "\L$b" } keys %{$self->{TagsState}};

  if ($self->{SelectedTagGroup} eq '.Show No Tags') {
    @tags = ();
  } elsif ($self->{SelectedTagGroup} ne '.Unlimited') {
    @tags = grep { $self->{TagGroups}->{$self->{SelectedTagGroup}}->{$_} } @tags;
  }

  # break the list of tags into groups of 5
  my @chunks;
  push @chunks, [ splice @tags, 0, 5 ] while @tags;

  # $self->NotSoSimpleButton($http, {
  #   caption => "Toggle Tag List",
  #   op => "ToggleQueryFilter",
  #   sync => "Update();",
  #   class => "btn btn-warning"
  # });

  # display the list of selected filters, if requested
  # if (not $self->{QueryFilterDisplay}) {
    # get list of selected tags
    @tags = grep {
      $self->{TagsState}->{$_} eq 'true';
    } keys %{$self->{TagsState}};

    my $taglist = join(', ', @tags);

    $http->queue(qq{
      <p class="alert alert-info">
        Selected tags: <strong>$taglist</strong>
      </p>
    });
    # return;
  # }

  $http->queue(qq{
    <table class="table table-condensed">
  });
  for my $chunk (@chunks) {
    $http->queue(qq{<tr>});
    for my $tag (@$chunk) {
      my $pretty_tag = titlize($tag);

      my $checked = '';
      if ($self->{TagsState}->{$tag} eq 'true') {
        $checked = 'checked';
      }

      my $new_state = $checked eq 'checked'? 'false':'true';
      my $extra_class = $checked eq 'checked'? 'active':''; 

      $http->queue(qq{
        <td>
          <div class="btn-group" data-toggle="buttons">
            <label class="btn btn-default $extra_class"
              onClick="javascript:PosdaGetRemoteMethod('CheckBoxChange', 'value=$tag&checked=$new_state');Update();"
            >
              <input type="checkbox" autocomplete="off" name="$tag" $checked>
              $pretty_tag
            </label>
          </div>
        </td>
      });
    }
    $http->queue(qq{</tr>});
  }
  $http->queue("</table>");
}

method CheckBoxChange($http, $dyn){
  $self->{TagsState}->{$dyn->{value}} = $dyn->{checked};
}

method SetTagsFilter($http, $dyn){
  my $opt = $dyn->{value};
  if(exists $tag_modes->{$opt}){
    $self->{TagsFilterDisplay} = $opt;
  } elsif(exists $tag_ops->{$opt}) {
    print STDERR "Checking if self->can($opt)\n";
    my $op = $tag_ops->{$opt};
    if($self->can($op)){ $self->$op }
    else {
      print STDERR "$self->{path} can't $op\n";
    }
  }
};
method TagTest($query_tags_listref, $all_tags){
  my $query_tags = {};
  for my $qt (@$query_tags_listref) {
    $query_tags->{$qt} = 1;
  }
  my %selected_tags;
  for my $t (keys %$all_tags){
    if($self->{TagsState}->{$t} eq "true"){ $selected_tags{$t} = 1 }
  }
  my $num_selected = keys %selected_tags;
  my $num_tags = keys %$all_tags;
  my $tags_in_query = keys %$query_tags;
  my $FilterSpec = $self->{TagsFilterDisplay};
  if($FilterSpec eq "All Queries"){
    return 1;
  } elsif($FilterSpec eq "Queries With No Tags Set"){
    if($tags_in_query == 0) { return 1 } else { return 0 }
  } elsif ($FilterSpec eq "Queries With Any Selected Tag Set"){
    for my $t (keys %$query_tags){
      if(exists $selected_tags{$t}) { return 1 }
    }
    return 0;
  } elsif ($FilterSpec eq "Queries With All Selected Tags Set"){
    for my $t (keys %selected_tags){
      unless(exists $query_tags->{$t}) { return 0 }
    }
    return 1;
  } elsif ($FilterSpec eq "Queries With Only All Selected Tags Set"){
    for my $t (keys %selected_tags){
      unless(exists $query_tags->{$t}) { return 0 }
    }
    for my $t (keys %$query_tags){
      if(exists $selected_tags{$t}) { return 1 }
    }
    return 0;
  } else { return 1 }
}
method ListQueries($http, $dyn){
  my @q_list;
  # If tags are selected, return only queries with those tags

  if (not defined $self->{TagsState} or ref($self->{TagsState}) ne "HASH"){
    my $tags = PosdaDB::Queries->GetAllTags();
    $self->{TagsState} = {};
    for my $t (@$tags){
      $self->{TagsState}->{$t} = "false";
    }
  }

  # get simple list of selected tags
  my @selected_tags = grep {
    $self->{TagsState}->{$_} eq 'true';
  } keys %{$self->{TagsState}};

  if ($#selected_tags >= 0) {
    @q_list = sort @{PosdaDB::Queries->GetQueriesWithTags(\@selected_tags)};
  } elsif ($self->{SelectedTagGroup} eq '.Unlimited') {
    @q_list = sort @{PosdaDB::Queries->GetList()};
  }

  # Draw the tag list
  $self->RefreshEngine($http, $dyn, qq{
    <p>Queries</p>
    <p>
      <?dyn="TagGroupSelector"?>
      <?dyn="TagSelection"?>
    </p>
    <table class="table table-striped table-condensed">
  });
  for my $i (@q_list){
    # unless($self->TagTest(PosdaDB::Queries->GetTags($i), $tags)){ next }
    $self->RefreshEngine($http, $dyn, qq{
      <tr>
        <td>$i</td>
        <td>
          <?dyn="NotSoSimpleButton" op="SetActiveQuery" caption="Set Active" query_name="$i" sync="Update();"?>
          <?dyn="DrawQueryModificationButtons" query_name="$i"?>
        </td>
      </tr>
    });
  }
  $self->RefreshEngine($http, $dyn, "</table>");
  $self->DrawSpreadsheetOperationList($http, $dyn, \@selected_tags);
}

method OpenViewPopup($http, $dyn) {
  my $child_path = $self->child_path("TestPopup$dyn->{file_id}");
  my $child_obj = Posda::PopupImageViewer->new($self->{session}, 
                                              $child_path, {file_id => $dyn->{file_id}});
  $self->StartJsChildWindow($child_obj);
}
method OpenComparePopup($http, $dyn) {
  my $child_path = $self->child_path("PopupCompare_$dyn->{sop}");
  my $child_obj = Posda::PopupCompare->new($self->{session}, 
                                              $child_path, $dyn->{sop});
  $self->StartJsChildWindow($child_obj);
}

method DrawSpreadsheetOperationList($http, $dyn, $selected_tags) {
  my @q_list = sort @{PosdaDB::Queries->GetOperationsWithTags($selected_tags)};
  $http->queue(qq{
    <div class="panel panel-info">
      <div class="panel-heading">
        Spreadsheet Operations associated with the selected tags
      </div>

        <table class="table">
          <tr>
            <th>Name</th>
            <th>Command Line</th>
            <th>Input Format</th>
          </tr>
  });
  for my $row (@q_list) {
    my ($name, $cmdline, $op_type, $input_fmt, $tags) = @$row;

    # Escape html codes
    $name = encode_entities($name);
    $cmdline = encode_entities($cmdline);
    $op_type = encode_entities($op_type);
    $input_fmt = encode_entities($input_fmt);

    $http->queue(qq{
      <tr>
        <td>$name</td>
        <td>$cmdline</td>
        <td>$input_fmt</td>
      </tr>
    });

  }
  $http->queue(qq{
        </table>
    </div>
  });
}


method DrawQueryModificationButtons($http, $dyn) {
  if ($self->{user_has_permission}('superuser')) {
    $self->NotSoSimpleButton($http, {
      op => 'DeleteQuery',
      caption => 'Delete',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
    $self->NotSoSimpleButton($http, {
      op => 'SetEditQuery',
      caption => 'Edit',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
    $self->NotSoSimpleButton($http, {
      op => 'CloneQuery',
      caption => 'Clone',
      query_name => $dyn->{query_name},
      sync => 'Update();',
      class => 'btn btn-info',
    });
  }
}
method NewQuery($http, $dyn){
  $http->queue("New Queries Mode");
}
method SetEditQuery($http, $dyn){
  $self->{Mode} = "EditQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{LinkedTextField} = $self->{queries};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}

method SaveQuery($http, $dyn) {
  $self->{query}->Save();
  $http->queue(qq{
    <p class="alert alert-info">
      Query saved.
    </p>
  });
  $self->NotSoSimpleButton($http, {
    caption => "Return to query",
    op => "ResetQuery",
    sync => 'Update();'
  });
}

method CloneQuery($http, $dyn) {
  $self->{Mode} = 'RenderCloneQuery';
  $self->{clone_query} = $dyn->{query_name};
}

method RenderCloneQuery($http, $dyn) {
  $http->queue(qq{
    <h3>Clone Query: $self->{clone_query}</h3>
    <div class="col-md-4">
      <p class="alert alert-warning">
        Every query must have a unique name.
      </p>
      <div class="form-group">
        <label>Name for new query:</label>
        <input class="form-control" id="newName" value="$self->{clone_query}">
      </div>
  });
  $self->NotSoSimpleButtonButton($http, {
      caption => 'Cancel',
      op => 'SetMode',
      mode => 'ListQueries'
  });
  $self->SubmitValueButton($http, {
      caption => 'Save',
      element_id => 'newName',
      op => 'SaveCloneQuery',
      class => 'btn btn-primary',
      #extra => $extra
  });

  $http->queue(qq{
    </div>
  });
}

method SaveCloneQuery($http, $dyn) {
  my $new_name = $dyn->{value};
  my $old_name = $self->{clone_query};

  PosdaDB::Queries::Clone($old_name, $new_name);
  $self->{Mode} = 'ListQueries';
}

method SmallInputBoxWithAddButton($http, $dyn) {
  my $id = $dyn->{id};
  my $op = $dyn->{op};
  my $extra = $dyn->{extra};

  $http->queue(qq{
    <form onSubmit="return false;" class="input-group col-md-4">
      <input id="$id" type="input" class="form-control">
      <span class="input-group-btn">
  });
  $self->SubmitValueButton($http, {
      caption => 'Add',
      element_id => $id,
      op => $op,
      extra => $extra
  });
  $http->queue(qq{
      </span>
    </form>
  });
}

### 
# Delegated methods
###

method DeleteHashKeyList($http, $dyn) {
  DEBUG Dumper($dyn);
  my $type = $dyn->{type};
  my $index = $dyn->{index};

  splice @{$self->{query}->{$type}}, $index, 1;
}
method AddToHashKeyList($http, $dyn) {
  push @{$self->{query}->{tags}}, $dyn->{value};
}

method AddToEditList($http, $dyn) {
  my $source = $dyn->{extra};
  my $value = $dyn->{value};

  DEBUG "Adding '$value' to $source";

  push @{$self->{query}->{$source}}, $value;
}

method DeleteFromEditList($http, $dyn) {
  my $source = $dyn->{name};
  my $value = $dyn->{value};

  DEBUG "Deleting '$value' from $source";

  my @idx = grep {
    $self->{query}->{$source}->[$_] eq $value
  } 0..$#{$self->{query}->{$source}};

  splice @{$self->{query}->{$source}}, $idx[0], 1;

}

method MoveEditListElementUp($http, $dyn) {
  my $source = $dyn->{name};
  my $value = $dyn->{value};

  # find the index of the element to move
  my @idx = grep {
    $self->{query}->{$source}->[$_] eq $value
  } 0..$#{$self->{query}->{$source}};

  my $index = $idx[0];

  if ($index < 1) {
    # can't help you!
    return;
  }

  my $new_index = $index - 1;
  my $temp_val = $self->{query}->{$source}->[$new_index];
  $self->{query}->{$source}->[$new_index] = $self->{query}->{$source}->[$index];
  $self->{query}->{$source}->[$index] = $temp_val;

}

method AddTextField($http, $dyn) {
  $self->{query}->{$dyn->{index}} = $dyn->{value};
}

### End Delegated Methods

method EditQuery($http, $dyn){
  my $descrip = {
    args => {
      caption => "Arguments",
      struct => "array",
    },
    columns =>{
      caption => "Columns Returned",
      struct => "array",
    },
    description => {
      caption=> "Description",
      struct => "textarea",
      rows => 5,
      cols => 100,
    },
    query => {
      caption=> "Query Text",
      struct => "textarea",
      rows => 30,
      cols => 100,
    },
    schema => {
      caption=> "Schema",
      struct => "text",
    },
    name => {
      caption=> "Query Name",
      struct => "text",
    },
    tags => {
      caption => "Tags",
      # struct => "hash key list",
      struct => "array",
    },
  };
  $self->RefreshEngine($http, $dyn,
    'Editing Query: ' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Save" ' .
    'op="SetMode" ' .
    'mode="SaveQuery" ' .
    'sync="Update();" ' .
    'class="btn btn-primary"?>&nbsp;' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Cancel" ' .
    'op="SetMode" ' .
    'mode="ListQueries" ' .
    'sync="Update();" ' .
    'class="btn btn-info"?>&nbsp;' .
    '<?dyn="NotSoSimpleButton" ' .
    'caption="Refresh" ' .
    'op="NoOp" ' .
    'sync="Update();" ' .
    'class="btn btn-info"?>'
  );
  $http->queue(q{<table class="table">});
  for my $i (
    "name", "schema", "description", "tags", "columns", "args", "query"
  ){
    my $d = $descrip->{$i};
    $http->queue(qq{
      <tr>
        <td align="right" valign="top">
          <strong>$d->{caption}</strong>
        </td>
        <td align="left" valign = "top">
    });

    if($d->{struct} eq "text"){
      unless(exists $self->{LinkedTextField}->{$i}){
        $self->{LinkedTextField}->{$i} = $self->{query}->{$i};
      }
      $self->DelegateEntryBox($http, {
          op => 'AddTextField',
          value => $self->{query}->{$i},
          index => $i,
      });
    }

    if($d->{struct} eq "array"){
      $http->queue(qq{
        <table class="table table-condensed">
      });
      for my $j (@{$self->{query}->{$i}}){
        $http->queue(qq{ <tr><td>$j</td><td> });
        $self->NotSoSimpleButton($http, {
            op => 'DeleteFromEditList',
            caption => 'del',
            name => $i,
            value => $j,
            sync => 'Update();'
        });
        $http->queue(qq{ </td><td> });
        $self->NotSoSimpleButton($http, {
            op => 'MoveEditListElementUp',
            caption => 'up',
            name => $i,
            value => $j,
            sync => 'Update();'
        });
        $http->queue(qq{ </td><td> </tr> });
      }
      $http->queue("<tr><td>");
      $http->queue("</table>");
      $self->SmallInputBoxWithAddButton($http, {
        id => "new$i",
        op => 'AddToEditList',
        extra => $i
      });
    } elsif($d->{struct} eq "hash key list"){
      # TODO: This really only works for tags, not for generic 'hash key list'!
      my @keys = sort @{$self->{query}->{tags}};
      $self->{query}->{tags} = \@keys; # Save it back so indexes make sense!

      $http->queue(qq{
        <table class="table table-condensed">
      });
      for my $k (0 .. $#keys){
        $http->queue(qq{
          <tr>
            <td>$keys[$k]</td>
            <td>
        });
        $self->NotSoSimpleButton($http, {
          caption => "del",
          class => "btn btn-danger",
          op => "DeleteHashKeyList",
          type => $i,
          index => $k,
          value => $keys[$k],
          sync => "Update();"
        });
        $http->queue(qq{
            </td>
          </tr>
        });
      }
      $http->queue(qq{
        </table>
      });
      $self->SmallInputBoxWithAddButton($http, {
        id => 'newTag',
        op => 'AddToHashKeyList',
        extra => $i
      });
    } elsif($d->{struct} eq "textarea"){
        $self->DelegateTextArea($http, {
          id => "$i",
          op => "TextAreaChanged",
          value => $self->{query}->{$i},
          rows => $d->{rows},
          cols => $d->{cols}
      });
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}

# do we really need to handle this with a post?
method TextAreaChanged($http, $dyn){
  DEBUG Dumper($dyn);
  # Read the POST data (this method needs to be POSTed to!)
  my $buff;
  my $c = read $http->{socket}, $buff, $http->{header}->{content_length};

  $self->{query}->{$dyn->{id}} = $buff;
  DEBUG $buff;
}

method SetActiveQuery($http, $dyn){
  $self->{Mode} = "ActiveQuery";
  $self->{Query} = $dyn->{query_name};
  delete $self->{QueryResults};
  delete $self->{Input};
  $self->{query} = PosdaDB::Queries->GetQueryInstance($dyn->{query_name});
}
method ActiveQuery($http, $dyn){
  DEBUG @_;
  my $descrip = {
    args => {
      caption => "Arguments",
      struct => "array",
      special => "form"
    },
    columns =>{
      caption => "Columns Returned",
      struct => "array",
      special => "pre-formatted-list",
    },
    description => {
      caption=> "Description",
      struct => "text",
      special => "",
    },
    query => {
      caption=> "Query Text",
      struct => "text",
      special => "pre-formatted"
    },
    schema => {
      caption=> "Schema",
      struct => "text",
      special => "",
    },
    name => {
      caption=> "Query Name",
      struct => "text",
      special => "",
    },
    tags => {
      caption => "Tags",
      struct => "hash key list",
    },
  };
  $http->queue(q{<table class="table">});
  for my $i (
    "name", "schema", "description", "tags", "columns", "args", "query"
  ){
    #DEBUG "i = $i";
    my $d = $descrip->{$i};
    $http->queue(qq{
      <tr>
        <td align="right" valign="top">
          <strong>$d->{caption}</strong>
        </td>
        <td align="left" valign = "top">
    });
    if($d->{struct} eq "text"){
      #DEBUG 'text';
      if(
        defined($d->{special}) &&
        $d->{special} eq "pre-formatted"
      ){
         $self->RefreshEngine($http, $dyn, "<pre><code class=\"sql\">$self->{query}->{$i}</code></pre>")
      } else {
         $self->RefreshEngine($http, $dyn, "$self->{query}->{$i}")
      }
    }
    if($d->{struct} eq "array"){
      #DEBUG 'array';
      if($d->{special} eq "pre-formatted-list"){
        #DEBUG 'pre-formatted-list';

        $http->queue(qq{
          <table class="table table-condensed">
        });
        for my $j (@{$self->{query}->{$i}}){
          $self->RefreshEngine($http, $dyn, "<tr><td>$j</td></tr>");
        }
        $self->RefreshEngine($http, $dyn, "</table>");

      } elsif($d->{special} eq "form"){
        #DEBUG 'form';
        $self->RefreshEngine($http, $dyn, "<table class=\"table\">");
        for my $arg (@{$self->{query}->{args}}){
          # preload the Input if arg is in cache
          if (defined $self->{BindingCache}->{$arg}) {
            $self->{Input}->{$arg} = $self->{BindingCache}->{$arg};
          }
          $self->RefreshEngine($http, $dyn, qq{
            <tr>
              <th style="width:5%">$arg</th>
              <td>
                <?dyn="LinkedDelegateEntryBox" linked="Input" index="$arg"?>
              </td>
            </tr>
          });
        }
        $http->queue('</table>');
        $http->queue('<p>');
        $self->NotSoSimpleButton($http, { 
            caption => "Query and Display Results",
            op => "MakeQuery",
            sync => "Update();",
            class => "btn btn-primary",
            then => "results"
        });
        $http->queue('</p>');
        $http->queue('<p>');
        $self->NotSoSimpleButton($http, { 
            caption => "Query and Go to Tables",
            op => "MakeQuery",
            sync => "Update();",
            class => "btn btn-default",
            then => "tables"
        });
        $http->queue('</p>');
      }
    } elsif($d->{struct} eq "hash key list"){
      # TODO: This is both not a hash key list, AND it only works
      # for tags!
      $http->queue(join(', ', @{$self->{query}->{tags}}));
    }
    $self->RefreshEngine("</td></tr>");
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method DeleteQuery($http,$dyn){
  $self->{Mode} = "DeleteQueryPending";
  $self->{QueryPendingDelete} = $dyn->{query_name};
}
method DeleteQueryPending($http, $dyn){
  $self->RefreshEngine($http, $dyn, qq{
    <p>
      Do you want to delete query named $self->{QueryPendingDelete}?
    </p>

    <?dyn="NotSoSimpleButton" op="ReallyDeleteQuery" caption="Yes, Delete it" sync="Update();"?>
    <?dyn="NotSoSimpleButton" op="CancelDeleteQuery" caption="No, don't delete" sync="Update();"?>
  });
}
method ReallyDeleteQuery($http, $dyn){
 PosdaDB::Queries::Delete($self->{QueryPendingDelete});
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}
method CancelDeleteQuery($http, $dyn){
 delete $self->{QueryPendingDelete};
 $self->{Mode} = "ListQueries";
}

method GetBindings() {
  my $bc = $self->{BindingCache};

  my @bindings;
  for my $i (@{$self->{query}->{args}}){
    $bc->{$i} = $self->{Input}->{$i};
    push(@bindings, $self->{Input}->{$i});
  }

  # Save the cache to disk
  store $bc, "$self->{SavedQueriesDir}/bindingcache.pinfo";

  return \@bindings;
}

method MakeQuery($http, $dyn){
  # ensure the schema is valid
  if ($self->{query}->{connect} eq 'invalid database name') {
    $self->{ErrorMessage} = 'Requested schema does not exist!';
    $self->{Mode} = 'QueryError';
    return;
  }

  my $query = {};
  my $then = $dyn->{then};

  $query->{bindings} = $self->GetBindings();

  $self->{Mode} = "QueryWait";

  $self->{query}->SetAsync();

  $self->{query_rows} = [];
  $self->{query}->RunQuery(
    func($row) {
      push @{$self->{query_rows}}, $row;
    },
    $self->QueryEnd($query, $then),
    func($message) {
      $self->{Mode} = "QueryError";
      $self->{ErrorMessage} = $message;
      $self->AutoRefresh;
    },
    @{$query->{bindings}}
  );

}

method QueryError($http, $dyn) {
  $http->queue(qq{
    <div>
      <p class="alert alert-danger">Error executing query!</p>
      <p>Query that was executing: $self->{Query}</p>
      <pre>$self->{ErrorMessage}</pre>
    </div>
  });

  $self->NotSoSimpleButton($http, {
    caption => "Return to query",
    op => "ResetQuery",
    sync => 'Update();'
  });
}

method ResetQuery($http, $dyn) {
  $self->SetActiveQuery($http, {query_name => $self->{Query}});
}

method QueryWait($http, $dyn) {
  $http->queue(qq{
    <div class="alert alert-info">
      Executing query...
      <div class="spinner" style="display:inline-block;margin-left:30px"></div>
    </div>
  });
}

method QueryEnd($query, $then) {
  my $start_time = time;
  my $sub = sub {
    my($status, $struct) = @_;
    if($self->{Mode} eq "QueryWait"){
      $self->AutoRefresh;
    }
    # if($status = "Succeeded" && $struct->{Status} eq "OK"){

    if($self->{query}->{query} =~ /^select/){
      my $struct = { Rows => $self->{query_rows} };

      if ($then eq 'results') {
        return $self->CreateAndSelectTableFromQuery($self->{query}, $struct, $start_time);
      } else {
        $self->CreateTableFromQuery($self->{query}, $struct, $start_time);
        $self->{Mode} = "Tables";
      }
    } elsif(exists $struct->{NumRows}){
      return $self->UpdateInsertCompleted($query, $struct);
    }

    # } else {
    #   if($self->{Mode} eq "QueryWait"){
    #     $self->{Mode} = "QueryFailed";
    #   }
    #   unless(exists $self->{FailedQueries}){ $self->{FailedQueries} = [] }
    #   push @{$self->{FailedQueries}}, {
    #     query => $query,
    #     result => $struct
    #   };
    # }
  };
  return $sub;
}
method UpdateInsertCompleted($query, $struct){
  unless(exists $self->{CompletedUpdatesAndInserts}){
    $self->{CompletedUpdatesAndInserts} = [] }
  push(@{$self->{CompletedUpdatesAndInserts}}, {
    query => $query,
    results => $struct,
  });
  my $index = $#{$self->{CompletedUpdatesAndInserts}};
  if($self->{Mode} eq "QueryWait"){
    $self->{SelectedUpdateInsert} = $index;
    $self->{Mode} eq "UpdateInsertStatus";
  }
}

method CreateTableFromQuery($query, $struct, $start_at) {
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
  my $new_entry = {
    type => "FromQuery",
    at => $start_at,
    duration => time - $start_at,
    rows => $struct->{Rows},
  };
  my $new_q = {
  };
  for my $i (keys %$query){
    unless($i eq 'columns' 
        or $i eq 'dbh' # if the handle is included it will fail to Freeze
    ){ 
      $new_q->{$i} = $query->{$i};
    }
  }
  my @cols = @{$query->{columns}};
  $new_q->{columns} = \@cols;
  $new_entry->{query} = $new_q;
  push(@{$self->{LoadedTables}}, $new_entry);

}
method SelectNewestTable() {
  my $index = $#{$self->{LoadedTables}};
  if($self->{Mode} eq "QueryWait"){
    $self->{Mode} = "TableSelected";
    $self->{SelectedTable} = $index;
  }
}

method CreateAndSelectTableFromQuery($query, $struct, $start_at){
	$self->CreateTableFromQuery($query, $struct, $start_at);
	$self->SelectNewestTable();
}

method DownloadPreparedReport($http, $dyn) {
  my $filename = $dyn->{filename};
  my $shortname = $dyn->{shortname};

  DEBUG $filename;

  my $fh;
  if(open $fh, $filename) {
    $http->DownloadHeader("text/csv", $shortname);
    Dispatch::Select::Socket->new(
      $self->SendFile($http),
    $fh)->Add("reader");
  }

}

sub WaitHttpReady{
  my($this, $disp, $buff, $http) = @_;
  my $sub = sub {
    my($event) = @_;
    #print STDERR "UnThrottling tar\n";
    $http->queue($buff);
    $disp->Add("reader");
  };
  return $sub;
}
sub SendFile{
  my($this, $http) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $count = sysread($sock, $buff, 10240);
    if($count <= 0){
      $disp->Remove;
      return;
    }
    if($http->ready_out){
      $http->queue($buff);
    } else {
      #print STDERR "Throttling tar\n";
      $disp->Remove("reader");
      my $event = Dispatch::Select::Event->new(
        Dispatch::Select::Background->new(
          $this->WaitHttpReady($disp, $buff, $http)));
      $http->wait_output($event);
    }
  };
  return $sub;
}

method DownloadTableAsCsv($http, $dyn){
  my $table = $self->{LoadedTables}->[$dyn->{table}];
  my $q_name;

  if($table->{type} eq "FromQuery"){
    $q_name = "$table->{query}->{name}.csv";
  } elsif ($table->{type} eq "FromCsv") {
    $q_name = $table->{basename};
  } else {
    die "What kind of table is this?!";
  }

  $http->DownloadHeader("text/csv", "$q_name");
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd(
    $cmd,
    $table, 
    func($frag) {
      $http->queue("$frag");
    }, 
    func() {
      # do nothing, on purpose
    }
  );
}

method StoreQuery($query, $filename) {
  # my $new_q = {};
  # for my $i (keys %$query){
  #   unless($i eq 'columns' 
  #       or $i eq 'dbh' # if the handle is included it will fail to Freeze
  #   ){ 
  #     $new_q->{$i} = $query->{$i};
  #   }
  # }
  DEBUG "Storing query to: $filename";
  delete $query->{dbh};
  store $query, $filename;
}
method SaveTableAsReport($http, $dyn){
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  my $dir = $self->{PreparedReportsDir};
  my $public = $dyn->{public};
  if (defined $public) {
    DEBUG "Saving to public!";
    $dir = $self->{PreparedReportsCommonDir};
  }
  my $filename = $dyn->{saveName};

  if($table->{type} eq "FromQuery"){
    $self->StoreQuery($table->{query},
     "$dir/$filename.query");
  }

  # TODO: need to find a valid non-conflicting filename here

  my $file = "$dir/$filename";
  DEBUG "Saving to: $file";

  open my $fh, ">$file" or die "Can't open $file for writing ($!)";
  my $cmd = "PerlStructToCsv.pl";
  Dispatch::BinFragReader->new_serialized_cmd(
    $cmd,
    $table, 
    func($frag) {
      print $fh $frag;
    }, 
    func() {
      close $fh;
      $self->QueueJsCmd("alert('Report saved!');");
    }
  );
}

method SetUseAsArg($http, $dyn) {
  $self->{Mode} = 'UseAsArg';
  $self->{UseAsArgOps} = $dyn;
}
method UseAsArg($http, $dyn) {
  my $arg_name = $self->{UseAsArgOps}->{arg};
  my $value = $self->{UseAsArgOps}->{value};
  $http->queue(qq{
    <h2>Execute new query using selected argument value</h2>

    <div class="row">
      <div class="col-md-4">
        <div class="panel panel-default">
          <div class="panel-heading">Selected argument type</div>
          <div class="panel-body">
            $arg_name
          </div>
        </div>
      </div>
      <div class="col-md-8">
        <div class="panel panel-default">
          <div class="panel-heading">Selected argument value</div>
          <div class="panel-body">
            $value
          </div>
        </div>
      </div>
    </div>

    <p class="alert alert-info">The following queries can be executed with
    this as an input:</p>
  });

  $self->{BindingCache}->{$arg_name} = $value;

  # present a list of the possible queries here
  my $queries = PosdaDB::Queries->GetQuerysWithArg($arg_name);
  my $menu = [];
  $http->queue(qq{
    <div class="list-group">
  });
  for my $q (@$queries) {
    my ($name, $desc) = @$q;
    $http->queue(qq{
      <a class="list-group-item" href="#"
        onClick="javascript:PosdaGetRemoteMethod('SetActiveQuery', 'query_name=$name', function () {Update();});"
      >
        <h4 class="list-group-item-heading">$name</h4>
        <p class="list-group-item-text">$desc</p>
      </a>
    });
    # $self->NotSoSimpleButton($http, {
    #   caption => "$name",
    #   op => "SetActiveQuery",
    #   query_name => "$name",
    #   title => $desc,
    #   sync => 'Update();'
    # });
  }
  $http->queue(qq{
    </div>
  });
}

method InsertSaveReportModal($http, $name, $table) {
  $http->queue(qq{
    <button type="button" class="btn btn-default"
            data-toggle="modal" data-target="#saveReportModal">
      Save as Report
    </button>

    <div class="modal" id="saveReportModal" tabindex="-1"
         role="dialog" aria-labelledby="myModalLabel">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Save as Report</h4>
          </div>
          <div class="modal-body">
          <form id="saveAsReportForm">
            <div class="form-group">
              <label for="saveName">Save as</label>
              <input type="input" class="form-control" 
                     id="saveName" name="saveName"
                     value="$name">
            </div>
            <div class="checkbox">
              <label>
                <input type="checkbox" name="public"> Save as a Public Report
              </label>
            </div>
          </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default" 
                    data-dismiss="modal">Cancel</button>
            <button type="button" class="btn btn-primary"
                    onClick="javascript:PosdaGetRemoteMethod('SaveTableAsReport', \$('#saveAsReportForm').serialize(), function () {Update();});"
                    data-dismiss="modal"
            >Save</button>
          </div>
        </div>
      </div>
    </div>

  });

}

method TableSelected($http, $dyn){
  my $table = $self->{LoadedTables}->[$self->{SelectedTable}];
  if($table->{type} eq "FromQuery"){
    my $query = $table->{query};
    my $rows = $table->{rows};
    my $num_rows = @$rows;
    my $at = $table->{at};
    $self->RefreshEngine($http, $dyn, qq{
      <div>
      <h3>Table from query: $query->{name}</h3>
      <p>
        <a class="btn btn-primary" 
           href="DownloadTableAsCsv?obj_path=$self->{path}&table=$self->{SelectedTable}">
           Download
        </a>
      });
    $self->InsertSaveReportModal($http, "$query->{name}.csv");
    $self->NotSoSimpleButton($http, {
      caption => "Return to Query",
      op => "SetActiveQuery",
      query_name => $query->{name},
      sync => 'Update();'
    });
    $http->queue(qq{
      </p>

      <div class="panel panel-default">
        <div class="panel-heading">Description</div>
        <div class="panel-body">
          $query->{description}
        </div>
      </div>

      <p>Schema: $query->{schema}</p>
    });

    my $numb = @{$query->{bindings}};
    if($numb > 0){
      $http->queue('Bindings:<ul>');
      for my $i (0 .. $#{$query->{bindings}}){
        $http->queue("<li>$query->{args}->[$i]: " .
          "$query->{bindings}->[$i]</li>");
      }
      $http->queue('</ul>');
    }
    $http->queue("Rows: $num_rows<hr>");
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    for my $i (@{$query->{columns}}){
      $http->queue("<th>$i</th>");
    }
    $http->queue('</tr>');

    my $col_pos = 0;
    for my $r (@$rows){
      $http->queue('<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        my $cn = $query->{columns}->[$col_pos++];
        $http->queue("<td>");
        if (defined $self->{AllArgs}->{$cn}) {
          $self->NotSoSimpleButton($http, {
              class => "",
              caption => "$v_esc",
              op => "SetUseAsArg",
              value => $v_esc,
              arg => $cn,
              element => 'a',
              title => 'Click to use this value as an input to another query',
              sync => 'Update();'
          });
        } else {
          $http->queue($v_esc);
        }
        # TODO: This should be configurable!
        if ($cn eq "file_id") {
          $self->NotSoSimpleButton($http, {
              caption => "View",
              op => "OpenViewPopup",
              file_id => "$v_esc",
              sync => 'Update();'
          });
        }

        if ($cn eq "sop_instance_uid") {
          if (defined $query->{name} and 
              $query->{name} =~ /duplicate/i) {
            $self->NotSoSimpleButton($http, {
                caption => "Compare",
                op => "OpenComparePopup",
                sop => "$v_esc",
                sync => 'Update();'
            });
          }
        }
        $http->queue("</td>");
      }
      $col_pos = 0;
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  } elsif($table->{type} eq "FromCsv"){
    my $file = $table->{file};
    my $rows = $table->{rows};
    my $num_rows = @$rows - 1;
    my $at = $table->{at};
    $self->RefreshEngine($http, $dyn, qq{
      <div style="background-color: white">
      Table from CSV file: $file   
      <a class="btn btn-sm btn-primary" 
         href="DownloadTableAsCsv?obj_path=$self->{path}&table=$self->{SelectedTable}">Download</a>
     });
    $self->InsertSaveReportModal($http, basename($file));
    $http->queue(qq{
      <br>
    });
    $http->queue("Rows: $num_rows<br>Results:<hr>");
    $http->queue(qq{
      <table class="table table-striped">
        <tr>
    });
    for my $i (@{$rows->[0]}){
      $http->queue("<th>$i</th>");
    }
    $http->queue('</tr>');
  
    for my $ri (1 .. $#{$rows}){
      my $r = $rows->[$ri];
      $http->queue('<tr>');
      for my $v (@$r){
        unless(defined($v)){ $v = "<undef>" }
        my $v_esc = $v;
        $v_esc =~ s/</&lt;/g;
        $v_esc =~ s/>/&gt;/g;
        $http->queue("<td>$v_esc</td>");
      }
      $http->queue('</tr>');
    }
    $self->RefreshEngine($http, $dyn, "</table></div>");
  }
}
method UpdateInsertStatus($http, $dyn){
}
method UpdatesInserts($http, $dyn){
}
#############################
my $f_form = '
<form action="<?dyn="StoreFileUri"?>"
enctype="multipart/form-data" method="POST" class="dropzone">
</form>';
method Upload($http, $dyn){
  $self->RefreshEngine($http, $dyn, $f_form);
}
method StoreFileUri($http, $dyn){
  $http->queue("StoreFile?obj_path=$self->{path}");
}
method StoreFile($http, $dyn){
  my $method = $http->{method};
  my $content_type = $http->{header}->{content_type};
  unless($method eq "POST" && $content_type =~ /multipart/){
    print STDERR "No file posted\n";
    return;
  }
  $self->{UploadCount}++;
#  $http->ParseMultipartShouldWork("$self->{TempDir}/$self->{UploadCount}",
#    $self->UploadDone($http, $dyn));
  my $file = $http->ParseMultipart(
     "$self->{TempDir}/$self->{UploadCount}");
  &{$self->UploadDone($http, $dyn)}($file);
}
method UploadDone($http, $dyn){
  my $sub = sub {
    my($file) = @_;
    unless(exists($self->{UploadQueue})){ $self->{UploadQueue} = [] }
    push(@{$self->{UploadQueue}}, $file);
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
    $http->queue("<pre>");
    $http->queue("File uploaded into $file\n");
    for my $k (keys %$dyn){
      $http->queue("dyn{$k} = $dyn->{$k}\n");
    }
    for my $k (keys %$http){
      $http->queue("http{$k} = $http->{$k}\n");
    }
    for my $k (keys %{$http->{header}}){
      $http->queue("http{header}->{$k} = $http->{header}->{$k}\n");
    }
    $http->queue("<a href=\"Refresh?obj_path=$self->{path}\">Go back</a>");
    $http->queue("<hr><pre>");
  };
  return $sub;
}

method ServeUploadQueue() {
  unless($#{$self->{UploadQueue}} >= 0){ return }
  my $up_load_file = shift @{$self->{UploadQueue}};
  my $command = "ExtractUpload.pl \"$up_load_file\" \"$self->{TempDir}\"";
  my $hash = {};
  Dispatch::LineReader->new_cmd($command, $self->ReadConvertLine($hash),
    $self->ConvertLinesComplete($hash));
}

method ReadConvertLine($hash){
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^(.*):\s*(.*)$/){
      my $k = $1; my $v = $2;
      $hash->{$k} = $v;
    }
  };
  return $sub;
}
method ConvertLinesComplete($hash){
  my $sub = sub {
    push(@{$self->{UploadedFiles}}, $hash);
    # If the file was a CSV, go ahead and load it as a table now
    if ($hash->{'mime-type'} eq 'text/csv') {
      $self->LoadCSVIntoTable_NoMode($hash->{'Output file'});
    }
    $self->InvokeAfterDelay("ServeUploadQueue", 0);
  };
  return $sub;
}
method Files($http, $dyn){
  unless(exists $self->{UploadedFiles}) { $self->{UploadedFiles} = [] }
  my $num_files = @{$self->{UploadedFiles}};
  if($num_files == 0){
    return $self->RefreshEngine($http, $dyn, "No files have been uploaded");
  }
  $self->RefreshEngine($http, $dyn,
    '<table class="table table-striped table-condensed">' .
    '<tr><th colspan="5"><p>Files Uploaded</p></th></tr>'.
    '<tr><th><p>File</p></th><th><p>Size</p></th><th><p>Type</p></th>' .
    '<th><p>File Type</p></th>' .
    '<th><p>Op</p></th></tr>');
  file:
  for my $in(0 .. $#{$self->{UploadedFiles}}){
    my $i = $self->{UploadedFiles}->[$in];
    my $path = $i->{"Output file"};
    my $file;
    if($path =~ /\/([^\/]+)$/){
      $file = $1;
    } else {
      $file = $path;
    }
    my $type = $i->{"mime-type"};
    my $size  = $i->{length};
    unless(exists $i->{file_type}){
      my $file_type = `file \"$path\"`;
      chomp $file_type;
      if($file_type =~ /^.*:(.*)$/){
        $i->{file_type} = $1;
      } else {
        $i->{file_type} = $file_type;
      }
    }
    $self->RefreshEngine($http, $dyn, '<tr>' .
      "<td><p>$file</p></td>" .
      "<td><p>$size</p></td><td><p>");
    $self->RefreshEngine($http, $dyn, $type .
      "</p></td><td><p>");
    $self->RefreshEngine($http, $dyn, $i->{file_type} .
      "</p></td><td><p>");
    if($type eq "text/csv"){
      $self->NotSoSimpleButton($http, {
        caption => "Load as Table",
        op => "LoadCsvIntoTable",
        index => $in
      });
    }
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}
method LoadCsvIntoTable($http, $dyn){
  $self->{Mode} = "LoadCsvIntoTable";
  my $file = $self->{UploadedFiles}->[$dyn->{index}]->{"Output file"};
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
}
method LoadCSVIntoTable_NoMode($file) {
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  $self->SemiSerializedSubProcess($cmd, $self->CsvLoaded($file));
}

method CsvLoaded($file){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded"){
      if($struct->{status} eq "OK"){
        unless(
          exists $self->{LoadedTables} &&
          ref($self->{LoadedTables}) eq "ARRAY"
        ){ $self->{LoadedTables} = [] }

        # Get the basename of the file
        my $basename;
        my $fn = $file;
        if($fn =~ /\/([^\/]+)$/){
          $basename = $1;
        } else {
          $basename = $fn;
        }

        # test if there is a query file to load
        my $queryfile = "$file.query";
        my $query;

        # if $queryfile exists, load it
        if (-e $queryfile) {
          $query = retrieve $queryfile;
        }

        my $new_table_entry = {
          type => "FromCsv",
          file => $file,
          basename => $basename,
          at => time,
          rows => $struct->{rows},
        };

        if (defined $query) {
          $new_table_entry->{query} = $query;
          $new_table_entry->{type} = "FromQuery";
          #delete the first row, as it is query headers
          delete $new_table_entry->{rows}->[0];
        }

        push(@{$self->{LoadedTables}}, $new_table_entry);
      } else {
      }
    } else {
    }
  };
  return $sub;
}

method Reports($http, $dyn) {
  # load list of reports from the dir
  my $report_dir = $self->{PreparedReportsDir};
  my $common_dir = $self->{PreparedReportsCommonDir};

  opendir(my $dh, $report_dir) or die "Can't open report dir: $report_dir";
  my @files = grep { 
    /^[^\.]/ and not /\.query$/
  } readdir($dh); # ignore dots
  closedir $dh;

  opendir(my $cdh, $common_dir) or die "Can't open report dir: $common_dir";
  my @common_files = grep { 
    /^[^\.]/ and not /\.query$/
  } readdir($cdh); # ignore dots
  closedir $cdh;

  $http->queue(qq{
    <h3>Common reports</h3>
    <table class="table">
    <tr>
      <th>Filename</th>
      <th>Type</th>
      <th>Bytes</th>
      <th>Download</th>
    </tr>
  });
  for my $f (@common_files) {
    my $filename = "$common_dir/$f";
    my $type = (-e "$filename.query")?"Query":"CSV";
    my $size = (stat($filename))[7];
    $http->queue(qq{
      <tr>
      <td>
    });
    $self->NotSoSimpleButton($http, {
        caption => "$f",
        op => "LoadPreparedReport",
        filename => $f,
        ftype => 'common',
        sync => "Update();",
        element => 'a',
        class => "",
    });
    $http->queue(qq{
        </td>
        <td>$type</td>
        <td>$size</td>
        <td>
        <a class="btn btn-primary" 
           href="DownloadPreparedReport?obj_path=$self->{path}&filename=$filename&shortname=$f">
           ⬇
        </a>
      </td>
      </tr>
    });
  }
  $http->queue(qq{
    </table>
  });

  $http->queue(qq{
    <h3>Personal (user) reports</h3>
    <table class="table">
    <tr>
      <th>Filename</th>
      <th>Type</th>
      <th>Bytes</th>
    </tr>
  });
  for my $f (@files) {
    my $filename = "$report_dir/$f";
    my $type = (-e "$filename.query")?"Query":"CSV";
    my $size = (stat($filename))[7];
    $http->queue(qq{<tr><td>});
    $self->NotSoSimpleButton($http, {
        caption => "$f",
        op => "LoadPreparedReport",
        filename => $f,
        ftype => 'personal',
        sync => "Update();",
        element => 'a',
        class => "",
    });
    $http->queue(qq{
        </td>
        <td>$type</td>
        <td>$size</td>
      </tr>});
  }
  $http->queue(qq{
    </table>
  });

}

method LoadPreparedReport($http, $dyn) {
  my $dir;
  if ($dyn->{ftype} eq 'common') {
    $dir = $self->{PreparedReportsCommonDir};
  } elsif ($dyn->{ftype} eq 'personal') {
    $dir = $self->{PreparedReportsDir};
  } else {
    die "Unknown ftyp $dyn->{ftype}";
  }
  my $file = "$dir/$dyn->{filename}";

  # couldn't call existing method because we need more control 
  my $cmd = "CsvToPerlStruct.pl \"$file\"";
  my $final_callback = $self->CsvLoaded($file);
  $self->SemiSerializedSubProcess($cmd, func() {
    &$final_callback(@_);
    my $index = $#{$self->{LoadedTables}};
    $self->{SelectedTable} = $index;
    $self->{Mode} = "TableSelected";
    $self->AutoRefresh;
  });

  $self->{Mode} = "QueryWait";
}

method Tables($http, $dyn){
  unless(exists $self->{LoadedTables}) { $self->{LoadedTables} = [] }
  my $num_tables = @{$self->{LoadedTables}};
  if($num_tables == 0){
    return $self->RefreshEngine($http, $dyn, "No tables have been loaded");
  }
  $self->RefreshEngine($http, $dyn,
    '<table class="table table-striped table-condensed">' .
    '<tr><th colspan="4"><p>Tables</p></th></tr>'.
    '<tr><th><p>Type</p></th><th><p>Rows</p></th><th><p>File/Query Name</p>' .
    '</th></th>' .
    '<th><p>Op</p></th></tr>');
  file:
  for my $in(0 .. $#{$self->{LoadedTables}}){
    my $i = $self->{LoadedTables}->[$in];
    my $type = $i->{type};
    my $type_disp;
    my $num_rows;
    my $name;
    if($type eq "FromCsv") {
      $type_disp = "From CSV Upload";
      $num_rows = @{$i->{rows}} - 1;
      $name = $i->{basename};
    } elsif ($type eq "FromQuery"){
      $type_disp = "From DB Query";
      $num_rows = @{$i->{rows}};
      $name = "$i->{query}->{schema}:$i->{query}->{name}(";
      for my $bi (0 .. $#{$i->{query}->{bindings}}){
        my $b = $i->{query}->{bindings}->[$bi];
        $name .= "\"$b\"";
        unless($bi == $#{$i->{query}->{bindings}}){
          $name .= ", ";
        }
      }
      $name .= ")";
    }
    $self->RefreshEngine($http, $dyn,
      "<tr><td><p>$type</p></td><td><p>$num_rows</p></td>" .
      "<td><p>$name</p></td><td><p>");
    $self->NotSoSimpleButton($http, {
        caption => "Select",
        op => "SelectTable",
        index => $in,
        sync => "Update();",
    });
    $http->queue(qq{
        <a class="btn btn-primary" 
           href="DownloadTableAsCsv?obj_path=$self->{path}&table=$in">
           Download
        </a>
    });
    my $can_nickname = 0;
    my $can_command = 0;
    my $cols;
    if($type eq "FromCsv"){ $cols = $i->{rows}->[0] }
    elsif($type eq "FromQuery"){ $cols = $i->{query}->{columns} }
    for my $i (@$cols) {
      if(
        $i eq "series_instance_uid" ||
        $i eq "study_instance_uid" ||
        $i eq "sop_instance_uid" ||
        $i eq "file_id"
      ){ $can_nickname = 1 }
      if($i eq "Operation") { $can_command = 1 }
    }
    if($can_nickname){
      $self->NotSoSimpleButton($http, {
          caption => "Add Nicknames",
          op => "AddNicknames",
          index => $in,
          sync => "Update();",
      });
    }
    if($can_command){
      $self->NotSoSimpleButton($http, {
          caption => "Perform Operations",
          op => "ExecuteCommand",
          index => $in,
          sync => "Update();",
      });
    }
    $self->RefreshEngine($http, $dyn, '</p></td></tr>');
  }
  $self->RefreshEngine($http, $dyn, '</table>');
}

func apply_command($command, $colmap, $row) {
  if (not defined $command) {
    return undef
  }

  # build the final line
  my $final = $command->{cmdline};
  map {
    my $parm = $_;
    my $index_of_parm = $colmap->{$parm};
    my $new_value = $row->[$index_of_parm];

    $final =~ s/<$parm>/$new_value/g;
  } @{$command->{parms}};

  return $final;
}

method ExecuteCommand($http, $dyn) {
  my $table = $self->{LoadedTables}->[$dyn->{index}];

  # generate a map of column name to col index
  my $colmap = {};
  map {
    my $item = $table->{rows}->[0]->[$_];
    $colmap->{$item} = $_;
  } (0 .. $#{$table->{rows}->[0]});

  # Test for pipe edge case
  my $first_row_op = $table->{rows}->[1]->[$colmap->{Operation}];
  if (defined $self->{Commands}->{$first_row_op}->{pipe_parms}) {
    my $op = $self->{Commands}->{$first_row_op};

    say "First row is a Pipeop!";

    # get list of columns that are "column vars"
    my @column_vars = $op->{pipe_parms} =~ /<([^<>]+)>/g;

    # transform column_var columns into lists
    my $cols = {};
    for my $col_name (@column_vars) {
      my $col_idx = $colmap->{$col_name};

      my $col1 = [];
      for my $row (@{$table->{rows}}) {
        push @$col1, $row->[$col_idx];
      }
      shift @$col1; # kill the first element

      $cols->{$col_name} = $col1;
    }

    # now generate the cmdline like normal
    my $final_cmd = apply_command($op, $colmap, $table->{rows}->[1]);

    my @planned_operations;
    my $first_col_name = [keys %{$cols}]->[0];
    for my $i (0..$#{$cols->{$first_col_name}}) {
      my $pipe_parm_format = $op->{pipe_parms};
      for my $var (@column_vars) {
        my $v = $cols->{$var}->[$i];
        $pipe_parm_format =~ s/<$var>/$v/g;
      }
      push @planned_operations, $pipe_parm_format;
    }

    $self->{PlannedOperations} = \@planned_operations;
    $self->{PlannedPipeOperation} = $final_cmd;
    $self->{Mode} = 'PipeOperationsSummary';
    return;
  }

  # generate summary of commands to be run
  my @operations = map {
    my $op = $_->[$colmap->{Operation}];
    apply_command($self->{Commands}->{$op}, $colmap, $_);
  } @{$table->{rows}};

  # remove any that failed
  $self->{PlannedOperations} = [grep { defined $_ } @operations];

  $self->{Mode} = 'OperationsSummary';
}

method ExecutePlannedOperations($http, $dyn) {
  $self->{TotalPlannedOperations} = scalar @{$self->{PlannedOperations}};
  $self->UpdateWaitingOnOps($http, $dyn);

  $self->ExecuteNextOperation();
}
method UpdateWaitingOnOps($http, $dyn) {
  my $total = $self->{TotalPlannedOperations};
  my $left = scalar @{$self->{PlannedOperations}};

  $self->{RemainingOpCount} = $left;

  $self->{Mode} = 'WaitingOnOperation';
  $self->AutoRefresh();
}

method ExecuteNextOperation() {
  my $operations = $self->{PlannedOperations};

  my $op = shift @$operations;

  if (not defined $op) {
    say "No ops left, stopping the op train!";
    $self->{Mode} = 'ResultsAreIn';
    $self->AutoRefresh();
    return;
  }

  Dispatch::LineReader->new_cmd(
    $op, 
    func($line) {
      # save into output buffer
      push @{$self->{Results}}, $line;
    },
    func() {
      # queue the next one?
      say "finished op: $op";
      $self->UpdateWaitingOnOps();
      $self->ExecuteNextOperation();
    }
  );

}

method ExecutePlannedPipeOperations($http, $dyn) {
  my $cmd = $self->{PlannedPipeOperation};
  my $stdin = $self->{PlannedOperations};

  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd,
    $stdin,
    func($return) {
      $self->{Results} = $return;
      $self->{Mode} = 'ResultsAreIn';
      $self->AutoRefresh;
      say "ResultsAreIn!";
    }
  );

  $self->{Mode} = 'WaitingOnOperation';
}

method WaitingOnOperation($http, $dyn) {
  $http->queue("<p>Waiting on operations to finish...</p>");
  my $total = $self->{TotalPlannedOperations};
  my $left = $self->{RemainingOpCount};
  if (defined $total and defined $left) {
    $http->queue("<p>Left: $left of: $total</p>");
  }
}

method ResultsAreIn($http, $dyn) {
  $http->queue("<p>results are in!");
  $self->NotSoSimpleButton($http, {
    caption => "Save as CSV",
    op => "SaveResultsAsCsv",
    syn => "Update();",
  });
  $http->queue("</p>");
  map {
    $http->queue("<p>$_</p>");
  } @{$self->{Results}};
}

method SaveResultsAsCsv($http, $dyn){
  my $file = "$self->{TempDir}/OpResults_$self->{Sequence}.csv";
  $self->{Sequence} += 1;
  my $length = 0;
  open my $fh, ">$file" or die "Can't open $file for writing ($!)";
  for my $line (@{$self->{Results}}){
    print $fh "$line\n";
    $length += length("$line\n");
  }
  close $fh;
  my $fdesc = {
    "Output file" => $file,
    file_type => "ASCII text",
    length => $length,
    "mime-type" => "text/csv",
  };
  push @{$self->{UploadedFiles}}, $fdesc;
}

method PipeOperationsSummary($http, $dyn) {
  # display a list of planned operations
  $http->queue(qq{
    <h3>Planned Pipe Operation</h3>
  });

  $self->NotSoSimpleButton($http, {
      caption => "Execute Planned Operations",
      op => "ExecutePlannedPipeOperations",
      sync => "Update();",
  });

  $http->queue(qq{
    <p>The command to be executed:</p>
    <pre>$self->{PlannedPipeOperation}</pre>

    <p>The vlaues to be fed on standard input:</p>
    <table class="table">
      <tr>
        <th>Input</th>
      </tr>
  });

  for my $op (@{$self->{PlannedOperations}}) {
    if (not defined $op) { next }
    $http->queue(qq{
      <tr>
        <td>
          $op
        </td>
      </tr>
    });
  }

  $http->queue(qq{
    </table>
  });

}

method OperationsSummary($http, $dyn) {
  # display a list of planned operations
  $http->queue(qq{
    <h3>Planned Operations</h3>
  });

  $self->NotSoSimpleButton($http, {
      caption => "Execute Planned Operations",
      op => "ExecutePlannedOperations",
      sync => "Update();",
  });

  $http->queue(qq{
    <table class="table">
      <tr>
        <th>Command Line</th>
      </tr>
  });

  for my $op (@{$self->{PlannedOperations}}) {
    if (not defined $op) { next }
    $http->queue(qq{
      <tr>
        <td>
          $op
        </td>
      </tr>
    });
  }

  $http->queue(qq{
    </table>
  });
}

method SelectTable($http, $dyn){
  $self->{SelectedTable} = $dyn->{index};
  $self->{Mode} = "TableSelected";
}
method AddNicknames($http, $dyn){
  my $table_n = $dyn->{index};
  $self->{SelectedTable} = $dyn->{index};
  my $table = $self->{LoadedTables}->[$table_n];
  my @cols;
  my $rs;
  if($table->{type} eq "FromCsv"){
    @cols = @{$table->{rows}->[0]};
    $rs = 1;
  } elsif($table->{type} eq "FromQuery"){
    @cols = @{$table->{query}->{columns}};
    $rs = 0;
  }
  my %nn_types;
  for my $ii (0 .. $#cols){
    my $i = $cols[$ii];
    if($i eq "series_instance_uid"){
      $nn_types{series_nn} = $ii;
    } elsif($i eq "study_instance_uid") {
      $nn_types{study_nn} = $ii;
    } elsif($i eq "sop_instance_uid") {
      $nn_types{sop_nn} = $ii;
    } elsif($i eq "file_id") {
      $nn_types{file_nn} = $ii;
    }
  }
  $self->{Mode} = "LookingUpNicknames";
  my $file_where;
  if(exists $nn_types{file_nn}){
print STDERR "Fetching File NN\n";
    my $col_n = $nn_types{file_nn};
    $file_where = "where file_id in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $file_where .= "$table->{rows}->[$i]->[$col_n]";
      unless($i == $#{$table->{rows}}){ $file_where .= ", " }
    }
    $file_where .= ")";
    $self->NicknamesByFileId($file_where, "file_nn", $table_n);
  }
  my $sop_where;
  if(exists $nn_types{sop_nn}){
print STDERR "Fetching SOP NN\n";
    my $col_n = $nn_types{sop_nn};
    $sop_where = "where sop_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $sop_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $sop_where .= ", " }
    }
    $sop_where .= ")";
    $self->SeriesStudyBySop($sop_where, "sop_nn", $table_n);
  }
  my $series_where;
  if(exists $nn_types{series_nn}){
print STDERR "Fetching Series NN\n";
    my $col_n = $nn_types{series_nn};
    $series_where = "where series_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $series_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $series_where .= ", " }
    }
    $series_where .= ")";
    $self->StudiesBySeries($series_where, "series_nn", $table_n);
  }
  my $study_where;
  if(exists $nn_types{study_nn}){
print STDERR "Fetching Study NN\n";
    my $col_n = $nn_types{study_nn};
    $study_where = "where study_instance_uid in (";
    for my $i ($rs .. $#{$table->{rows}}){
      $study_where .= "'$table->{rows}->[$i]->[$col_n]'";
      unless($i == $#{$table->{rows}}){ $study_where .= ",\n" }
    }
    $study_where .= ")";
    $self->NicknamesByStudy(
      $study_where, "study_nn", $table_n);
  }
}
method NicknamesByStudy($study_where, $nn_type, $table_n){
print STDERR "NicknamesByStudy(study_where, $nn_type, $table_n)\n";
  my $q = {
    query => "select * from study_nickname\n" . $study_where,
    schema => "posda_nicknames",
    db_type => "postgres",
    columns => [
      "study_instance_uid", "project_name", "site_name",
      "subj_id", "study_nickname"
    ],
    args => [],
    bindings => [],
    name => "Study nickname by study_uids",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->StudyNnsFetchedByStudy($nn_type, $table_n));
}
method StudyNnsFetchedByStudy($nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
print STDERR "StudyNnsFetched::sub($nn_type, $table_n)\n";
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %study_info;
      for my $i (@{$struct->{Rows}}){
        $study_info{$i->[0]}->{project_name} = $i->[1];
        $study_info{$i->[0]}->{site_name} = $i->[2];
        $study_info{$i->[0]}->{subj_id} = $i->[3];
        $study_info{$i->[0]}->{study_nickname} = $i->[4];
      }
      $self->RenderNicknames(\%study_info, {}, {}, {}, {}, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesByFileId($f_where, $nn_type, $table_n){
  my $q = {
    query => "select\n" .
             "  distinct file_id, digest, sop_instance_uid, " .
             "  series_instance_uid, study_instance_uid " .
             "from\n" .
             "  file natural left join file_sop_common\n" .
             "  natural left join file_series\n" .
             "  natural left join file_study\n" .
             $f_where,
     columns => [ "file_id", "digest", "sop_instance_uid",
       "series_instance_uid", "study_instance_uid"],
     args => [ ],
     binding => [ ],
     schema => "posda_files",
     db_type => "postgres",
     name => "get_file_info",
     description => "",
     connect => Database('posda_files')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->FileIdsFetched($nn_type, $table_n));
}
method FileIdsFetched($nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %file_ids;
      for my $i (@{$struct->{Rows}}){
        $file_ids{$i->[0]}->{digest} = $i->[1];
        $file_ids{$i->[0]}->{sop_instance_uid} = $i->[2];
        $file_ids{$i->[0]}->{series_instance_uid} = $i->[3];
        $file_ids{$i->[0]}->{study_instance_uid} = $i->[4];
      }
      my $q_t = "select\n" .
        "  project_name, site_name, subj_id, file_digest,\n" .
        "  sop_nickname_copy as sop_nickname, version_number\n" .
        "from file_nickname\n" .
        "where file_digest in (";
      for my $i (0 .. $#{$struct->{Rows}}){
        $q_t .= "'$struct->{Rows}->[$i]->[1]'";
        unless($i == $#{$struct->{Rows}}) { $q_t .= ", " }
      }
      $q_t .= ")";
      my $q = {
        query => $q_t,
        columns => ["project_name", "site_name", "subj_id", 
          "sop_nickname", "version_number", "file_digest"],
        args =>[],
        bindings =>[],
        schema => "posda_nicknames",
        db_type => "postgres",
        name => "get_file_nicknames",
        description => "",
        connect => Database('posda_nicknames')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->FileNnsFetched($nn_type, \%file_ids, $table_n));
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method FileNnsFetched($nn_type, $f_info, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %dig_info;
      for my $i (@{$struct->{rows}}){
        $dig_info{$i->[3]}->{project_name} = $i->[0];
        $dig_info{$i->[3]}->{site_name} = $i->[1];
        $dig_info{$i->[3]}->{subj_id} = $i->[2];
        $dig_info{$i->[3]}->{sop_nickname} = $i->[4];
        $dig_info{$i->[3]}->{version_number} = $i->[5];
      }
      my $sop_where = "where sop_instance_uid in (";
      my @keys = keys %$f_info;
      for my $i (0 .. $#keys){
        $sop_where .= "'$f_info->{$keys[$i]}->{sop_instance_uid}'";
        unless($i == $#keys) { $sop_where .= ",\n" }
      }
      $sop_where .= ")";
      $self->NicknamesBySop(
        $sop_where, {}, $f_info, \%dig_info, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
} 
method SeriesStudyBySop($sop_where, $nn_type, $table_n){
  my $q = {
    schema => "posda_files",
    db_type => "postgres",
    query => "select\n" .
      "  distinct series_instance_uid, study_instance_uid, sop_instance_uid\n" .
      "from\n" .
      "  file_series natural join file_study natural join file_sop_common\n" .
      $sop_where,
    columns => [
      "sop_instance_uid", "series_instance_uid", "study_instance_uid"
    ],
    args => [],
    bindings => [],
    name => "get series and study by sops",
    description => "",
    connect => Database('posda_files')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SeriesAndStudiesFetched($sop_where, $nn_type, $table_n));
}
method SeriesAndStudiesFetched($sop_where, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %sop_info;
      for my $i (@{$struct->{Rows}}){
        $sop_info{$i->[0]}->{series_instance_uid} = $i->[1];
        $sop_info{$i->[0]}->{study_instance_uid} = $i->[2];
      }
      $self->NicknamesBySop(
        $sop_where, \%sop_info, {}, {}, $nn_type, $table_n);
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesBySop($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n){
  my $q = {
    query => "select\n" .
      "  project_name, site_name, subj_id, sop_nickname, sop_instance_uid\n" .
      "from sop_nickname\n" . $sop_where,
    columns => ["project_name", "site_name", "subj_id", "sop_nickname",
      "sop_instance_uid", ],
    args =>[],
    bindings =>[],
    schema => "posda_nicknames",
    db_type => "postgres",
    name => "get_sop_nicknames",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SopNnsFetched($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n)
  );
}
method SopNnsFetched($sop_where, $sop_info, $file_info, $dig_info, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      for my $i (@{$struct->{Rows}}){
        $sop_info->{$i->[4]}->{project_name} = $i->[0];
        $sop_info->{$i->[4]}->{site_name} = $i->[1];
        $sop_info->{$i->[4]}->{subj_id} = $i->[2];
        $sop_info->{$i->[4]}->{sop_nickname} = $i->[3];
      }
      my $q = {
        query => "select distinct series_instance_uid,\n" .
          "  study_instance_uid\n" .
          "from file_sop_common natural join file_series\n" .
          "  natural join file_study\n" .
          $sop_where,
        columns => [ "series_instance_uid", "study_instance_uid" ],
        args => [],
        bindings => [],
        schema => "posda_files",
        db_type => "postgres",
        name => "get_series_by_sops",
        description => "",
        connect => Database('posda_files')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->SeriesBySopsFetched(
          $sop_info ,$file_info, $dig_info, $nn_type, $table_n)
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method SeriesBySopsFetched(
  $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    my %series_info;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my $series_where = "where series_instance_uid in (";
      for my $ii (0 .. $#{$struct->{Rows}}){
        $series_info{$struct->{Rows}->[$ii]->[0]}->{study_instance_uid} =
          $struct->{Rows}->[$ii]->[1];
        my $i = $struct->{Rows}->[$ii]->[0];
        $series_where .= "'$i'";
        unless($ii == $#{$struct->{Rows}}){
          $series_where .= ", ";
        }
      }
      $series_where .= ")";
      $self->NicknamesBySeries(
        $series_where, \%series_info, $sop_info, $file_info, 
        $dig_info, $nn_type, $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudiesBySeries(
  $series_where, $nn_type, $table_n
){
print STDERR "StudiesBySeries($series_where, $nn_type, $table_n)\n";
  my $q = {
    schema => "posda_files",
    db_type => "postgres",
    query => "select\n" .
      "   distinct series_instance_uid, study_instance_uid,\n" .
      "   project_name, site_name , patient_id\n" .
      "from\n" .
      "  file_series natural join file_study\n" . 
      "   natural join ctp_file natural join file_patient\n" . 
      $series_where,
    columns => ["series_instance_uid", "study_instance_uid",
      "project_name", "site_name", "patient_id" ],
    args => [],
    bindings => [],
    name => "studies by series",
    description => "",
    connect => Database('posda_files')
  };
print STDERR "Calling Serialized SubProcess\n";
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
     $self->StudiesFetchedBySeries(
       $series_where, $nn_type, $table_n)
   );
}
method StudiesFetchedBySeries($series_where, $nn_type, $table_n){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %series_info;
      for my $i (@{$struct->{Rows}}){
        $series_info{$i->[0]}->{study_instance_uid} = $i->[1];
        $series_info{$i->[0]}->{project_name} = $i->[2];
        $series_info{$i->[0]}->{site_name} = $i->[3];
        $series_info{$i->[0]}->{subj_id} = $i->[4];
      }
      $self->NicknamesBySeries(
        $series_where, \%series_info, {}, {}, {}, "series_nn", $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method NicknamesBySeries(
  $series_where, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $q = {
    query => "select\n" .
      "  project_name, site_name, subj_id, series_nickname,\n" .
      "  series_instance_uid\n" .
      "from series_nickname\n" . $series_where,
    columns => ["project_name", "site_name", "subj_id", "series_nickname",
      "series_instance_uid"],
    schema => "posda_nicknames",
    db_type => "postgres",
    args => [],
    bindings => [],
    name => "series nicknames",
    description => "",
    connect => Database('posda_nicknames')
  };
  $self->SerializedSubProcess($q, "SubProcessQuery.pl",
    $self->SeriesNicknamesFetched(
      $series_where, $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n)
  );
}
method SeriesNicknamesFetched(
  $series_where, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      for my $i (@{$struct->{Rows}}){
        $series_info->{$i->[4]}->{project_name} = $i->[0];
        $series_info->{$i->[4]}->{site_name} = $i->[1];
        $series_info->{$i->[4]}->{subj_id} = $i->[2];
        $series_info->{$i->[4]}->{series_nickname} = $i->[3];
      }
      my $q = {
        query => "select distinct study_instance_uid\n" .
          "from file_series natural join file_study\n" .
          $series_where,
        columns => [ "study_instance_uid" ],
        schema => "posda_files",
        db_type => "postgres",
        args => [],
        bindings => [],
        name => "study from series",
        description => "",
        connect => Database('posda_files')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->StudiesBySeriesFetched(
          $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n
        )
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudiesBySeriesFetched(
  $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my $study_where = "where study_instance_uid in (";
      for my $ii (0 .. $#{$struct->{Rows}}){
        my $i = $struct->{Rows}->[$ii]->[0];
        $study_where .= "'$i'";
        unless($ii == $#{$struct->{Rows}}){ $study_where .= ", "}
      }
      $study_where .= ")";
      my $q = {
        schema => "posda_nicknames",
        db_type => "postgres",
        query => "select\n" .
          "  study_instance_uid, project_name, site_name,\n" .
          "  subj_id, study_nickname\n" .
          "from study_nickname\n" . $study_where,
        columns => [ "study_instance_uid", "project_name",
          "site_name", "subj_id", "study_nickname" ],
        args => [],
        bindings => [],
        connect => Database('posda_nicknames')
      };
      $self->SerializedSubProcess($q, "SubProcessQuery.pl",
        $self->StudyNnsFetched(
          $series_info, $sop_info ,$file_info, $dig_info, $nn_type, $table_n
        )
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method StudyNnsFetched(
  $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
  my $sub = sub {
    my($status, $struct) = @_;
    if($status eq "Succeeded" && $struct->{Status} eq "OK"){
      my %study_info;
      for my $i (@{$struct->{Rows}}){
        $study_info{$i->[0]}->{project_name} = $i->[1];
        $study_info{$i->[0]}->{site_name} = $i->[2];
        $study_info{$i->[0]}->{subj_id} = $i->[3];
        $study_info{$i->[0]}->{study_nickname} = $i->[4];
      }
      $self->RenderNicknames(
        \%study_info, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
      );
    } else {
      $self->AutoRefresh;
      $self->{Mode} = "ERROR";
      $self->{ErrorInfo} = {
        status => $status,
        struct => $struct,
      };
    }
  };
  return $sub;
}
method RenderNicknames(
  $study_info, $series_info, $sop_info, $file_info, $dig_info, $nn_type, $table_n
){
print "Render Nicknames: $nn_type, $table_n\n";
$self->{DebugNickname} = {
  study_info => $study_info,
  series_info => $series_info,
  sop_info => $sop_info,
  file_info => $file_info,
  dig_info => $dig_info,
  nn_type => $nn_type,
  table_n => $table_n
};
  if($self->{Mode} eq "LookingUpNicknames"){
    $self->AutoRefresh;
    $self->{Mode} = "TableSelected";
  }
  my $table = $self->{LoadedTables}->[$table_n];
  my $columns;
  my $first_row;
  if($table->{type} eq "FromQuery"){
    $columns = $table->{query}->{columns};
    $first_row = 0;
  }elsif($table->{type} eq "FromCsv"){
    $columns = $table->{rows}->[0];
    $first_row = 1;
  }
  if($nn_type eq "file_nn"){
    my $file_id_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "file_id"){
        $file_id_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $file_id_row) {
      print STDERR "No file_id in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my @errors;
      my($proj, $site, $subj, $study, $series, $sop, $version);

      my $row = $table->{rows}->[$i];
      my $file_id = $row->[$file_id_row];
      my $f_info = $file_info->{$file_id};
      my $digest = $f_info->{digest};
      my $sop_instance_uid = $f_info->{sop_instance_uid};
      my $series_instance_uid = $f_info->{series_instance_uid};
      my $study_instance_uid = $f_info->{study_instance_uid};
      if(exists $dig_info->{$digest}){
        $proj = $dig_info->{$digest}->{project_name};
        $site = $dig_info->{$digest}->{site_name};
        $subj = $dig_info->{$digest}->{subj_id};
        $sop = $dig_info->{$digest}->{sop_nickname};
        $version = $dig_info->{$digest}->{version};
      }
      my $sop_nn_info = $sop_info->{$sop_instance_uid};
      $sop =$sop_nn_info->{sop_nickname};
      unless(defined($proj)){
        $proj = $sop_nn_info->{project_name};
        $site = $sop_nn_info->{site_name};
        $subj = $sop_nn_info->{subj_id};
      }
      my $series_nn_info = $series_info->{$series_instance_uid};
      unless(defined($proj)){
        $proj = $series_nn_info->{project_name};
        $site = $series_nn_info->{site_name};
        $subj = $series_nn_info->{subj_id};
      }
      $series = $series_nn_info->{series_nickname};
      my $study_nn_info = $study_info->{$study_instance_uid};
      unless(defined($proj)){
        $proj = $study_nn_info->{project_name};
        $site = $study_nn_info->{site_name};
        $subj = $study_nn_info->{subj_id};
      }
      $study = $study_nn_info->{study_nickname};
      unless(defined $proj) { $proj = "<undef>" }
      unless(defined $site) { $site = "<undef>" }
      unless(defined $subj) { $subj = "<undef>" }
      unless(defined $study) { $study = "<undef>" }
      unless(defined $series) { $series = "<undef>" }
      unless(defined $sop) { $sop = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study//$series//$sop";
      if($version) { $row->{$nn_row} .= "[$version]" }
    }
  } elsif($nn_type eq "sop_nn"){
    my $sop_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "sop_instance_uid"){
        $sop_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $sop_instance_uid_row) {
      print STDERR "No sop_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $sop_instance_uid = $row->[$sop_instance_uid_row];
      my @errors;
      my($proj, $site, $subj, $study, $series, $sop);
      my $sop_nn_info;
      if(exists $sop_info->{$sop_instance_uid}){
        $sop_nn_info = $sop_info->{$sop_instance_uid};
      } else {
        print STDERR "no SOP nickname data for $sop_instance_uid\n";
        return;
      }
      my $study_instance_uid = $sop_nn_info->{study_instance_uid};
      my $series_instance_uid = $sop_nn_info->{series_instance_uid};
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $series_nn_info = $series_info->{$series_instance_uid};
      $proj = $study_nn_info->{project_name};
      $site = $study_nn_info->{site_name};
      $subj = $study_nn_info->{subj_id};
      my $study_nn = $study_nn_info->{study_nickname};
      my $series_nn = $series_nn_info->{series_nickname};
      my $sop_nn = $sop_nn_info->{sop_nickname};
      unless(defined $study_nn) { $study_nn = "&ltundef>" }
      unless(defined $series_nn) { $series_nn = "&ltundef>" }
      unless(defined $sop_nn) { $sop_nn = "&ltundef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study_nn//$series_nn//$sop_nn";
    }
  } elsif($nn_type eq "series_nn"){
    my $series_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "series_instance_uid"){
        $series_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $series_instance_uid_row) {
      print STDERR "No series_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $series_instance_uid = $row->[$series_instance_uid_row];
      my $series_nn_info = $series_info->{$series_instance_uid};
      my $study_instance_uid = $series_nn_info->{study_instance_uid};
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $proj = $series_nn_info->{project_name};
      my $site = $series_nn_info->{site_name};
      my $subj = $series_nn_info->{subj_id};
      my $study = $study_nn_info->{study_nickname};
      my $series = $series_nn_info->{series_nickname};
      unless(defined($proj)){ $proj = "<undef>" }
      unless(defined($site)){ $site = "<undef>" }
      unless(defined($subj)){ $subj = "<undef>" }
      unless(defined($study)){ $study = "<undef>" }
      unless(defined($series)){ $series = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study//$series";
    }
  } elsif($nn_type eq "study_nn"){
    my $study_instance_uid_row;
    my $nn_row;
    for my $i (0 .. $#{$columns}){
      if($columns->[$i] eq "study_instance_uid"){
        $study_instance_uid_row = $i;
      } elsif($columns->[$i] eq "nickname"){
        $nn_row = $i;
      }
    }
    unless(defined $study_instance_uid_row) {
      print STDERR "No study_instance_uid in this table\n";
      return;
    }
    unless(defined $nn_row){
      $nn_row = $#{$columns} + 1;
      $columns->[$#{$columns} + 1] = "nickname";
    }
    for my $i ($first_row .. $#{$table->{rows}}){
      my $row = $table->{rows}->[$i];
      my $study_instance_uid = $row->[$study_instance_uid_row];
      my $study_nn_info = $study_info->{$study_instance_uid};
      my $proj = $study_nn_info->{project_name};
      my $site = $study_nn_info->{site_name};
      my $subj = $study_nn_info->{subj_id};
      my $study = $study_nn_info->{study_nickname};
      unless(defined($proj)){ $proj = "<undef>" }
      unless(defined($site)){ $site = "<undef>" }
      unless(defined($subj)){ $subj = "<undef>" }
      unless(defined($study)){ $study = "<undef>" }
      $row->[$nn_row] = "$proj//$site//$subj//$study";
    }
  }
}
1;
