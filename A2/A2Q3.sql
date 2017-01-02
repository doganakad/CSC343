SET search_path TO bnb,public;

CREATE VIEW notValid AS
SELECT distinct B1.listingId
FROM Booking B1, Booking B2
WHERE B1.listingId = B2.listingId 
		AND EXTRACT(YEAR from B1.startdate) = EXTRACT(YEAR from B2.startdate)
		AND EXTRACT(MONTH from B1.startdate) = EXTRACT(MONTH from B2.startdate)
		AND EXTRACT(DAY from B1.startdate) < EXTRACT(DAY from B2.startdate)
		AND EXTRACT(DAY from B1.startdate) + B1.numNights < EXTRACT(DAY from B2.startdate);


CREATE VIEW validListings AS
(SELECT *
FROM listing) EXCEPT
(SELECT * FROM notValid natural join Listing);

CREATE VIEW ownerOfListing AS
SELECT *
FROM validListings V, homeowner O
WHERE V.owner = O.homeownerId;

CREATE VIEW listingsInfo AS
SELECT *
FROM (ownerOfListing natural join Booking) natural join CityRegulation;

CREATE VIEW withMaxLimit AS
SELECT homeownerId, listingId, sum(numNights) as rentedDays, EXTRACT(YEAR from startdate) as year, city
FROM listingsInfo
WHERE regulationType = 'max'
GROUP BY city, homeownerId, listingId, EXTRACT(YEAR from startdate);

CREATE VIEW regu AS
SELECT homeownerId as homeowner, listingId, CAST(year as integer) as year, W.city
FROM withMaxLimit W, CityRegulation C
WHERE W.city = C.city AND C.regulationType = 'max' AND W.rentedDays > C.days;

CREATE VIEW withMinLimit AS
SELECT homeownerId as homeowner, listingId, cast(EXTRACT(YEAR from startdate) as integer) as year, city
FROM listingsInfo
WHERE regulationType = 'min' AND numNights < days
GROUP BY city, homeowner, listingId, EXTRACT(YEAR from startdate);

(SELECT *
FROM regu) UNION
(SELECT *
FROM withMinLimit);