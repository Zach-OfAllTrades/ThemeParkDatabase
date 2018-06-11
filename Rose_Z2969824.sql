CREATE TABLE Job(
  jobCode char(4) not null,
  jobDesc varchar(50) null,

  CONSTRAINT PK_JobCode PRIMARY KEY (jobCode),

  CONSTRAINT JOB_JOBCODE CHECK (jobCode='CAST' OR jobCode='ENGI' OR jobCode='INSP' OR jobCode='PMGR')
);
GO

CREATE TABLE Employee(
  empNumber char(8) not null,
  firstName varchar(25) null,
  lastName varchar(25) null,
  ssn char(9) null,
  address varchar(50) null,
  state char(2) null,
  zip char(5) null,
  jobCode char(4) null,
  dateOfBirth date null,
  certification bit null,
  salary money null,

  CONSTRAINT PK_EmpNumber PRIMARY KEY (empNumber),

  CONSTRAINT FK_JOB FOREIGN KEY (jobCode)
    REFERENCES Job(jobCode),

  CONSTRAINT EMP_STATECHECK CHECK (state='CA' OR state='FL')
);
GO

Insert into Job values ('CAST', 'Cast Memeber');
Insert into Job values ('ENGI', 'Engineer');
Insert into Job values ('INSP', 'Inspector');
Insert into Job values ('PMGR', 'Project Manager');

Insert into Employee values('12345678','Caroline','Clarke','896979789','1026 S Saylor Ave Jacksonvlle','FL','32225','PMGR','12-30-1993','1','160000.00');
Insert into Employee values('87654321','Kyle','Reid','888869345','4815 Mariners Point Dr San Diego','CA','60126','ENGI','10-20-1990','1','80000.00');
Insert into Employee values('45362718','Nick','Delaparte','904504512','206 Oleander St Neptune Beach','FL','32046','CAST','01-27-1991','0','35000.00');

GO

CREATE VIEW vw_CertifiedEngineers
AS
  SELECT empNumber, firstName, lastName, jobDesc
  FROM Employee, Job
  WHERE Employee.jobCode = 'ENGI' AND certification = 1;
GO

CREATE VIEW vw_ReadyToRetire 
AS
  SELECT empNumber, firstName, lastName
  FROM Employee
  WHERE DateDiff(year, dateOfBirth, GETDATE()) > 62;
GO

CREATE VIEW vw_EmployeeAvgSalary AS
  SELECT AVG(salary) as AvgSalary, jobCode
  FROM Employee group by jobCode;
GO

CREATE INDEX IDX_LastName
  ON Employee (lastName);
GO

CREATE INDEX IDX_ssn
  ON Employee (ssn);
GO
