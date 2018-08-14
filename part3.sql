SELECT * 
INTO EmployeeAudit 
FROM Employee 
WHERE 0 = 1;
ALTER TABLE EmployeeAudit 
  ADD Operation varchar(50),
  DateTimeStamp datetime;
GO

SELECT * 
INTO JobAudit 
FROM Job 
WHERE 0 = 1;
ALTER TABLE JobAudit
  ADD Operation varchar(50),
  DateTimeStamp datetime;
GO

SELECT * 
INTO ProjectMainAudit 
FROM ProjectMain 
WHERE 0 = 1;
ALTER TABLE ProjectMainAudit
  ADD Operation varchar(50),
  DateTimeStamp datetime;
GO

SELECT * 
INTO ActivityMainAudit 
FROM ActivityMain 
WHERE 0 = 1;
ALTER TABLE ActivityMainAudit
  ADD Operation varchar(50),
  DateTimeStamp datetime;
GO



CREATE TRIGGER trgEmployee
ON Employee 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
  if exists(SELECT * FROM inserted)
BEGIN
  INSERT INTO EmployeeAudit (
    empNumber, 
    firstName, 
    lastName, 
    ssn, 
    address, 
    state, 
    zip, 
    jobCode, 
    dateOfBirth, 
    certification, 
    salary, 
    Operation, 
    DateTimeStamp
    )
  SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END

  if exists(SELECT * FROM deleted)
BEGIN
  INSERT INTO EmployeeAudit (
    empNumber, 
    firstName, 
    lastName, 
    ssn, 
    address, 
    state, 
    zip, 
    jobCode, 
    dateOfBirth, 
    certification, 
    salary, 
    Operation, 
    DateTimeStamp
    )
  SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted
END

  if(UPDATE(empNumber) OR UPDATE(firstName) OR UPDATE(lastName) OR UPDATE(ssn) OR UPDATE(address) OR UPDATE(state) OR UPDATE(zip) OR UPDATE(jobCode) OR UPDATE(dateOfBirth) OR UPDATE(certification) OR UPDATE(salary)) 
BEGIN
  INSERT INTO EmployeeAudit (
    empNumber, 
    firstName, 
    lastName, 
    ssn, 
    address, 
    state, 
    zip, 
    jobCode, 
    dateOfBirth, 
    certification, 
    salary, 
    Operation, 
    DateTimeStamp
    )
  SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted
  SELECT empNumber, firstName, lastName, ssn, address, state, zip, jobCode, dateOfBirth, certification, salary, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END
END;
GO



CREATE TRIGGER trgJob
ON Job 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
  if exists(SELECT * FROM inserted)
BEGIN
  INSERT INTO JobAudit (
    jobCode, 
    jobDesc, 
    Operation, 
    DateTimeStamp
    )
  SELECT jobCode, jobDesc, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END

  if exists(SELECT * FROM deleted)
BEGIN
  INSERT INTO JobAudit (
    jobCode, 
    jobDesc, 
    Operation, 
    DateTimeStamp
    )
  SELECT jobCode, jobDesc, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted

  if(UPDATE(jobCode) OR UPDATE(jobDesc))
BEGIN
  INSERT INTO JobAudit (
    jobCode, 
    jobDesc, 
    Operation, 
    DateTimeStamp
    )
  SELECT jobCode, jobDesc, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted
  SELECT jobCode, jobDesc, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END
END;
GO



CREATE TRIGGER trgProjectMain
ON ProjectMain 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
  if exists(SELECT * FROM inserted)
BEGIN
  INSERT INTO ProjectMainAudit (
    projectId, 
    projectName, 
    firmFedID, 
    fundedbudget, 
    projectStartDate, 
    projectStatus, 
    projectTypeCode, 
    projectedEndDate, 
    projectManager, 
    Operation, 
    DateTimeStamp
    )
  SELECT projectId, projectName, firmFedID, fundedbudget, projectStartDate, projectStatus, projectTypeCode, projectedEndDate, projectManager, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END

if exists(SELECT * FROM deleted)
BEGIN
  INSERT INTO ProjectMainAudit (
    projectId, 
    projectName, 
    firmFedID, 
    fundedbudget, 
    projectStartDate, 
    projectStatus, 
    projectTypeCode, 
    projectedEndDate, 
    projectManager, 
    Operation, 
    DateTimeStamp
    )
  SELECT projectId, projectName, firmFedID, fundedbudget, projectStartDate, projectStatus, projectTypeCode, projectedEndDate, projectManager, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted		
END
END;
GO



CREATE TRIGGER trgActivityMain
ON ActivityMain FOR INSERT, DELETE, UPDATE
AS
BEGIN
  if exists(SELECT * FROM inserted)
BEGIN
  INSERT INTO ActivityMainAudit (
    activityId, 
    activityName, 
    projectId, 
    costToDate, 
    activityStatus, 
    startDate, 
    endDate, 
    Operation, 
    DateTimeStamp
    )
  SELECT activityId, activityName, projectId, costToDate, activityStatus, startDate, endDate, 'INSERTED', CURRENT_TIMESTAMP 
  FROM inserted
END

  if exists(SELECT * FROM deleted)
BEGIN
  INSERT INTO ActivityMainAudit (
    activityId, 
    activityName, 
    projectId, 
    costToDate, 
    activityStatus, 
    startDate, 
    endDate, 
    Operation, 
    DateTimeStamp
    )
  SELECT activityId, activityName, projectId, costToDate, activityStatus, startDate, endDate, 'DELETED', CURRENT_TIMESTAMP 
  FROM deleted
END
END;
GO



CREATE VIEW vw_TableNoIndexes
AS
SELECT name, create_date
FROM sys.objects
WHERE (type = 'U') AND (object_id NOT IN( SELECT object_id FROM sys.indexes));
GO



CREATE VIEW vw_ProjectIdTables
AS
SELECT DISTINCT SO.name AS object_name     
FROM sys.objects SO INNER JOIN sys.columns SC ON SO.object_id=SC.object_id
WHERE SC.name LIKE '%projectid%'; 
GO



CREATE VIEW vw_Last7Obj
AS
SELECT name AS object_name, modify_date  
FROM sys.objects  
WHERE modify_date > GETDATE() - 7; 
GO



CREATE VIEW vw_ProjectProcs
AS
SELECT name AS proc_name, SM.definition, create_date    
FROM sys.objects SO INNER JOIN sys.sql_modules SM ON SM.object_id = SO.object_id  
WHERE SM.definition LIKE '%project%'; 
GO



CREATE PROCEDURE Sp_ActiveConnections
@databasename varchar(250)
AS
SELECT  db_name(dbid) DatabaseName, count(spid) NumberOfConnections, LoginName
FROM sys.sysprocesses
WHERE db_name(dbid)=@databasename
GROUP BY db_name(dbid), LoginName;
GO

EXEC Sp_ActiveConnections 'Rose_Z2969824'
GO

CREATE PROCEDURE Sp_LogFileStatus
@databasename varchar(250)
AS
SELECT  db_name(database_id) DatabaseName, sum(size*iif(type_desc='LOG', 1, 0)) LogSize, sum(size) TotalSize
FROM sys.master_files
WHERE (db_name(database_id)=@databasename)
GROUP BY db_name(database_id);
GO

EXEC Sp_LogFileStatus 'Rose_Z2969824'
GO
