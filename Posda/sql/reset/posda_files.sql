truncate table adverse_file_event;
truncate table association;
truncate table association_errors;
truncate table association_file;
truncate table association_import;
truncate table association_pc;
truncate table association_pc_proposed_ts;
truncate table beam_applicator;
truncate table beam_block;
truncate table beam_bolus;
truncate table beam_compensator;
truncate table beam_control_point;
truncate table beam_general_accessory;
truncate table beam_limiting_device;
truncate table beam_wedge;
truncate table contour_image;
truncate table control_point_bld_position;
truncate table control_point_dose_reference;
truncate table control_point_reference_dose;
truncate table control_point_wedge_position;
truncate table ctp_file;
truncate table ctp_filex;
truncate table ctp_upload_event;
truncate table dicom_dir;
truncate table dicom_dir_rec;
truncate table dicom_edit_event;
truncate table dicom_edit_event_adverse_file_event;
truncate table dicom_file;
truncate table dicom_file_edit;
truncate table dicom_file_errors;
truncate table dicom_file_send;
truncate table dicom_icon_image;
truncate table dicom_image_dir_rec;
truncate table dicom_patient_dir_rec;
truncate table dicom_process_errors;
truncate table dicom_rt_dose_dir_rec;
truncate table dicom_rt_plan_dir_rec;
truncate table dicom_rt_structure_set_dir_rec;
truncate table dicom_rt_treatment_rec_dir_rec;
truncate table dicom_send_event;
truncate table dicom_series_dir_rec;
truncate table dicom_study_dir_rec;
truncate table distinguished_pixel_digest_pixel_value;
truncate table distinguished_pixel_digests;
truncate table dose_referenced_from_beam;
truncate table dose_referenced_from_plan;
truncate table file;
truncate table file_ct_image;
truncate table file_dose;
truncate table file_ele_ref;
truncate table file_ele_ref_text_value;
truncate table file_equipment;
truncate table file_for;
truncate table file_image;
truncate table file_image_geometry;
truncate table file_import;
truncate table file_import_series;
truncate table file_import_study;
truncate table file_location;
truncate table file_locationx;
truncate table file_meta;
truncate table file_patient;
truncate table file_plan;
truncate table file_roi_image_linkage;
truncate table file_series;
truncate table file_slope_intercept;
truncate table file_sop_common;
truncate table file_structure_set;
truncate table file_study;
truncate table file_visibility_change;
truncate table file_win_lev;
truncate table for_registration;
truncate table fraction_reference_beam;
truncate table fraction_reference_brachy;
truncate table fraction_reference_dose;
truncate table fraction_related_dose;
truncate table image;
truncate table image_equivalence_class;
truncate table image_equivalence_class_input_image;
truncate table image_equivalence_class_out_image;
truncate table image_frame_offset;
truncate table image_geometry;
truncate table image_referenced_from_beam;
truncate table image_slope_intercept;
truncate table image_window_level;
truncate table import_ct_series;
truncate table import_event;
truncate table missing_files;
truncate table missing_from_db;
truncate table missing_from_fs;
truncate table patient_import_status;
truncate table patient_import_status_change;
truncate table pixel_location;
truncate table plan;
truncate table plan_related_plans;
truncate table planned_verification_images;
truncate table related_roi_observations;
truncate table roi;
truncate table roi_contour;
truncate table roi_elemental_composition;
truncate table roi_observation;
truncate table roi_physical_properties;
truncate table roi_related_roi;
truncate table rt_beam;
truncate table rt_beam_limit_dev_tolerance;
truncate table rt_beam_tolerance_table;
truncate table rt_dose;
truncate table rt_dose_gfov;
truncate table rt_dose_image;
truncate table rt_dose_ref_beam;
truncate table rt_dose_ref_brachy;
truncate table rt_dvh;
truncate table rt_dvh_available_rois;
truncate table rt_dvh_dvh;
truncate table rt_dvh_dvh_data;
truncate table rt_dvh_dvh_dose_bins;
truncate table rt_dvh_dvh_roi;
truncate table rt_dvh_protocol_case_roi;
truncate table rt_dvh_rt_dose;
truncate table rt_plan_fraction_group;
truncate table rt_plan_patient_setup;
truncate table rt_plan_respiratory_motion_comp;
truncate table rt_plan_setup_device;
truncate table rt_plan_setup_fixation_device;
truncate table rt_plan_setup_image;
truncate table rt_plan_setup_shielding_device;
truncate table rt_prescription;
truncate table rt_prescription_dose_ref;
truncate table slope_intercept;
truncate table ss_for;
truncate table ss_volume;
truncate table structure_set;
truncate table submission;
truncate table unique_pixel_data;
truncate table window_level;
truncate table log_iec_hide;
