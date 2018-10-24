-- Name: DuplicatePixelDataThatMatters
-- Schema: posda_files
-- Columns: ['image_id', 'count']
-- Args: ['collection']
-- Tags: ['pixel_duplicates']
-- Description: Return a list of files with duplicate pixel data,
-- restricted to those files which have parsed DICOM data
-- representations in Database.
-- 

select image_id, count from (
  select distinct image_id, count(*)
  from (
    select distinct image_id, file_id
    from (
      select
        file_id, image_id, patient_id, study_instance_uid, 
        series_instance_uid, sop_instance_uid, modality
      from
        file_patient natural join file_series natural join 
        file_study natural join file_sop_common
        natural join file_image
      where file_id in (
        select file_id
        from (
          select image_id, file_id 
          from file_image 
          where image_id in (
            select image_id
            from (
              select distinct image_id, count(*)
              from (
                select distinct image_id, file_id
                from file_image where file_id in (
                  select distinct file_id
                  from ctp_file
                  where project_name = ? and visibility is null
                )
              ) as foo
              group by image_id
            ) as foo 
            where count > 1
          )
        ) as foo
      )
    ) as foo
  ) as foo
  group by image_id
) as foo 
where count > 1;
