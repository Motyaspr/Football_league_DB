CREATE TABLE Position
(
    ShortName VARCHAR(10) NOT NULL,
    PRIMARY KEY (ShortName)
);

CREATE TABLE Sponsor
(
    SponsorId   BIGSERIAL   NOT NULL,
    SponsorName VARCHAR(90) NOT NULL,
    Income      NUMERIC(40),
    PRIMARY KEY (SponsorId)
);

CREATE TABLE Player
(
    PlayerId        BIGSERIAL   NOT NULL,
    PlayerFirstName VARCHAR(90),
    PlayerLastName  VARCHAR(90) NOT NULL,
    PositionName    VARCHAR(10) NOT NULL,
    PRIMARY KEY (PlayerId)
);

CREATE TABLE PositionPlayer
(
    PlayerId     BIGSERIAL   NOT NULL REFERENCES Player (PlayerId),
    PositionName VARCHAR(10) NOT NULL REFERENCES Position (ShortName),
    PRIMARY KEY (PlayerId, PositionName)
);

ALTER TABLE Player
    ADD FOREIGN KEY (PlayerId, PositionName)
        REFERENCES PositionPlayer (PlayerId, PositionName) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE SponsorPlayer
(
    Salary    NUMERIC(40) NOT NULL,
    SponsorId BIGSERIAL   NOT NULL REFERENCES Sponsor (SponsorId),
    PlayerId  BIGSERIAL   NOT NULL REFERENCES Player (PlayerId),
    PRIMARY KEY (PlayerId, SponsorId)
);

CREATE TABLE Stadium
(
    StadiumId   BIGSERIAL   NOT NULL,
    StadiumName VARCHAR(90) NOT NULL,
    Capacity    INT         NOT NULL,
    PRIMARY KEY (StadiumId)
);

CREATE TABLE Team
(
    TeamId    BIGSERIAL   NOT NULL,
    TeamName  VARCHAR(90) NOT NULL,
    City      VARCHAR(90) NOT NULL,
    StadiumId BIGSERIAL   NOT NULL REFERENCES Stadium (StadiumId),
    PlayerId  BIGSERIAL   NOT NULL,
    PRIMARY KEY (TeamId),
    UNIQUE (TeamName, City)
);

CREATE TABLE Contract
(
    Salary      NUMERIC(40) NOT NULL,
    GoalBonus   NUMERIC(40),
    AssistBonus NUMERIC(40),
    PlayerId    BIGSERIAL   NOT NULL REFERENCES Player (PlayerId) PRIMARY KEY,
    TeamId      BIGSERIAL   NOT NULL REFERENCES Team (TeamId),
    UNIQUE (PlayerId, TeamId)
);

ALTER TABLE Team
    ADD FOREIGN KEY (PlayerId, TeamId)
        REFERENCES Contract (PlayerId, TeamId) DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE SponsorTeam
(
    Salary    NUMERIC(40) NOT NULL,
    SponsorId BIGSERIAL   NOT NULL REFERENCES Sponsor (SponsorId),
    TeamId    BIGSERIAL   NOT NULL REFERENCES Team (TeamId),
    PRIMARY KEY (TeamId, SponsorId)
);

CREATE TABLE Match
(
    MatchId    BIGSERIAL NOT NULL,
    MatchDate  DATE      NOT NULL,
    TourNum    INT       NOT NULL,
    HomeTeamId BIGSERIAL NOT NULL REFERENCES Team (TeamId),
    AwayTeamId BIGSERIAL NOT NULL REFERENCES Team (TeamId) CHECK (HomeTeamId != AwayTeamId),
    PRIMARY KEY (MatchId)
);

CREATE TABLE Goal
(
    GoalId     BIGSERIAL NOT NULL,
    Half       INT       NOT NULL,
    MinuteGoal INT       NOT NULL CHECK (Half = 1 or (Half >= 2 and MinuteGoal >= 45)),
    ScorerId   BIGSERIAL NOT NULL REFERENCES Player (PlayerId),
    MatchId    BIGSERIAL NOT NULL REFERENCES Match (MatchId),
    PRIMARY KEY (GoalId)
);

CREATE TABLE Assist
(
    PlayerId BIGSERIAL NOT NULL REFERENCES Player (PlayerId),
    GoalId   BIGSERIAL NOT NULL REFERENCES Goal (GoalId),
    PRIMARY KEY (GoalId)
);

-- для быстрого поиска стадиона комаанды
CREATE INDEX TeamIdToStadiumId on Team using btree (TeamId, StadiumId);

-- для быстрого поиска команды игрока
CREATE INDEX ContractToTeam on Contract using btree (PlayerId, TeamId);

-- для быстрого поиска автора гола
CREATE INDEX GoalToPlayer on Goal using btree (GoalId, ScorerId);

-- для быстрого поиска матча по голу
CREATE INDEX GoalToMatch on Goal using btree (GoalId, MatchId);

-- для быстрого поиска команды, которая играла дома
CREATE INDEX MatchToHome on Match using btree (MatchId, HomeTeamId);

-- для быстрого поиска команды, которая играла в гостях
CREATE INDEX MatchToAway on Match using btree (MatchId, AwayTeamId);

-- для быстрого поиска автора передачи
CREATE INDEX AssistToPlayer on Assist using btree (GoalId, PlayerId);

-- для быстрого поиска свидетеля команды(может помочь при удалении команды)
CREATE INDEX TeamPlayer on Team using btree (playerid, teamid);

-- для быстрого поиска всех контрактов данного спонсора с игроками/командами
CREATE INDEX SponsorToPlayer on SponsorPlayer using btree(sponsorId);
CREATE INDEX SponsorToTeam on SponsorTeam using btree(sponsorId);

-- для быстрого поиска всех контрактов данного игрока/команды с спонсорами
CREATE INDEX PlayerToSponsor on SponsorPlayer using btree(playerid);
CREATE INDEX TeamToSponsor on SponsorTeam using btree(teamid);

-- для быстрого поиска всех позиций игрока
CREATE INDEX AllPosition on PositionPlayer using btree(PlayerId);

-- для быстрого поиска всех игроков на данной позиции
CREATE INDEX AllPlayerPosition on PositionPlayer using btree(PositionName);

-- для быстрого поиска всех игроков с данным именем
CREATE INDEX PlayersByName on Player using hash(PlayerLastName);

-- для быстрого поиска всех спонсоров с данным именем
CREATE INDEX SponsorByName on Sponsor using hash(SponsorName)

