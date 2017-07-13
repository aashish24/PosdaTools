-- Name: TagUsage
-- Schema: posda_phi
-- Columns: ['element_signature', 'equipment_signature']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: Which equipment signatures for which tags
-- 

select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ?
order by element_signature;
