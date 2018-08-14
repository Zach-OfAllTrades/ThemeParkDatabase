CREATE TABLE ProjectMain (
    projectId char(4) not null,
    projectName varchar(50) null,
    firmFedID char(9) null,
    fundedbudget decimal(16,2) null,
    projectStartDate date null,
    projectStatus varchar(25) null,
    projectTypeCode char(5) null,
    projectedEndDate date null,
    projectManager char(8) null,

    CONSTRAINT PK_ProjectMain PRIMARY KEY (projectId),

    CONSTRAINT MAIN_TYPECODE CHECK (projectTypeCode='FAC' OR projectTypeCode='RIDE' OR projectTypeCode='RET' OR projectTypeCode='FOOD')
);
GO

CREATE TABLE ActivityMain (
    activityId char(4) not null,
    activityName varchar(50) null,
    projectId char(4) not null,
    costToDate decimal(16,2) null,
    activityStatus varchar(25) null,
    startDate date null,
    endDate date null,

    CONSTRAINT PK_ActivityMain PRIMARY KEY (activityId, projectId)
);
GO

CREATE TABLE FirmMain (
    firmFedID char(9) not null,
    firmName varchar(50) null,
    firmAddress varchar(50) null,

    CONSTRAINT PK_FirmMain PRIMARY KEY (firmFedID)
);
GO

CREATE TABLE ProjectDescriptions (
    projectTypeCode char(5) not null,
    projectTypeDesc varchar(50) null,

    CONSTRAINT PK_ProjectDescriptions PRIMARY KEY (projectTypeCode),

    CONSTRAINT DESC_TYPECODE CHECK (projectTypeCode='FAC' OR projectTypeCode='RIDE' OR projectTypeCode='RET' OR projectTypeCode='FOOD')
);
GO

CREATE PROCEDURE SP_AddUpdateProject (
    @projectId char(4),
    @projectName varchar(50),
    @firmFedID char(9),
    @fundedbudget decimal(16,2),
    @projectStartDate date,
    @projectStatus varchar(25),
    @projectTypeCode char(5),
    @projectedEndDate date,
    @projectManager char(8)
)
AS
BEGIN
    if exists(SELECT * FROM ProjectMain WHERE @projectId = projectId)
    BEGIN
        UPDATE ProjectMain
        SET projectName = @projectName,
        firmFedID = @firmFedID,
        fundedbudget = @fundedbudget,
        projectStartDate = @projectStartDate,
        projectstatus = @projectstatus,
        projectTypeCode = @projectTypeCode,
        projectedEndDate = @projectedEndDate,
        projectManager = @projectManager
        WHERE projectId = @projectId;
    END
    ELSE
    BEGIN
    INSERT INTO ProjectMain (
        projectId, 
        projectName, 
        firmFedID, 
        fundedbudget, 
        projectStartDate,
        projectStatus, 
        projectTypeCode, 
        projectedEndDate, 
        projectManager
    )
    VALUES (
        @projectId,
        @projectName,
        @firmFedID,
        @fundedbudget,
        @projectStartDate,
        @projectstatus,
        @projectTypeCode,
        @projectedEndDate,
        @projectManager
    );
    END
END
GO

CREATE PROCEDURE SP_DeleteProject (
    @projectId char(4)
)
AS
BEGIN
    DELETE FROM ProjectMain 
    WHERE projectId = @projectId;
END
GO

CREATE PROCEDURE SP_AddUpdateActivity (
    @activityId char(4),
    @activityName varchar(50),
    @projectId char(4),
    @costToDate decimal(16,2),
    @activityStatus varchar(25),
    @startDate date,
    @endDate date
)
AS 
BEGIN
    if exists(SELECT * FROM Activity WHERE activityId = @activityId)
    BEGIN
        UPDATE ActivityMain
        SET activityName = @activityName,
        projectId = @projectId,
        costToDate = @costToDate,
        activityStatus = @activityStatus,
        startDate = @startDate,
        endDate = @endDate
        WHERE @activityId = activityId;
    END
    ELSE
    BEGIN
    INSERT INTO ActivityMain (
        activityId, 
        activityName,
        projectId, 
        costToDate, 
        activityStatus, 
        startDate, 
        endDate
    )
    VALUES (
        @activityId,
        @activityName,
        @projectId,
        @costToDate,
        @activityStatus,
        @startDate,
        @endDate
    )
    END
END
GO

CREATE PROCEDURE SP_DeleteActivity (
    @projectId char(4),
    @activityId char(4)
)
AS 
BEGIN
    DELETE FROM ActivityMain 
    WHERE projectId = @projectId AND activityId = @activityId;
END
GO

CREATE PROCEDURE SP_ProcessProjectDelay(
    @projectId char(4)
)
AS
BEGIN
    DECLARE @fine decimal(16,2),
            @totalFine decimal(16,2),
            @daysPastDue int,
            @newFundedbudget decimal(16,2),
            @newProjectedEndDate date;

    if(
        SELECT DATEDIFF(DAY, ProjectMain.projectedEndDate, ActivityMain.endDate) 
        AS daysPastDue
        FROM ActivityMain
        INNER JOIN ProjectMain
        ON ActivityMain.projectId = ProjectMain.projectId
    ) > 0
    BEGIN
        SELECT @daysPastDue = DATEDIFF(DAY, ProjectMain.projectedEndDate, ActivityMain.endDate)
        FROM ActivityMain
        INNER JOIN ProjectMain
        ON ActivityMain.projectId = ProjectMain.projectId

        SELECT @totalFine = @fine * @daysPastDue

        SELECT @newFundedbudget = ProjectMain.fundedbudget + @totalFine 
        FROM ProjectMain

        SELECT @newProjectedEndDate = DATEADD(DAY, @daysPastDue, ProjectMain.projectedEndDate)
        FROM ProjectMain

        UPDATE ProjectMain
        SET projectedEndDate = @newProjectedEndDate,
        fundedbudget = @newFundedbudget
        WHERE projectId = @projectId
    END
END
