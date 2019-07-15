  -- Cohort creation
  -- Our cohort: 1st ICU admission of patients >16 years old, with height, weight and laboratory results at least 3 days and at most 1 year befre the hospital admission
  -- create table public.XXXX . as -- use this command to crete a public table
WITH
  t1 AS (
  SELECT
    adm.subject_id,
    adm.hadm_id,
    adm.admittime,
    RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hadm_id_order,
    EXTRACT('epoch'
    FROM
      adm.admittime - pat.dob) / 60.0 / 60.0 / 24.0 / 365.242 AS age
  FROM
    mimiciii.admissions adm,
    mimiciii.patients pat
  WHERE
    adm.subject_id = pat.subject_id
  ORDER BY
    subject_id ),
  t2 AS -- first hospital admission
  (
  SELECT
    subject_id,
    hadm_id,
    EXTRACT (epoch
    FROM
      admittime) AS admittime,
    age
  FROM
    t1
  WHERE
    hadm_id_order = 1 ),
  t3_lab AS -- all lab values (hemoglobin, white blood cells, platelets, sodium, potasium, creatinine, BUN, bicarbonate, glucose and bilirubin)
  (
  SELECT
    DISTINCT subject_id,
    hadm_id,
    EXTRACT(epoch
    FROM
      charttime) AS charttime -- , valuenum
  FROM
    mimiciii.labevents
  WHERE
    itemid IN (50912,
      50811,
      51222,
      51300,
      51301,
      51265,
      50983,
      50824,
      50971,
      50822,
      51006,
      51081,
      50882,
      50803,
      50902,
      50806,
      50809,
      50931,
      50960,
      50808)
    AND hadm_id IS NULL
  ORDER BY
    subject_id,
    charttime ),
  adultswithlabs AS (
    -- combining inclusion criteria
  SELECT
    DISTINCT t2.subject_id,
    t2.hadm_id
  FROM
    t2,
    t3_lab AS t3
  WHERE
    t2.age >= 16
    AND t3.charttime BETWEEN t2.admittime-365.25*24*3600
    AND t2.admittime-3*24*3600
    AND t3.subject_id=t2.subject_id
  ORDER BY
    t2.hadm_id ),
  t3_wt AS -- weight
  (
  SELECT
    DISTINCT subject_id,
    icustay_id,
    EXTRACT(epoch
    FROM
      charttime) AS charttime,
    valuenum AS weight
  FROM
    mimiciii.chartevents
  WHERE
    valuenum IS NOT NULL
    AND itemid IN (581,
      580,
      224639,
      226512)
  ORDER BY
    icustay_id,
    charttime ),
  t1_icu AS (
  SELECT
    icu.*,
    RANK() OVER (PARTITION BY icu.subject_id ORDER BY icu.intime) AS icustay_id_order
  FROM
    mimiciii.icustays icu
  ORDER BY
    subject_id ),
  t2_icu AS -- 1st icu stay
  (
  SELECT
    subject_id,
    hadm_id,
    icustay_id,
    EXTRACT ( epoch
    FROM
      intime) AS intime
  FROM
    t1_icu
  WHERE
    icustay_id_order = 1 ),
  mean_weight AS -- mean weight between 24h before and 24 after the ICu admission
  (
  SELECT
    DISTINCT t3.subject_id,
    AVG(t3.weight) AS mean_weight
  FROM
    t2_icu AS t2,
    t3_wt AS t3
  WHERE
    t3.charttime BETWEEN t2.intime-01*24*3600
    AND t2.intime+1*24*3600
    AND t3.subject_id=t2.subject_id  -- select weight within -1d / +1d from ICU admission
  GROUP BY
    t3.subject_id
  ORDER BY
    t3.subject_id ),
  t0 AS -- height
  (
  SELECT
    DISTINCT subject_id,
    EXTRACT(epoch
    FROM
      charttime) AS charttime,
    itemid,
    CASE
      WHEN itemid IN (920, 1394, 4187, 3486, 226707) THEN valuenum *2.54
    ELSE
    valuenum
  END
    AS height  -- with conversion inches/cm
  FROM
    mimiciii.chartevents
  WHERE
    valuenum IS NOT NULL
    AND itemid IN ( 920,
      1394,
      4187,
      3486,
      3485,
      4188,
      226707,
      226730)
    AND valuenum != 0 )
  -- select max available height per subject_id
  ,
  max_height AS (
  SELECT
    DISTINCT subject_id,
    MAX(height) AS height
  FROM
    t0
  GROUP BY
    subject_id ),
  tempo AS -- transforming inches in cm
  (
  SELECT
    ad.subject_id,
    ad.hadm_id,
    icu.icustay_id,
    mw.mean_weight,
    CASE
      WHEN mh.height < 100 THEN mh.height *2.54
      WHEN mh.height>300 THEN mh.height/2.54
    ELSE
    mh.height
  END
    AS height
  FROM
    adultswithlabs ad
  LEFT JOIN
    mean_weight mw
  ON
    ad.subject_id=mw.subject_id
  LEFT JOIN
    max_height mh
  ON
    ad.subject_id=mh.subject_id
  LEFT JOIN
    t2_icu icu
  ON
    ad.hadm_id = icu.hadm_id
  ORDER BY
    ad.subject_id ),
  tempo2 AS -- calculating BMI
  (
  SELECT
    tempo.*,
    mean_weight/(height*height/10000) AS bmi
  FROM
    tempo
  WHERE
    mean_weight IS NOT NULL
    AND height IS NOT NULL ),
  tempo3 AS -- defining BMI groups
  (
  SELECT
    tempo2.*,
    CASE
      WHEN bmi < 18.5 THEN 1
      WHEN bmi >= 18.5
    AND bmi < 24.999999999 THEN 2
      WHEN bmi >= 25 AND bmi < 30 THEN 3
      WHEN bmi >= 30 THEN 4
    ELSE
    0
  END
    AS bmi_group
  FROM
    tempo2 )
SELECT
  * -- selecting final cohort
FROM
  tempo3
WHERE
  icustay_id IS NOT NULL
  AND bmi_group =2 -- (normal weight cohort) or bmi_group=4 (obese cohort)
