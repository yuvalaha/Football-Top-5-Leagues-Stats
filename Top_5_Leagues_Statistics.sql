USE Football_Top_5_Leagues

ALTER TABLE Players_Stats
ALTER COLUMN Gls INT

ALTER TABLE Players_Stats
ALTER COLUMN Ast INT

ALTER TABLE Players_Stats
ALTER COLUMN xG FLOAT

ALTER TABLE Players_Stats
ALTER COLUMN MIN INT

ALTER TABLE Players_Stats
ALTER COLUMN Prgp INT

ALTER TABLE Players_Stats
ALTER COLUMN Prgc INT

ALTER TABLE Players_Stats
ALTER COLUMN PrgR INT

ALTER TABLE Players_Stats
ALTER COLUMN Gls_90 FLOAT

ALTER TABLE Players_Stats
ALTER COLUMN G_A_90 FLOAT

-- All Data
SELECT * 
FROM Players_Stats

-- Which teams appear in the table
SELECT DISTINCT squad
FROM Players_Stats
ORDER BY Squad

-- All Data With Club City Name
SELECT  PS.*,
		TI.City
FROM Players_Stats PS
JOIN Team_Info TI
ON PS.Squad = TI.Squad

-- How many players are there in each team
SELECT  squad,
		COUNT(*) AS Number_Of_Players
FROM Players_Stats
GROUP BY Squad
ORDER BY Squad

-- What is the average age of players in each team
SELECT  Squad,
		AVG(Age) AS Average_Age
FROM Players_Stats
GROUP BY Squad
ORDER BY Average_Age DESC

-- Which players have scored more than 5 goals
SELECT  Player,
		Squad,
		Gls
FROM Players_Stats
WHERE Gls > 5 

-- Who are the top 10 players with the most goals + assists
SELECT TOP 10 squad,
		player,
		Gls,
		Ast,
		Ast + Gls AS Goals_And_Asists
FROM Players_Stats
WHERE Ast + Gls > 10
ORDER BY Goals_And_Asists DESC

-- Which players contribute the most G+A per 90 minutes
SELECT TOP 20 squad,
	   Player,
	   G_A_90 AS Goals_And_Asists_Per_90_Minuets
FROM Players_Stats
ORDER BY Goals_And_Asists_Per_90_Minuets DESC


-- Which players have an expected goals (xG) value greater than 5
SELECT  Squad,
		Player,
		xG,
		Gls
FROM Players_Stats
WHERE xG > 5
ORDER BY xG DESC

-- Who are the top 10 players with the most minutes played
SELECT TOP 10 Squad,
		Player,
		Min AS Total_Minutes
FROM Players_Stats 
ORDER BY Total_Minutes DESC

-- What are the differences between actual goals and xG for players
SELECT  Squad,
		Player,
		Gls,
		xG,
		(Gls - xG)  AS Difference_Between_Goals_And_xG
FROM Players_Stats
ORDER BY Difference_Between_Goals_And_xG DESC

-- What is the average number of goals per player for each team
SELECT  Squad,
		COUNT(Player) AS Number_Of_Players,
		SUM(Gls) AS Total_Goals,
		ROUND(AVG(CAST (Gls AS FLOAT)), 2) AS Average_Goals_Per_Player
FROM Players_Stats
GROUP BY Squad

-- Who are the top 5 players with the most progressive passes (PrgP)
SELECT  TOP 5 Squad,
		Player,
		PrgP AS Progressive_Passes
FROM Players_Stats
ORDER BY Progressive_Passes DESC

-- How many players are there per position
SELECT  pos,
		COUNT(Pos) AS Amount_Of_Players
FROM Players_Stats
GROUP BY Pos

-- Which teams have more than 50 total goals 
SELECT  Squad,
		SUM(Gls) AS Total_Goals
FROM Players_Stats
GROUP BY Squad
HAVING SUM(Gls) > 50
ORDER BY Total_Goals DESC

