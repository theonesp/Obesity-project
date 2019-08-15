# Obesity-project
Description of the obesity project done with MIMIC-III database on March 2017.

You can find the manuscript now available on [Severity of Illness Scores May Misclassify Critically Ill Obese Patients.](https://insights.ovid.com/pubmed?pmid=29194147)

Study question:
"to compare the deviation of laboratory results utilized in scoring systems from baseline to ICU admission in both obese and normal weight patients, adjusted for the severity of score illness (SAPS-II or SOFA)"

Step by step:
1. Cohort creation - note you need to create a new table with a specific name for each cohort (normal weight and obese).
2. Demographics I and II
3. Primary ICD9
4. ICU procedures in the first 24h
5. ICU severity of illness score
6. Baseline lab results
7. 1st24hICU_labresults
8. Statistical analyses code (R)

