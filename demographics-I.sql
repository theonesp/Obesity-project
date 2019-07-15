  -- code for:age,gender, ethinicty, marital status, insurance coverage, LOS hospital, LOS ICU, admission type, ICU type
WITH
  t1 AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id
    -- patient level factors
    ,
    pat.gender
    -- hospital level factors
    ,
    adm.admittime,
    adm.dischtime,
    adm.insurance,
    adm.religion,
    adm.marital_status,
    adm.diagnosis,
    ROUND( (CAST(adm.dischtime AS DATE) - CAST(adm.admittime AS DATE)), 4) AS los_hospital,
    ROUND( (CAST(adm.admittime AS DATE) - CAST(pat.dob AS DATE)) / 365.242, 4) AS age,
    adm.ethnicity,
    adm.ADMISSION_TYPE,
    adm.hospital_expire_flag,
    DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq,
    CASE
      WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN 'Y'
    ELSE
    'N'
  END
    AS first_hosp_stay
    -- icu level factors
    ,
    ie.intime,
    ie.outtime,
    ROUND( (CAST(ie.outtime AS DATE) - CAST(ie.intime AS DATE)), 4) AS los_icu,
    DENSE_RANK() OVER (
    PARTITION BY
      ie.hadm_id
    ORDER BY
      ie
