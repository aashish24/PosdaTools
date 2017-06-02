package Posda::QueryLog;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config 'Database';
use DBI;
use Data::Dumper;

our $connection;

func connect_to_db() {
  if (not defined $connection) {
    $connection = DBI->connect(Database('posda_queries'));
  }
}

# Record a query_invoked event, returning an ID that can be used later
# to record it being finalized
func query_invoked($query, $user) {
  connect_to_db();
  my $start_time = time;

  my $res = $connection->selectrow_arrayref(qq{
    insert into query_invoked_by_dbif
    (query_name, invoking_user, query_start_time)
    values (?, ?, to_timestamp(?))
    returning query_invoked_by_dbif_id
  }, {}, $query->{name}, $user, $start_time);

  my $invoked_id = $res->[0];

  for my $i (0..$#{$query->{args}}) {
    insert_query_args($invoked_id, $i, $query->{args}->[$i], $query->{bindings}->[$i]);
  }

  return $invoked_id;
}

func query_finished($invoked_id, $rowcount) {
  connect_to_db();
  $connection->do(qq{
    update query_invoked_by_dbif
    set query_end_time = to_timestamp(?),
        number_of_rows = ?
    where query_invoked_by_dbif_id = ?
  }, {}, time, $rowcount, $invoked_id);
}

func insert_query_args($invoked_by_id, $index, $name, $value) {
  $connection->do("insert into dbif_query_args values (?, ?, ?, ?)", {},
    $invoked_by_id, $index, $name, $value);
}

1;
