SET search_path TO bnb,public;

CREATE VIEW notBooked AS 
(SELECT travelerID 
FROM traveler)
EXCEPT 
(SELECT travelerID 
FROM booking);

CREATE VIEW travelerTotal as 
SELECT count(requestID) as total, travelerID 
FROM bookingrequest
GROUP BY travelerID;

CREATE VIEW losers as
(SELECT travelerID 
FROM traveler) 
EXCEPT 
(SELECT travelerID 
FROM travelerTotal);

CREATE VIEW losersTable as
SELECT 0 as total, travelerID
FROM losers natural join travelerTotal;

CREATE VIEW travelerTotalRequest as
(SELECT * 
FROM travelerTotal) 
UNION 
(SELECT * 
FROM losersTable);

CREATE VIEW numbtravelerID as 
SELECT count(travelerID) as tot 
FROM traveler;

CREATE VIEW totals as
SELECT count(requestID) as count
FROM bookingrequest;

CREATE VIEW tentimesmorethanaverage AS
SELECT B.travelerID
FROM (travelerTotalRequest natural join bookingrequest) B, numbtravelerID T, totals tot
WHERE B.total > 10*(tot.count/T.tot);

CREATE VIEW scraper as 
(SELECT * 
FROM tentimesmorethanaverage) 
INTERSECT
(SELECT * 
FROM notBooked);

CREATE VIEW scraperinfo as
SELECT travelerID, total, listingID
FROM (scraper natural join travelerTotalRequest) natural join bookingrequest;

CREATE VIEW mostRequested AS
(SELECT requestID, travelerID, listingID
FROM bookingrequest) EXCEPT
(SELECT B1.requestID, B1.travelerID, B1.listingID
FROM bookingrequest B1, bookingrequest B2
WHERE B1.travelerID = B2.travelerID AND B1.startdate < B2.startdate);

CREATE VIEW includedCity AS
SELECT travelerID, total, city as mostRequestedCity
FROM (mostRequested natural join listing) natural join scraperinfo;

SELECT DISTINCT travelerID, firstname || ' ' || surname as name, email, mostRequestedCity, total as numRequests
FROM includedCity natural join traveler
ORDER BY total DESC, travelerID ASC;