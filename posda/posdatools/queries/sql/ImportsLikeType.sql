-- Name: ImportsLikeType
-- Schema: posda_files
-- Columns: ['import_type', 'import_comment', 'import_time', 'total_files']
-- Args: ['from', 'to', 'type_like']
-- Tags: ['downloads_by_date', 'import_events']
-- Description: Counts query by Collection, Site
-- 

select
  distinct import_type, import_comment, import_time,
  sum(num_files) as total_files
from (
  select * from (
    select
      distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id) as num_files 
    from
      import_event natural join file_import
    where import_time > ? and import_time < ?
    group by import_event_id, import_time, import_type, import_comment order by import_time desc
  ) as foo
  where num_files > 1 and import_type like ?
) as foo
group by import_type, import_time, import_comment