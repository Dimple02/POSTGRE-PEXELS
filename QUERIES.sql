CREATE TABLE patients (
    Patient_ID INT PRIMARY KEY,
    Admit_Date DATE NOT NULL,
    Discharge_Date DATE NOT NULL,
    Diagnosis VARCHAR(255) NOT NULL,
    Bed_Occupancy VARCHAR(50) CHECK (Bed_Occupancy IN ('ICU', 'General', 'Private')),
    Test VARCHAR(100),
    Doctor VARCHAR(100),
    Followup_Date DATE,
    Feedback DECIMAL(3,1) CHECK (Feedback BETWEEN 0 AND 5),
    Billing_Amount DECIMAL(10,2) NOT NULL,
    Health_Insurance_Amount DECIMAL(10,2)
);

SELECT * FROM patients;

--BASIC QUERIES

--List distinct diagnoses in the hospital

SELECT DISTINCT Diagnosis FROM patients;

--Count the total number of patients admitted

SELECT COUNT(*) AS Total_Patients FROM patients;

--Retrieve patients who were admitted to the ICU

SELECT * FROM patients WHERE Bed_Occupancy = 'ICU';

--List all patients along with their assigned doctor

SELECT Patient_ID, Doctor FROM patients;

--Intermediate Queries

Find the total revenue generated from patient billing

SELECT SUM("billing_amount") AS Total_Revenue FROM patients;

--Calculate the average billing amount per diagnosis

SELECT Diagnosis, AVG("billing_amount") AS Avg_Billing 
FROM patients 
GROUP BY Diagnosis;

-- Find the top 5 doctors with the highest number of patients

SELECT Doctor, COUNT(*) AS Patient_Count 
FROM patients 
GROUP BY Doctor 
ORDER BY Patient_Count DESC 
LIMIT 5;

--List the 3-most common medical test performed

SELECT Test, COUNT(*) AS Test_Count 
FROM patients 
GROUP BY Test 
ORDER BY Test_Count DESC 
LIMIT 3;

--Retrieve all patients who had a follow-up after their discharge

SELECT * FROM patients 
WHERE "followup_date" > "discharge_date"
LIMIT 10;

--ADVANCED QUERIES

--Calculate the average length of stay for patients

SELECT AVG("discharge_date" - "admit_date") AS Avg_Stay_Duration 
FROM patients;

--Identify the top 2 doctors who has generated the highest revenue

SELECT Doctor, SUM("billing_amount") AS Total_Revenue 
FROM patients 
GROUP BY Doctor 
ORDER BY Total_Revenue DESC 
LIMIT 2;

--Find the month with the highest number of admissions

SELECT EXTRACT(MONTH FROM "admit_date") AS Month, COUNT(*) AS Admissions 
FROM patients 
GROUP BY Month 
ORDER BY Admissions DESC 
LIMIT 2;

--Retrieve the top 3 diagnoses with the highest total billing

SELECT Diagnosis, SUM("billing_amount") AS Total_Billing 
FROM patients 
GROUP BY Diagnosis 
ORDER BY Total_Billing DESC 
LIMIT 3;

--Calculate the insurance coverage percentage for each patient

SELECT Patient_ID, 
       ("health_insurance_amount" / "billing_amount") * 100 AS Insurance_Coverage_Percentage 
FROM patients;

--Rank Doctors Based on Total Revenue Generated

SELECT Doctor, 
       SUM("billing_amount") AS Total_Revenue, 
       RANK() OVER (ORDER BY SUM("billing_amount") DESC) AS Revenue_Rank
FROM patients
GROUP BY Doctor
ORDER BY Revenue_Rank;

--Calculate the Readmission Rate of Patients

WITH Readmissions AS (
    SELECT Patient_ID, COUNT(*) AS admission_count 
    FROM patients 
    GROUP BY Patient_ID 
    HAVING COUNT(*) > 1
)
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients)) AS Readmission_Rate 
FROM Readmissions;

--Find the 3-Most Profitable Diagnosis for the Hospital

SELECT Diagnosis, 
       SUM("billing_amount") AS Total_Revenue
FROM patients
GROUP BY Diagnosis
ORDER BY Total_Revenue DESC
LIMIT 3;

--Compare Insurance Coverage Across Different Diagnoses

SELECT Diagnosis, 
       AVG("health_insurance_amount" / NULLIF("billing_amount", 0) * 100) AS Avg_Coverage_Percentage
FROM patients
GROUP BY Diagnosis
ORDER BY Avg_Coverage_Percentage DESC;

--Determine Patient Flow Over Time (Rolling Admissions Count)

SELECT "admit_date", 
       COUNT(*) OVER (ORDER BY "admit_date" ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling_Weekly_Admissions
FROM patients;

--Identify Seasonal Trends in Patient Admissions

SELECT EXTRACT(MONTH FROM "admit_date") AS Month, COUNT(*) AS Total_Admissions
FROM patients
GROUP BY Month
ORDER BY Total_Admissions DESC;

--Find Revenue Growth Over Time

SELECT DATE_TRUNC('month', "admit_date") AS Month, 
       SUM("billing_amount") AS Monthly_Revenue,
       LAG(SUM("billing_amount")) OVER (ORDER BY DATE_TRUNC('month', "admit_date")) AS Previous_Month_Revenue,
       (SUM("billing_amount") - LAG(SUM("billing_amount")) OVER (ORDER BY DATE_TRUNC('month', "admit_date"))) AS Revenue_Growth
FROM patients
GROUP BY Month
ORDER BY Month;

--List Patients Who Had the Longest Hospital Stay

SELECT Patient_ID, "admit_date", "discharge_date", 
       ("discharge_date" - "admit_date") AS Stay_Duration
FROM patients
ORDER BY Stay_Duration DESC
LIMIT 5;

--Calculate Average Recovery Time by Diagnosis

SELECT Diagnosis, 
       AVG("discharge_date" - "admit_date") AS Avg_Recovery_Days
FROM patients
GROUP BY Diagnosis
ORDER BY Avg_Recovery_Days;

--Identify Patients with Unusually High Billing Amounts (Outliers)

SELECT * FROM patients 
WHERE "billing_amount" > (SELECT AVG("billing_amount") + 2 * STDDEV("billing_amount") FROM patients);


