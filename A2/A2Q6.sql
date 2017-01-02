SET search_path TO bnb,public;

CREATE VIEW requestedTravelers as 
SELECT DISTINCT travelerID 
FROM bookingrequest;

CREATE VIEW bookedTravelers as 
SELECT DISTINCT travelerID 
FROM booking;

CREATE VIEW committedtravelers as 
SELECT travelerID 
FROM requestedTravelers 
INTERSECT 
(SELECT travelerID 
FROM bookedTravelers);

CREATE VIEW numboflistings as 
SELECT count(distinct listingID) as numListings, travelerID 
FROM booking natural join committedtravelers 
GROUP BY travelerID;


SELECT travelerID, surname, numListings
FROM numbofListings natural join Traveler
ORDER BY travelerID ASC;