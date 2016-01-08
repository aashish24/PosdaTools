#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/GetCollectionId.pl,v $ #$Date: 2015/12/15 14:10:58 $
#$Revision: 1.1 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select
  distinct project_name, site_name, count(*)
from
  ctp_file
where
  visibility is null
group by project_name, site_name
order by project_name, site_name
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute();
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  print "$i->{project_name}|$i->{site_name}|$i->{count}\n";
}

