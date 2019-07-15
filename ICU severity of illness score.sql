  -- code for SAPS-II
SELECT
  final_2.icustay_id,
  sapsii.sapsii
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  sapsii
ON
  final_2.icustay_id = sapsii.icustay_id
ORDER BY
  icustay_id
  --code for SOFA
SELECT
  final_2.icustay_id,
  sofa.sofa AS sofa_score,
  sofa.respiration,
  sofa.coagulation,
  sofa.liver,
  sofa.cardiovascular,
  sofa.cns,
  sofa.renal
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  sapsii
LEFT JOIN
  sofa
ON
  final_2.icustay_id = sofa.icustay_id
ORDER BY
  icustay_id
