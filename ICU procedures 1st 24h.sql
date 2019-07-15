  -- code for mechanical ventilation in the first 24h of ICU
SELECT
  final_2.icustay_id,
  ventfirstday.mechvent AS MV_1stday
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  ventfirstday
ON
  final_2.icustay_id = ventfirstday.icustay_id
ORDER BY
  icustay_id
  -- code for pressors in the first 24h of ICU
WITH
  t2 AS (
  WITH
    t1 AS (
    SELECT
      DISTINCT vasopressordurations.icustay_id,
      (vasopressordurations.starttime) AS starttime,
      rank () OVER (PARTITION BY vasopressordurations.icustay_id ORDER BY starttime) AS pressor_order,
      CASE
        WHEN starttime >= icustays.intime - INTERVAL '1' day AND starttime <= icustays.intime + INTERVAL '1' day THEN 1
      ELSE
      0
    END
      AS pressor_1stday,
      icustays.intime
    FROM
      public.vasopressordurations,
      mimiciii.icustays
    WHERE
      vasopressordurations.icustay_id = icustays.icustay_id
    GROUP BY
      vasopressordurations.icustay_id,
      icustays.intime,
      starttime
    ORDER BY
      vasopressordurations.icustay_id )
  SELECT
    icustay_id,
    pressor_1stday,
    pressor_order
  FROM
    t1
  WHERE
    pressor_order =1 )
SELECT
  public.final_2.icustay_id,
  t2.pressor_1stday
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  t2
ON
  public.final_2.icustay_id=t2.icustay_id
ORDER BY
  icustay_id
  -- code for renal replacement therapy in the first 24h of ICU
SELECT
  final_2.icustay_id,
  rrtfirstday.rrt AS RRT_1stday
FROM
  public.final_2 -- replace by the table name created by you in the cohort selection
LEFT JOIN
  rrtfirstday
ON
  final_2.icustay_id = rrtfirstday.icustay_id
ORDER BY
  icustay_id
