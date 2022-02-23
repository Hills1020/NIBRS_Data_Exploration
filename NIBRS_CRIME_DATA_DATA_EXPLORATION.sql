-- Percent of offenses completed and offenses attempted compared to the total amount of offenses overall
SELECT offense_category, total_offenses,num_offense_comp, num_offense_attemp,
ROUND(Num_Offense_Comp / Total_Offenses, 4) * 100 AS Percent_Offense_Comp,
ROUND(Num_Offense_Attemp / Total_Offenses, 4) * 100 AS Percent_Offense_Attemp
FROM Completed_Table
WHERE offense_category != 'Crimes Against Persons'
	AND offense_category != 'Crimes Against Property'
	AND offense_category != 'Crimes Against Society'
	AND offense_category != 'Total'
ORDER BY Percent_Offense_Comp DESC


-- This looks at what the percentage of a specific crime group is compared to the sum of all crime groups.
SELECT Offense_Category, Total_Offenses, ROUND(total_offenses / 8879728, 4) * 100 as percent_of_crime
FROM Completed_Table
WHERE offense_category != 'Crimes Against Persons'
	AND offense_category != 'Crimes Against Property'
	AND offense_category != 'Crimes Against Society'
	AND offense_category != 'Total'
ORDER BY 3 DESC

-- This table is taking the percent of each crime group within the overall crimes against persons category
-- compared to the overall "crimes against persons", for each state
SELECT state,
state_population,
total_offenses,
ROUND(assault / total_offenses, 4) * 100 AS assault_percent, 
ROUND(homicide / total_offenses, 4) * 100 AS homicide_percent,
ROUND(human_traficking / total_offenses, 4) * 100 AS traficking_percent,
ROUND(kidnappingabduction / total_offenses, 4) * 100 AS kidnap_abduct_percent,
ROUND(sex_offenses / total_offenses, 4) * 100 AS sex_offense_percent
FROM cap_states
ORDER BY sex_offense_percent DESC

-- Percent of all crime per age group, compared to the total number of offenses within
-- the specified crime grouping
SELECT offense_category, total_offense,
SUM(Percent_10_under) As sum_under_10,
SUM(Percent_11_15) As sum_11_15,
SUM(Percent_16_20) As sum_16_20,
SUM(Percent_21_25) As sum_21_25,
SUM(Percent_26_30) As sum_26_30,
SUM(Percent_31_35) As sum_31_35,
SUM(Percent_36_40) As sum_36_40,
SUM(Percent_41_45) As sum_41_45,
SUM(Percent_46_50) As sum_46_50,
SUM(Percent_51_55) As sum_51_55,
SUM(Percent_56_60) As sum_56_60,
SUM(Percent_61_65) As sum_61_65,
SUM(Percent_66_over) As sum_66_over,
SUM(Percent_Unknown_Age) AS sum_unknown
FROM
	(SELECT offense_category, 
	total_offense,
	Round("10_and_under" / total_offense,4) * 100 AS Percent_10_under,
	ROUND("11-15" / total_offense,4) * 100 AS Percent_11_15,
	ROUND("16-20" / total_offense,4) * 100 AS Percent_16_20,
	ROUND("21-25" / total_offense,4) * 100 AS Percent_21_25,
	ROUND("26-30" / total_offense,4) * 100 AS Percent_26_30,
	ROUND("31-35" / total_offense,4) * 100 AS Percent_31_35,
	ROUND("36-40" / total_offense,4) * 100 AS Percent_36_40,
	ROUND("41-45" / total_offense,4) * 100 AS Percent_41_45,
	ROUND("46-50" / total_offense,4) * 100 AS Percent_46_50,
	ROUND("51-55" / total_offense,4) * 100 AS Percent_51_55,
	ROUND("56-60" / total_offense,4) * 100 AS Percent_56_60,
	ROUND("61-65" / total_offense,4) * 100 AS Percent_61_65,
	ROUND("66_and_over" / total_offense,4) * 100 AS Percent_66_over,
	ROUND(unknown_age / total_offense,4) * 100 as Percent_Unknown_Age
	FROM offender_age
	WHERE Offense_Category NOT LIKE 'Crimes Against%')
AS sum_crime_age_group
GROUP BY total_offense, offense_category

-- Combined crime category tables for offenses in each state
SELECT ca_prop_states.state, ca_prop_states.state_population,
(CAP_States.Total_Offenses + ca_prop_states.total_offenses + cas_states.total_offenses) AS total_offenses,
Assault, Homicide, Human_Traficking, KidnappingAbduction, Sex_Offenses,
arson, bribery, BurglaryBreakingEntering, 
CounterfeitingForgery, DestructionDamageVandalisim, Embezzlement,
ExtortitionBlackmail, Fraud, LarcenyTheft, MotorVehicleTheft,
Robbery, StolenProperty,
animalcruelty, drugoffenses, gamblingoffenses,
pornographyoffenses, prostitutionoffenses, weaponviolations
FROM ca_prop_states 
LEFT JOIN CAP_States 
ON CAP_States.id = ca_prop_states .id
LEFT JOIN cas_states 
ON cas_states.id = CAP_States.id
WHERE ca_prop_states.state NOT LIKE 'district%'

-- Percent of crime by crime category, for each state, compared to total amount of crime per state
SELECT state, state_population, total_offenses,
offenses_against_persons, ROUND(offenses_against_persons/total_offenses, 4) * 100 AS persons_percent,
offenses_against_property, ROUND(offenses_against_property/total_offenses, 4) * 100 as property_percent,
offenses_against_society, ROUND(offenses_against_society/total_offenses, 4) * 100 AS society_percent
FROM
	(SELECT ca_prop_states.state, ca_prop_states.state_population,
	(CAP_States.Total_Offenses + ca_prop_states.total_offenses + cas_states.total_offenses) AS total_offenses,
	(Assault + Homicide + Human_Traficking + KidnappingAbduction + Sex_Offenses) AS offenses_against_persons,
	(arson + bribery + BurglaryBreakingEntering + 
	CounterfeitingForgery + DestructionDamageVandalisim + Embezzlement +
	ExtortitionBlackmail + Fraud + LarcenyTheft + MotorVehicleTheft +
	Robbery + StolenProperty) AS offenses_against_property,
	(animalcruelty + drugoffenses + gamblingoffenses +
	pornographyoffenses + prostitutionoffenses + weaponviolations) AS offenses_against_society
	FROM ca_prop_states 
	LEFT JOIN CAP_States 
	ON CAP_States.id = ca_prop_states .id
	LEFT JOIN cas_states 
	ON cas_states.id = CAP_States.id
	WHERE ca_prop_states.state NOT LIKE 'district%') 
AS crime_groupings_table