-- Which players scored more than 0.5 goals per 90 minutes
SELECT  Squad,
		Player,
		Gls_90 AS Goals_Per_90_Minutes
FROM Players_Stats
WHERE Gls_90 > 0.5
ORDER BY Goals_Per_90_Minutes DESC

-- Which young players (under age 23) contribute the most G+A per 90 minutes
SELECT  Squad,
		Player,
		Age,
		G_A_90 AS Goals_And_Asists_Per_90_Minutes
FROM Players_Stats
WHERE Age < 23
ORDER BY Goals_And_Asists_Per_90_Minutes DESC

-- What is the average G+A per 90 minutes for each team
SELECT  Squad,
		ROUND(AVG(G_A_90), 2) AS Average_Goals_And_Asists_Per_90_Minutes
FROM Players_Stats
GROUP BY Squad
ORDER BY Average_Goals_And_Asists_Per_90_Minutes DESC

-- How many players are there from each nationality
SELECT  Nation,
		COUNT(*) AS Number_Of_Players
FROM Players_Stats
GROUP BY Nation
ORDER BY Number_Of_Players DESC

-- Which teams have an average xG per player greater than 0.3
SELECT  Squad,
		ROUND(AVG(xG), 2) AS Average_xG_Per_Player
FROM Players_Stats
GROUP BY Squad
HAVING AVG(xG) > 0.3
ORDER BY Average_xG_Per_Player DESC

-- Which players have played more than 10 matches and scored at least three goals
SELECT  Squad,
		Player,
		MP AS Matches_Played,
		Gls AS Goals_Scored
FROM Players_Stats
WHERE  MP > 10
	   AND Gls >= 3

-- Who are the top 10 players with the most progressive carries (PrgC)
SELECT  TOP 10 Squad,
		Player,
		PrgC AS Progressive_Carries
FROM Players_Stats
ORDER BY Progressive_Carries DESC

-- Which teams receive the highest percentage of goals from their top 3 scorers
;WITH Team_Top_Scorers AS(
	SELECT  Squad,
			Player,
			Gls,
			SUM(Gls) OVER(PARTITION BY Squad) AS Team_Total_Goals,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Gls DESC) AS Player_Goal_Ranking
	FROM Players_Stats
)
SELECT  Squad,
		SUM(Gls) AS Top_3_Players_Goals,
		FORMAT(SUM(Gls) * 1.0 / AVG(Team_Total_Goals), 'P') AS Percentage_Of_All_Team_Goals
FROM Team_Top_Scorers
WHERE Player_Goal_Ranking BETWEEN 1 AND 3
GROUP BY Squad
ORDER BY Percentage_Of_All_Team_Goals DESC

-- Which players are the most efficient in terms of goals + assists per minute played (more then 20 games)
SELECT  Squad,
		Player,
		Gls,
		Ast,
		Min,
		FORMAT((Gls + Ast) * 1.0 / Min, '##.####') AS Goals_And_Asists_Per_Minutes
FROM Players_Stats
WHERE MP > 20
ORDER BY Goals_And_Asists_Per_Minutes DESC

-- Which league shows the largest over - or underperformance compared to total expected goals (xG)

;WITH xG_Average AS (
	SELECT  Competition, 
			AVG(Gls * 1.0) AS Average_Goals_Per_Game,
			AVG(xG) AS Average_xG_Per_Game,
			AVG(Gls * 1.0) - AVG(xG) AS Differnce_Between_xG_And_Goals
	FROM Players_Stats
	GROUP BY Competition
)
SELECT  Competition,
		CASE
			WHEN Differnce_Between_xG_And_Goals < 0 THEN 'Underachievement'
			ELSE 'Overachievement'
		END AS Performence
FROM xG_Average
ORDER BY Differnce_Between_xG_And_Goals DESC

-- Which players contribute the most expected goals (xG) per 90 minutes for his team
;WITH Best_xG_All_Teams AS(
	SELECT  Squad,
			Player,
			xG_90,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY  xG_90 DESC)  AS xG_Goals_Per_90_Minutes
	FROM Players_Stats
)
SELECT  Squad,
		Player,
		xG_90
