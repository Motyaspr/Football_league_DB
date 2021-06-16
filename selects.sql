---Кол-во игроков в команде
CREATE OR REPLACE FUNCTION playersInTeam(team_id BIGINT)
    RETURNS INT AS
$$
BEGIN
    return (
        SELECT COUNT(playerid)
        FROM contract
        WHERE contract.teamid = team_id
        GROUP BY teamid);
END
$$ LANGUAGE plpgsql;

SELECT playersInTeam
FROM playersInTeam(1);

---Голы3
SELECT scorerId,
       COUNT(goalid)
FROM (SELECT playerid
      FROM contract
      WHERE teamid = 3) AS sub_query
         INNER JOIN goal ON sub_query.playerid = goal.scorerid
GROUP BY (scorerid);

---Заработок
SELECT playerlastname, SUM(sponsorplayer.salary) + SUM(contract.salary) as INCOME
FROM Contract
         right join SponsorPlayer on SponsorPlayer.PlayerId = Contract.PlayerId
         inner join player on contract.playerid = player.playerid
WHERE contract.playerid = 34
GROUP BY (player.playerid);

---Амплуа
SELECT playerlastname, positionplayer.positionname
FROM PositionPlayer
         LEFT JOIN Player ON positionplayer.playerid = player.playerid
WHERE positionplayer.playerid = 61;

--- Участники
SELECT TeamName
FROM Match
         inner join team on match.hometeamid = team.teamid or match.awayteamid = team.teamid
WHERE matchid = 3;

--- Домашние голы
SELECT COUNT(teamid)
FROM (SELECT scorerid, hometeamid
      FROM Match
               inner join goal on Match.matchid = goal.matchid
      WHERE goal.matchid = 4) T
         INNER JOIN contract on contract.playerid = T.scorerid
WHERE hometeamid = teamid
GROUP BY teamid;

--- Гостевые голы
SELECT COUNT(teamid)
FROM (SELECT scorerid, awayteamid
      FROM Match
               inner join goal on Match.matchid = goal.matchid
      WHERE goal.matchid = 4) T
         INNER JOIN contract on contract.playerid = T.scorerid
WHERE awayteamid = teamid
GROUP BY awayteamid;

--- Суммарно дома
SELECT COUNT(goalid)
FROM (MATCH NATURAL JOIN goal) T
         INNER JOIN contract on contract.playerid = T.scorerid and contract.teamid = T.hometeamid
where T.hometeamid = 4;

--- Суммарно в гостях
SELECT COUNT(goalid)
FROM (MATCH NATURAL JOIN goal) T
         INNER JOIN contract on contract.playerid = T.scorerid and contract.teamid = T.awayteamid
where T.awayteamid = 4;

--- Туры
SELECT tournum, COUNT(matchId)
FROM MATCH
WHERE match.tournum = 1
GROUP BY tournum;

CREATE OR REPLACE FUNCTION home_team_pts(match_id BIGINT)
    RETURNS INT AS

$$
DECLARE
    home_team_id BIGINT;
    away_team_id BIGINT;
    home_goals   int;
    away_goals   int;
    pts          int;
BEGIN
    home_team_id = (SELECT hometeamid
                    FROM match
                    WHERE match.matchid = match_id);
    away_team_id = (SELECT awayteamid
                    FROM match
                    WHERE match.matchid = match_id);

    home_goals = (SELECT COUNT(teamid)
                  FROM (SELECT scorerid, hometeamid
                        FROM Match
                                 inner join goal on Match.matchid = goal.matchid
                        WHERE goal.matchid = match_id) T
                           INNER JOIN contract on contract.playerid = T.scorerid
                  WHERE hometeamid = teamid
                  GROUP BY teamid);
    away_goals = (SELECT COUNT(teamid)
                  FROM (SELECT scorerid, awayteamid
                        FROM Match
                                 inner join goal on Match.matchid = goal.matchid
                        WHERE goal.matchid = match.matchid) T
                           INNER JOIN contract on contract.playerid = T.scorerid
                  WHERE awayteamid = teamid
                  GROUP BY awayteamid);
    if (away_goals < home_goals) then
        pts = 3;
    elseif (away_goals == home_goals) then
        pts = 1;
    else
        pts = 0;
    end if;
    return pts;
end
$$ LANGUAGE plpgsql;