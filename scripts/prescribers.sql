1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY npi
ORDER BY total_claims DESC;

-- Answer: 1881634483, 99707
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
	
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description, nppes_provider_last_org_name, nppes_provider_first_name
ORDER BY total_claims DESC;

--Answer: Bruce Pendley, Fmaily Practice, 99707

2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
	
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber p1
LEFT JOIN prescription p2
ON p1.npi = p2.npi
GROUP BY specialty_description
ORDER BY COUNT (total_claim_count) DESC;

-- Answer: Nurse Practitioner, 7185315

--     b. Which specialty had the most total number of claims for opioids?
	
SELECT specialty_description, SUM(total_claim_count)
FROM prescription p2
LEFT JOIN prescriber p1
ON p1.npi = p2.npi
LEFT JOIN drug d
ON p2.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY COUNT (total_claim_count) DESC;

-- Answer: Nurse Practitioner, 900845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT drug_name, generic_name, total_drug_cost
FROM prescription 
LEFT JOIN drug 
USING (drug_name)
ORDER BY total_drug_cost DESC;

-- Answer: PIRFENIDONE, $2,829,174.30

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT drug_name, generic_name, total_day_supply, total_30_day_fill_count, total_drug_cost
FROM prescription p
LEFT JOIN drug d
USING (drug_name)
ORDER BY total_drug_cost DESC;

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither' END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname, cbsa;

-- Answer: 10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, SUM(population) 
FROM cbsa
INNER JOIN population
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY SUM(population) DESC;

--Answer: Largest: Nashville-Davidson-Murfreesboro-Franklin, TN, 1,830,410. Smallest: Morristown, TN, 116,352.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT c1.cbsaname, f1.county, SUM(p1.population) AS total_population
FROM cbsa AS c1
FULL JOIN population AS p1
USING (fipscounty)
FULL JOIN fips_county AS f1
USING (fipscounty)
WHERE c1.cbsa IS NULL 
	AND population IS NOT NULL
GROUP BY c1.cbsaname, f1.county
ORDER BY SUM(p1.population) DESC;

--Answer: Sevier, 95,523.

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, SUM(total_claim_count) AS total_claims
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, SUM(total_claim_count) AS total_claims
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y'
GROUP BY drug_name;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT drug_name, total_claim_count, CONCAT(nppes_provider_first_name,' ', nppes_provider_last_org_name)
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y';

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name, specialty_description,drug_name, nppes_provider_city
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE specialty_description IN ('Pain Management')
	AND nppes_provider_city ILIKE 'Nashville';

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT npi, drug_name, specialty_description,drug_name, nppes_provider_city
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber
USING (npi)
WHERE specialty_description IN ('Pain Management')
	AND nppes_provider_city ILIKE 'Nashville';
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.																		   