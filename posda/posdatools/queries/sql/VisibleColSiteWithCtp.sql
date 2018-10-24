-- Name: VisibleColSiteWithCtp
-- Schema: posda_files
-- Columns: ['collection', 'site', 'num_series', 'num_files']
-- Args: []
-- Tags: ['adding_ctp', 'find_patients', 'series_selection', 'ctp_col_site', 'select_for_phi']
-- Description: Get List of visible patients with CTP data

select
  distinct project_name as collection, site_name as site,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files,
  min(import_time) as first_import,
  max(import_time) as last_import
from
  file_series
  natural join file_import natural join import_event
  natural join ctp_file
where
  visibility is null
group by collection, site