-- Name: GetSeriesSignature
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'signature', 'num_series', 'num_files']
-- Args: ['collection']
-- Tags: ['signature']
-- Description: Get a list of Series Signatures by Collection
-- 

select distinct
  dicom_file_type, modality|| ':' || coalesce(manufacturer, '<undef>') || ':' 
  || coalesce(manuf_model_name, '<undef>') ||
  ':' || coalesce(software_versions, '<undef>') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file
where project_name = ?
group by dicom_file_type, signature
