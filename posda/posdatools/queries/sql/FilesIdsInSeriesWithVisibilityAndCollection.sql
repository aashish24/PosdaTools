-- Name: FilesIdsInSeriesWithVisibilityAndCollection
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'visibility']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'find_files', 'used_in_simple_phi']
-- Description: Get files in a series from posda database
-- 

select
  file_id, project_name as collection, visibility
from
  ctp_file
  natural join file_series
where
  series_instance_uid = ?
