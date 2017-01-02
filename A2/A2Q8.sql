SET search_path TO bnb, public;

CREATE VIEW allTravelers as 
SELECT travelerID 
FROM traveler;

CREATE VIEW travelersListings as 
SELECT listingID, travelerID , startdate
FROM allTravelers natural join Booking;

CREATE VIEW travelerRates as 
SELECT rating, listingID, travelerID 
FROM TravelerRating natural join travelersListings;

CREATE VIEW homeownerRates as 
SELECT distinct listingID,travelerID, rating 
FROM HomeOwnerRating natural join travelersListings;

CREATE VIEW compareRatings as 
SELECT distinct B.travelerID travelerID, T.rating ratingt, B.rating ratingh 
FROM homeownerRates B,travelerRates T
WHERE B.listingID = T.listingID and B.travelerID = T.travelerID;

CREATE VIEW differbyOne as 
SELECT distinct B.travelerID travelerID, T.rating ratingt, B.rating ratingh 
FROM homeownerRates B, travelerRates T
WHERE B.listingID = T.listingID and B.travelerID = T.travelerID and 
(T.rating = B.rating or T.rating = B.rating - 1);

CREATE VIEW reciprocal as 
SELECT DISTINCT travelerID, count(distinct ratingt) reciprocals 
FROM compareRatings
GROUP BY travelerID;

CREATE VIEW backstrachers as 
SELECT DISTINCT travelerID, count(distinct ratingt) backScratches 
FROM differbyOne 
GROUP BY travelerID;

CREATE VIEW partialresults as 
SELECT DISTINCT reciprocal.travelerID travelerID, reciprocals::bigint, backScratches::bigint
FROM reciprocal natural join backstrachers;

CREATE VIEW losers as 
(SELECT * 
FROM allTravelers) 
EXCEPT 
(SELECT DISTINCT travelerID 
FROM partialresults);

CREATE VIEW loserstable as 
SELECT travelerID, 0 as reciprocals, 0 as backScratches
FROM losers;

CREATE VIEW result as 
(SELECT * FROM 
loserstable) 
UNION 
(SELECT * 
FROM partialresults);

SELECT * 
FROM result 
ORDER BY reciprocals DESC, backScratches DESC, travelerID ASC;