FROM Best_xG_All_Teams
WHERE xG_Goals_Per_90_Minutes = 1
ORDER BY xG_90 DESC

-- Which nationalities contributed the most goals and assists overall
SELECT  Nation,
		SUM(Gls) AS Total_Goals,
		SUM(Ast) AS Total_Asists,
		SUM(Gls) + SUM(Ast) AS Total_Goals_And_Asists
FROM Players_Stats
GROUP BY Nation
HAVING SUM(Gls) + SUM(Ast) > 100
ORDER BY Total_Goals_And_Asists DESC

-- Rank players within each team based on goals scored
;WITH Players_Goals_Ranking AS(
	SELECT  Squad,
			Player,
			Gls,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Gls DESC) AS Goals_Ranking
	FROM Players_Stats
)
SELECT  Squad,
		Player,
		Gls
FROM Players_Goals_Ranking
WHERE Goals_Ranking = 1
ORDER BY Gls DESC

-- Which players are ranked top 3 in both goals and assists within their team
;WITH Players_Goals_Asists_Rank AS(
	SELECT  Squad,
			Player,
			Gls,
			Ast,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Gls DESC) AS Goals_Rank,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Ast DESC) AS Asists_Rank,
			SUM(Gls) OVER(PARTITION BY Squad) AS Team_Total_Goals,
			SUM(Ast) OVER(PARTITION BY Squad) AS Team_Total_Asists
	FROM Players_Stats
)
SELECT	Squad,
		Player,
		Gls,
		Ast,
		FORMAT((Gls * 1.0) / Team_Total_Goals, 'P') AS Goal_Percentage,
		FORMAT((Ast * 1.0) / Team_Total_Asists, 'P') AS Asists_Percentage
FROM Players_Goals_Asists_Rank
WHERE Goals_Rank BETWEEN 1 AND 3
	  AND Asists_Rank BETWEEN 1 AND 3
ORDER BY Gls DESC,
		 Ast DESC

-- Divide players into 4 quartiles by xG within each team
SELECT  Squad,
		Player,
		xG,
		NTILE(4) OVER(PARTITION BY Squad ORDER BY xG DESC) AS xG_Group
FROM Players_Stats

-- Compare each player’s goals + assists to their team’s average
SELECT  Squad,
		Player,
		Gls,
		FORMAT(Gls * 1.0 / SUM(Gls) OVER(PARTITION BY Squad), 'P') AS Player_Goal_Percentage,
		FORMAT(Ast * 1.0 / SUM(Ast) OVER(PARTITION BY Squad), 'P') AS Player_Asists_Percentage
FROM Players_Stats
ORDER BY Squad, 
		 GLS DESC,
		 Ast DESC


-- How many players in each team perform above their team average in goals + assists
;WITH Players_Team_Goals_Asists AS(
	SELECT  Squad,
			Player,
			Gls,
			Ast,
			ROUND(AVG(Gls * 1.0) OVER(PARTITION BY Squad), 2) Team_Average_Goals_Per_Player,
			ROUND(AVG(Ast * 1.0) OVER(PARTITION BY Squad), 2) Team_Average_Asists_Per_Player
	FROM Players_Stats
), Players_Above_Average AS(
SELECT  Squad,
		Player,
		Gls,
		Ast
FROM Players_Team_Goals_Asists
WHERE Gls > Team_Average_Goals_Per_Player
	  AND Ast > Team_Average_Asists_Per_Player
)
SELECT  Squad,
		COUNT(*) AS Amount_Of_Players_Above_Average_Goals_And_Asists
FROM Players_Above_Average
GROUP BY Squad

