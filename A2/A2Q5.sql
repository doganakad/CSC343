SET search_path TO bnb,public;

CREATE VIEW listingRating as 
SELECT l.listingID as listingID, l.owner as homeownerId, COALESCE(h.rating, 0) as rating
FROM listing l natural left join TravelerRating h;

CREATE VIEW rating5 AS
(SELECT distinct(homeownerId), count(*) as r5
FROM homeowner  natural join listingRating
WHERE rating = 5
GROUP BY homeownerId, rating);

CREATE VIEW DontHaverating5 AS
SELECT distinct(homeownerId), null::bigint as r5
FROM homeowner  natural join listingRating
WHERE rating <> 5 and homeownerId NOT IN (SELECT homeownerId FROM rating5)
GROUP BY homeownerId, rating;

CREATE VIEW ALLRating5 AS
(SELECT * FROM rating5)
UNION
(SELECT * FROM DontHaverating5);


CREATE VIEW rating4 AS
(SELECT homeownerId, count(rating) as r4
FROM listingRating
WHERE rating=4
GROUP BY homeownerId, rating);


CREATE VIEW DontHaverating4 AS
SELECT distinct(homeownerId), null::bigint as r4
FROM homeowner  natural join listingRating
Where rating <> 4 and homeownerId NOT IN (SELECT homeownerId FROM rating4)
GROUP BY homeownerId, rating;

CREATE VIEW ALLRating4 AS
(SELECT * FROM rating4)
UNION
(SELECT * FROM DontHaverating4);

CREATE VIEW rating3 AS
(SELECT homeownerId, count(rating) as r3
FROM listingRating
WHERE rating = 3
GROUP BY homeownerId, rating);

CREATE VIEW DontHaverating3 AS
SELECT distinct(homeownerId), null::bigint as r3
FROM homeowner  natural join listingRating
Where rating <> 3 and homeownerId NOT IN (SELECT homeownerId FROM rating3)
GROUP BY homeownerId, rating;

CREATE VIEW ALLRating3 AS
(SELECT * FROM rating3)
UNION
(SELECT * FROM DontHaverating3);

CREATE VIEW rating2 AS
(SELECT homeownerId, count(rating) as r2
FROM listingRating
WHERE rating = 2
GROUP BY homeownerId, rating);

CREATE VIEW DontHaverating2 AS
SELECT distinct(homeownerId), null::bigint as r2
FROM homeowner  natural join listingRating
Where rating <> 2 and homeownerId NOT IN (SELECT homeownerId FROM rating2)
GROUP BY homeownerId, rating;

CREATE VIEW ALLRating2 AS
(SELECT * FROM rating2)
UNION
(SELECT * FROM DontHaverating2);

CREATE VIEW rating1 AS
(SELECT homeownerId, count(rating) as r1
FROM listingRating
WHERE rating = 1
GROUP BY homeownerId, rating);


CREATE VIEW DontHaverating1 AS
SELECT distinct(homeownerId), null::bigint as r1
FROM homeowner  natural join listingRating
Where rating <> 1 and homeownerId NOT IN (SELECT homeownerId FROM rating1)
GROUP BY homeownerId, rating;

CREATE VIEW ALLRating1 AS
(SELECT * FROM rating1)
UNION
(SELECT * FROM DontHaverating1);

SELECT homeownerId, r5, r4, r3, r2, r1
FROM ALLRating5 natural join ALLRating4 natural join ALLRating3 natural join ALLRating2 natural join ALLRating1
ORDER BY r5 DESC, r4 DESC, r3 DESC, r2 DESC, r1 DESC, homeownerId ASC;