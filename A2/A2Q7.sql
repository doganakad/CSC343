SET search_path TO bnb,public;

CREATE VIEW pricePerNight AS
SELECT price / numNights as nightPrice, listingId, travelerId
FROM booking;

CREATE VIEW avgPerNight AS
SELECT listingId, avg(nightPrice) as perNight
FROM pricePerNight
GROUP BY listingId;

CREATE VIEW moreThanPercentage AS
SELECT travelerId, (perNight - nightPrice)/perNight * 100 as percent, listingId
FROM avgPerNight natural join pricePerNight
WHERE (perNight * 75/100) > nightPrice;

CREATE VIEW threeDiffList AS
SELECT travelerId, max(percent) as percent
FROM moreThanPercentage
GROUP BY travelerId
HAVING count(listingId) >= 3;


SELECT travelerId, percent::integer as largestBargainPercentage, listingId
FROM threeDiffList natural join moreThanPercentage
ORDER BY largestBargainPercentage DESC, travelerId ASC;