-- Which players played the most minutes more than the next teammate
;WITH Minutes_Per_Player AS(
	SELECT  Squad,
			Player,
			Min,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Min DESC) AS Minutes_Rank
	FROM Players_Stats
), Diff_Minutes_Between_First_And_Second  AS(
	SELECT  Squad,
		MAX(CASE WHEN Minutes_Rank = 1 THEN Min END)  AS Most_Minutes,
		MAX(CASE WHEN Minutes_Rank = 1 THEN Player END) AS Player_With_Most_Minutes,
		MAX(CASE WHEN Minutes_Rank = 2 THEN Min END) AS Second_Most_Minutes,
		MAX(CASE WHEN Minutes_Rank = 2 THEN Player END) AS Player_With_Second_Most_Minutes,
		MAX(CASE WHEN Minutes_Rank = 1 THEN Min END)  - SUM(CASE WHEN Minutes_Rank = 2 THEN Min END) AS Diff_Between_First_And_Second
	FROM Minutes_Per_Player WHERE Minutes_Rank BETWEEN 1 AND 2
	GROUP BY Squad
)
SELECT *
FROM Diff_Minutes_Between_First_And_Second
ORDER BY Diff_Between_First_And_Second DESC

--Teams And Stadiums (Using JOIN)
SELECT  DISTINCT PS.Squad,
		TI.Stadium, 
		TI.Capacity
FROM Players_Stats PS
JOIN Team_Info TI 
ON TI.Squad = PS.Squad
ORDER BY Capacity DESC

-- Teams Budget Goal Scored
;WITH Team_Goals_And_Budget AS(
	SELECT  PS.Squad AS Team,
			SUM(PS.Gls) Team_Goals,
			AVG(TI.Budget) AS Team_Budget
	FROM Players_Stats PS
	JOIN Team_Info TI
	ON TI.Squad = PS.Squad
	GROUP BY PS.Squad
)
SELECT  Team,
		Team_Goals,
		Team_Budget,
		ROW_NUMBER() OVER(ORDER BY Team_Goals DESC) AS Team_Goals_Ranking,
		ROW_NUMBER() OVER(ORDER BY Team_Budget DESC) AS Team_Budget_Ranking
FROM Team_Goals_And_Budget
ORDER BY Team_Goals_Ranking 

-- Which teams have the highest average xG_90 among their top 5 players 
;WITH Most_Average_xG_Top_5_Players_Minutes AS(
	SELECT  Squad,
			Player,
			Min,
			xG,
			ROW_NUMBER() OVER(PARTITION BY Squad ORDER BY Min DESC) AS Minutes_Ranking
	FROM Players_Stats
)
SELECT  Squad,
		AVG(Min) AS Average_Minutes_Top_5_Players,
		AVG(xG) AS Average_xG
FROM Most_Average_xG_Top_5_Players_Minutes
WHERE Minutes_Ranking BETWEEN 1 AND 5
GROUP BY Squad
HAVING AVG(Min) > 3000
ORDER BY Average_xG DESC

-- Which teams rely most heavily on their defenders for assists
;WITH Defenders_Asists AS(
	SELECT  Squad,
			Pos,
			Ast,
			SUM(Ast) OVER(PARTITION BY Squad, Pos) AS Asists_Per_Position,
			SUM(Ast) OVER(PARTITION BY Squad)  AS Total_Asists
	FROM Players_Stats
)
SELECT DISTINCT Squad,
		FORMAT(Asists_Per_Position * 1.0 / Total_Asists, 'P') AS Defenders_Asists_Percentage
FROM Defenders_Asists
WHERE Pos = 'DF'


-- Which players with over 2000 minutes played are in the top 5% for G+A per 90
WITH Top_5_Players_G_A_90_More_2000_Minutes AS(
	SELECT  Squad,
			Player,
			MIN,
			G_A_90,
			NTILE(20) OVER(ORDER BY G_A_90 DESC) AS Goal_And_Asists_Per_90_Minutes_Group
	FROM Players_Stats
	WHERE Min > 2000
)
SELECT Squad,
		Player,
		MIN,
		G_A_90
FROM Top_5_Players_G_A_90_More_2000_Minutes
WHERE Goal_And_Asists_Per_90_Minutes_Group = 1