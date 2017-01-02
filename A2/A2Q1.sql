SET search_path TO bnb, public;


CREATE VIEW OnlyYears (travelerId, requestId, year) AS
SELECT travelerId, requestId, EXTRACT(YEAR from startdate)
FROM BookingRequest;

CREATE VIEW OnlyYearsBooking (travalerId, listingId, year) AS
SELECT travelerId, listingId, EXTRACT(YEAR from startdate)
From Booking;

CREATE VIEW NumbOfBookingRequest (travelerId, email, year, numreq) AS
SELECT T.travelerId, T.email,  year, count(requestId)
FROM Traveler T natural join OnlyYears
GROUP BY travelerId, year
HAVING year > EXTRACT(YEAR from current_date) - 10;


CREATE VIEW NumbOfBooking (travelerId, email, year, numBook) AS
SELECT T.travelerId, T.email, year, count(Distinct year)
FROM Traveler T natural join OnlyYearsBooking
WHERE year > EXTRACT(YEAR from current_date) - 10
GROUP BY travelerId, year;

CREATE VIEW Winners as SELECT travelerId, email, year::int as year, numReq as numRequests, numBook as numBooking
FROM NumbOfBookingRequest natural join NumbOfBooking;

CREATE VIEW Losers as 
(SELECT travelerId from Traveler) 
EXCEPT 
(SELECT travelerId from Winners);


CREATE VIEW LosersInfo AS
Select travelerId, email, null as year, 0 as numRequests, 0 as numBooking
FROM Traveler natural join Losers;


CREATE VIEW Unsorted as 
(SELECT * from Winners) 
UNION 
(SELECT * from LosersInfo);

SELECT *
FROM Unsorted
ORDER BY year DESC, travelerID ASC;