-- Name: GetDciodvfyUnitScanErrorId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_scan_instance row

select currval('dciodvfy_unit_scan_error_dciodvfy_unit_scan_error_id_seq') as id