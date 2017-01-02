CREATE VIEW ownerWithAverage AS
SELECT owner, avg(rating) as average, extract(year from startdate) as year
FROM travelerRating natural join listing
WHERE extract(year from startdate) > extract(year from current_date) - 10
GROUP BY owner, extract(year from startdate);

CREATE VIEW ratingDecreasing AS
SELECT O1.owner
FROM ownerWithAverage O1, ownerWithAverage O2
WHERE O1.owner = O2.owner AND O1.year < O2.year AND O1.average > O2.average;

CREATE VIEW ratingNonDecreasingOwner (owner) AS
(SELECT homeownerid
FROM homeowner)
EXCEPT
(SELECT *
FROM ratingDecreasing);

CREATE VIEW contributedOwnerNumber AS
SELECT count(DISTINCT owner)::numeric as ownerSatisfies 
FROM ratingNonDecreasingOwner natural join ownerWithAverage;

CREATE VIEW totalContributedOwnerNumber AS
SELECT count(DISTINCT owner)::numeric as totalowner
FROM ownerWithAverage;

SELECT ((ownerSatisfies/totalowner) * 100.0)::integer as percentage
FROM contributedOwnerNumber, totalContributedOwnerNumber;