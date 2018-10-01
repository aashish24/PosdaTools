-- Name: DistinctSeriesByPatientId
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'dicom_file_type', 'count']
-- Args: ['patient_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select distinct 
  project_name as collection, site_name as site, patient_id, study_instance_uid,
  series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_study natural join file_series natural join
  file_patient natural join
  dicom_file natural join ctp_file
where
  patient_id = ? and visibility is null
group by 
  collection, site, patient_id, study_instance_uid,
  series_instance_uid, dicom_file_type, modality
