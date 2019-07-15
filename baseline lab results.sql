  -- code for the baseline laboratory result
SELECT
  co.icustay_id,
  AVG(CASE
      WHEN itemid IN (51300, 51301) THEN valuenum
    ELSE
    NULL
  END
    ) AS avgwbc_baseline,
  AVG(CASE
      WHEN itemid = 51265 THEN valuenum
    ELSE
    NULL
  END
    ) AS avgplatelets_baseline,
  avg (CASE
      WHEN itemid IN (50983, 50824) THEN valuenum
    ELSE
    NULL
  END
    ) AS avgsodium_baseline,
  avg (CASE
      WHEN itemid IN (50971, 50822) THEN valuenum
    ELSE
    NULL
  END
    ) AS avgpotassium_baseline,
  avg (CASE
      WHEN itemid = 51006 THEN valuenum
    ELSE
    NULL
  END
    ) AS avgbun_baseline,
  avg (CASE
      WHEN itemid IN (50912, 51081) THEN valuenum
    ELSE
    NULL
  END
    ) AS avgcreatinine_baseline,
  avg (CASE
      WHEN itemid IN (50882, 50803) THEN valuenum
    ELSE
    NULL
  END
    ) AS avgbic_baseline
FROM
  final_2 co -- replace by the table name created by you in the cohort selection
INNER JOIN
  admissions adm
ON
  co.hadm_id = adm.hadm_id
LEFT JOIN
  labevents le
ON
  co.subject_id = le.subject_id
  AND le.charttime BETWEEN adm.admittime - INTERVAL '365' day
  AND adm.admittime - INTERVAL '3' day
GROUP BY
  co.subject_id,
  co.hadm_id,
  co.icustay_id,
  adm.admittime
ORDER BY
  icustay_id
