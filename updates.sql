---спонсор
UPDATE Sponsor
set sponsorname = 'Илья Мэддисон'
where SponsorId = (
    select SponsorId
    from Sponsor
    where sponsorname = 'Юрий Хованский'
);

---роль
INSERT INTO positionPlayer(PLAYERID, POSITIONNAME)
VALUES (44, 'GK');

---
DELETE
FROM Goal
WHERE goalid = (SELECT goalid
    from goal
    where goal.half = 2 and goal.minutegoal = 91 and matchid = 18);