  -- Code for the primary ICD-9 diagnosis
SELECT
  final_2.hadm_id,
  primary_dx.icd9_code,
  primary_dx.short_title,
  primary_dx.long_title
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  public.primary_dx
ON
  public.final_2.hadm_id = public.primary_dx.hadm_id
ORDER BY
  hadm_id
