#!/usr/bin/perl -w
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=posda_files", "", "");
my $q = <<EOF;
select
  distinct modality, body_part_examined, series_description,
  series_date, patient_name, patient_id, sex, series_instance_uid,
  study_instance_uid, study_date, study_description, accession_number,
  count(*)
from
  ctp_file natural join file_patient natural join
  file_series natural join file_study
where
  project_name = ? and site_name = ?
group by
  modality, body_part_examined, series_description,
  series_date, patient_name, patient_id, sex, series_instance_uid,
  study_instance_uid, study_date, study_description, accession_number
order by
  study_instance_uid, series_instance_uid
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[0], $ARGV[1]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  my $body_part = "<undef>";
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  my $desc = "<undef>";
  my $t_desc = "<undef>";
  my $pname = "<undef>";
  my $acces = "<undef>";
  my $ser_date = "<undef>";
  my $st_date = "<undef>";
  my $sex = "<undef>";
  if(defined $i->{series_description}) {$desc = $i->{series_description}}
  if(defined $i->{study_description}) {$t_desc = $i->{study_description}}
  if(defined $i->{patient_name}) {$pname = $i->{patient_name}}
  if(defined $i->{sex}) {$sex = $i->{sex}}
  if(defined $i->{accession_number}) {$acces = $i->{accession_number}}
  if(defined $i->{series_date}) {$ser_date = $i->{series_date}}
  if(defined $i->{study_date}) {$st_date = $i->{study_date}}
  print("$i->{patient_id}|$pname|$i->{study_instance_uid}|$st_date|$t_desc|" .
    "$i->{series_instance_uid}|$ser_date|$desc|$i->{modality}|$sex|$acces\n");
}

