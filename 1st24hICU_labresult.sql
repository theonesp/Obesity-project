  -- code for the most abnormal lab result in the first 24h of the ICU admission
SELECT
  final_2.icustay_id,
  labsfirstday.wbc_max AS wbc_icu,
  labsfirstday.platelet_min AS platelet_icu,
  labsfirstday.sodium_min AS Na_icu,
  labsfirstday.potassium_max AS k_icu,
  labsfirstday.bun_max AS BUN_icu,
  labsfirstday.creatinine_max AS Cr_icu,
  labsfirstday.bicarbonate_min AS BIC_icu
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  labsfirstday
ON
  final_2.icustay_id = labsfirstday.icustay_id
ORDER BY
  icustay_id
