SSP1 Group4
Cao Liu
Chaeyoung Ahn
Dang Thi Mai Vy
Foo Ji Kai
Jonas Noblet  

1. Hospital Tables
CREATE TABLE ZipCode 
  ( 
     zip     CHAR(6) PRIMARY KEY, -- Singapore zip contains 6 digits
     city    VARCHAR(20) DEFAULT 'Singapore', 
     state   VARCHAR(20) DEFAULT 'Singapore',
     
     CHECK (zip NOT like '%[^0-9]%') -- digit only
  );

CREATE TABLE Address 
  ( 
     address VARCHAR(256) PRIMARY KEY, 
     zip     CHAR(6) NOT NULL, 
     
     FOREIGN KEY (zip) REFERENCES ZipCode(zip) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Person 
  ( 
     person_id  INT IDENTITY(1,1) PRIMARY KEY, -- 'Auto-increment for MS SQL'
     name       VARCHAR(50) NOT NULL, 
     birth_date DATE, 
     phone_num  CHAR(7) CHECK (phone_num NOT LIKE'%[^0-9]%'), -- Assumed all persons’ phone numbers have 7 digits.
     address    VARCHAR(256), 

     FOREIGN KEY (address) REFERENCES Address(address) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
  ); 


CREATE TABLE Employee
  ( 
     employee_id INT PRIMARY KEY, 
     date_hired  DATE NOT NULL,

     FOREIGN KEY (employee_id) REFERENCES person(person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
  ); 

CREATE TABLE Staff 
  ( 
     staff_id  INT PRIMARY KEY, 
     job_class VARCHAR(50)  NOT NULL,

     FOREIGN KEY (staff_id) REFERENCES Employee(employee_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
  ); 

CREATE TABLE Technician 
  ( 
     technician_id INT PRIMARY KEY, 
     skill         VARCHAR(20), 

     FOREIGN KEY (technician_id) REFERENCES Employee(employee_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Lab 
  ( 
     lab_name VARCHAR(30) PRIMARY KEY, 
     location VARCHAR(30) NOT NULL
  ); 

CREATE TABLE AssignTech 
  ( 
     technician_id INT NOT NULL, 
     lab_name      VARCHAR(30)  NOT NULL, 

     PRIMARY KEY(technician_id, lab_name),
     FOREIGN KEY (technician_id) REFERENCES Technician(technician_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE, 
     FOREIGN KEY (lab_name) REFERENCES Lab(lab_name)
        ON DELETE CASCADE
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Nurse 
  ( 
     nurse_id        INT PRIMARY KEY, 
     care_center_name VARCHAR(30), 

     FOREIGN KEY (nurse_id) REFERENCES Employee(employee_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
  ); 

CREATE TABLE NurseCertificate
  (
     nurse_id    INT NOT NULL,
     certificate VARCHAR(50) NOT NULL,
     PRIMARY KEY (nurse_id, certificate),

     FOREIGN KEY (nurse_id) REFERENCES Nurse(nurse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
  );
CREATE VIEW RN(nurse_id) AS
  ( 
     SELECT nurse_id
     FROM NurseCertificate
     WHERE certificate = 'Registered Nurse Certificate'
  ); 

CREATE TABLE CareCenter 
  ( 
     care_center_name VARCHAR(30) PRIMARY KEY, 
     location        VARCHAR(30) NOT NULL, 
     type            VARCHAR(30) NOT NULL, 
     nurse_ic_id     INT  NOT NULL UNIQUE,);

ALTER TABLE CareCenter ADD CHECK (type='Emergency' OR type='Maternity' OR type='Cardiology');
 

   
CREATE TABLE Room 
  ( 
     room_number     INT PRIMARY KEY, 
     care_center_name VARCHAR(30) NOT NULL, 
     
     FOREIGN KEY (care_center_name) REFERENCES CareCenter(care_center_name) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 


CREATE TABLE Bed 
  ( 
     room_number  INT NOT NULL, 
     bed_number INT NOT NULL, 
     
     PRIMARY KEY(room_number, bed_number), 
     
     FOREIGN KEY (room_number) REFERENCES room(room_number) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Physician 
  ( 
     physician_id        INT PRIMARY KEY, 
     specialty           VARCHAR(20) NOT NULL, 
     office_phone_number CHAR(10) CHECK (office_phone_number NOT LIKE '%[^0-9]%'), 
     
     FOREIGN KEY (physician_id) REFERENCES person(person_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 


CREATE TABLE Patient 
  ( 
     patient_id   INT PRIMARY KEY,
     physician_id INT NOT NULL, 
     contact_date DATE NOT NULL,

    FOREIGN KEY (patient_id) REFERENCES person(person_id),
    FOREIGN KEY (physician_id) REFERENCES physician(physician_id)

    CHECK (patient_id <> physician_id)   -- patients should not be their physician); 

CREATE TABLE Resident
  ( 
     resident_id   INT PRIMARY KEY, 
     date_admitted DATETIME NOT NULL,
     room_number   INT NOT NULL,
     bed_number    INT NOT NULL,
     
     FOREIGN KEY (resident_id) REFERENCES patient(patient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE, 
     FOREIGN KEY (room_number, bed_number) REFERENCES Bed(room_number, bed_number) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
  ); 

CREATE TABLE OutPatient 
  ( 
     outpatient_id INT PRIMARY KEY, 
     FOREIGN KEY (outpatient_id) REFERENCES patient(patient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Visit 
  ( 
     physician_id   INT NOT NULL, 
     outpatient_id INT NOT NULL,
     visit_date   DATETIME DEFAULT getdate(),
     comment      VARCHAR(128), 
     
     PRIMARY KEY (physician_id, outpatient_id, visit_date), 
     
  ); 

CREATE TABLE Volunteer 
  ( 
     volunteer_id INT PRIMARY KEY, 
     skill        VARCHAR(20), 
     
     FOREIGN KEY (volunteer_id) REFERENCES person (person_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  );

2. Triggers

/*check that if the nurse is in-charge of a care-center, she/he cannot be assigned to another carecenter*/
CREATE TRIGGER CHECK_nurse ON Nurse
FOR INSERT, UPDATE
AS BEGIN 
IF EXISTS (SELECT * FROM inserted, CareCenter 
WHERE nurse_id=nurse_ic_id 
AND inserted.care_center_name<>CareCenter.care_center_name)
BEGIN 
RAISERROR ('THE NURSE IS ALREADY ASSIGNED TO ANOTHER CARECENTER',16,1);
ROLLBACK TRANSACTION;
RETURN
END
END;

/*check that the nurse in-charge of care-center must have registered nurse certificate*/
CREATE TRIGGER CHECK_CARECENTER
ON CareCenter
FOR INSERT, UPDATE
AS BEGIN 
IF EXISTS (SELECT * FROM inserted WHERE nurse_ic_id <> ALL(SELECT* FROM RN))
BEGIN 
RAISERROR ('THE NURSE IS NOT REGISTERED',16,1);
ROLLBACK TRANSACTION;
RETURN
END
END;

 CREATE TRIGGER CHECK_RESIDENT ON Resident
 FOR INSERT, UPDATE
 AS BEGIN 
 IF EXISTS( SELECT * FROM inserted,Resident 
 WHERE inserted.resident_id <> Resident.resident_id
 AND inserted.room_number=Resident.room_number
 AND inserted.bed_number=Resident.bed_number)
 begin 
 RAISERROR('THE BED IS ALREADY ASSIGNED TO ANOTHER RESIDENT',16,1);
 ROLLBACK TRANSACTION;
 RETURN
 END
 END;

3. Sample Queries
/* 
1. Find all Volunteers who do not have any skills.
*/
SELECT DISTINCT name, volunteer_id
FROM Volunteer, Person
WHERE skill IS NULL AND
	  volunteer_id = person_id;

/* 
2.  Find each Physician who visited an Outpatient
    for whom he or she was not responsible for.
*/

SELECT DISTINCT name, Visit.physician_id
FROM Visit, Patient, Person
WHERE Visit.outpatient_id = Patient.patient_id AND 
	  Visit.physician_id <> Patient.physician_id AND 
	  person_id = Visit.physician_id;

/*
3. Find each Outpatient who has been visited exactly once.
*/ 

SELECT 	outpatient_id, name, COUNT(*) AS numOfVisit
FROM 	Visit, Person
WHERE 	outpatient_id = person_id
GROUP BY outpatient_id, name
HAVING COUNT(*)= 1;

/*
4. For each Skill, list the total number of volunteers and 
   technicians that achieve this skill. 
*/
SELECT skill, COUNT(*) AS totalNum
FROM
(	
	(SELECT volunteer_id, Skill
	FROM Volunteer)
	UNION
	(SELECT technician_id, Skill
	FROM Technician)
) AS SkillList
GROUP BY skill
HAVING skill is not null ;

/*
5. Find all Patients who have been admitted within one week 
   of their Contact Date.
*/
SELECT patient_id
FROM Patient P, Resident R
WHERE P.patient_id = R.Resident_ID AND 
	  DATEDIFF(day, date_admitted, contact_date) <= 7
--GROUP BY Patient_ID

/*
6. List all Physicians who have made more than 3 visits on a single day. 
*/
SELECT physician_id, COUNT(outpatient_id) AS numOfVisit
FROM   Visit
GROUP BY physician_id, visit_date
HAVING COUNT(outpatient_id) > 3;


 

4. Data Insertion

INSERT INTO ZipCode(zip) VALUES
	('520110'),
	('521110'),
	('596569'),
	('689379'),
	('546080'),
	('238858'),
	('560252'),
	('339696'),
	('247964'),
	('307987'),
	('208539'),
	('493152'),
	('348475'),
	('640492'),
	('547809'),
	('560727'),
	('550261'),
	('555950'),
	('310520'),
	('688253'),
	('908553'),
	('554479'),
	('110926'),
	('735360'),
	('836914'),
	('109610');
    
INSERT INTO ZipCode(zip, city, state) VALUES
	('123456', 'London', 'England');


INSERT INTO Address(address, zip) VALUES
	('Blk 110, Simei Street 1, #02-232', 	'520110'),
	('110 Tampines Street 11, #07-221', 	'521110'),
	('20 Toh Yi Drive, #10-889', 		'596569'),
	('10 Choa Chu Kang Road, #03-439', 	'689379'),
	('Blk 277, Orchard Road, #05-315',		'238858'),
	('252 Ang Mo Kio Avenue 4, #07-619', 	'560252'),
	('88 Geylang Bahru, #02-559', 		'339696'),
	('56 Tanglin Road, #02-930', 		'247964'),
	('55 Newton Road #02-468', 			'307987'),
	('180 Kitchener Road, #06-775',		'208539'),
	('55 Newton Road, #04-1023',			'307987'),
	('10 Collyer Quay, #13-405',			'493152'),
	('70 Macpherson Road, #23-574',		'348475'),
	('492 Jurong West Street 41, #03-472',	'640492'),
	('1 Lim Ah Pin Road, #05-378',		'547809'),
	('727 Ang Mo Kio Avenue 6, #08-234', 	'560727'),
	('261 Serangoon Central Drive, #3-15', 	'550261'),
	('54 Serangoon Garden Way, #04-451', 	'555950'),
	('520 Lorong 6 Toa Payoh, #10-264', 	'310520'),
	('2 Mowbray Road, #01-241',			'688253'),
	('221B Baker Street, LONDON',		'123456'),
	('160 Robel Avenue Place, #06-321',	'908553'),
	('21 Lorong 3 Bukit Batok, #03-43',	'554479'),
	('97 Kuhn Park Bridge, #23-241',		'110926'),
	('646B Jalan Ferry Avenue, #10-231',	'735360'),
	('69 Jalan Terry Lane, #05-67',		'836914'),
	('16 Gutmann Place Place, #12-357',	'109610');

INSERT INTO Person(name, birth_date, phone_num, address) VALUES
	('Alan',	'1985-01-02','9463523',	'Blk 110, Simei Street 1, #02-232'),
	('Ben', 	'1985-05-19','9430088', '110 Tampines Street 11, #07-221'),
	('Charles',	'1985-10-03','9396653',	'20 Toh Yi Drive, #10-889'),
	('Denmark',	'1986-02-17','9363218',	'10 Choa Chu Kang Road, #03-439'),
	('Eric',	'1986-07-04','9329783',	'Blk 277, Orchard Road, #05-315'),
	('Fish',	'1986-11-18','9296348',	'252 Ang Mo Kio Avenue 4, #07-619'),
	('Irene',	'1987-04-04','9262913',	'88 Geylang Bahru, #02-559'),
	('Janet',	'1987-08-19','9229478',	'56 Tanglin Road, #02-930'),
	('Tarzan',	'1988-10-03','9129173',	'55 Newton Road #02-468'),
	('Janet',	'1988-05-19','9162608',	'180 Kitchener Road, #06-775'),
	('Helen',	'1988-01-03','9196043',	'55 Newton Road, #04-1023'),
	('Icarus',	'1989-02-17','9095738',	'10 Collyer Quay, #13-405'),
	('Mary',	'1989-07-04','9062303',	'70 Macpherson Road, #23-574'),
	('Moses',	'1989-11-18','9028868',	'492 Jurong West Street 41, #03-472'),
	('Janice',	'1990-04-04','8995433',	'1 Lim Ah Pin Road, #05-378'),
	('Jessline','1990-08-19','8961998',	'727 Ang Mo Kio Avenue 6, #08-234'),
	('Judas',	'1991-05-20','8895128',	'54 Serangoon Garden Way, #04-451'),
	('Isaac',	'1991-10-04','8861693',	'520 Lorong 6 Toa Payoh, #10-264'),
	('Shannon',	'1992-02-18','8828258',	'2 Mowbray Road, #01-241'),
	('Franck',	'1992-07-04','8794823',	'160 Robel Avenue Place, #06-321'),
	('Robert',	'1992-11-18','8761388',	'21 Lorong 3 Bukit Batok, #03-43'),
	('Alix',	'1993-04-04','8727953',	'97 Kuhn Park Bridge, #23-241'),
	('Jose',	'1993-08-19','8694518',	'646B Jalan Ferry Avenue, #10-231'),
	('Peter',	'1994-01-03','8661083',	'69 Jalan Terry Lane, #05-67'),
	('Alison',	'1994-05-20','8627648',	'16 Gutmann Place Place, #12-357');

INSERT INTO Person(name, address) VALUES
	('Sherlock', '221B Baker Street, LONDON');

INSERT INTO Employee(employee_id, date_hired) VALUES
	(1,	'2006-04-07'),
	(2,	'2006-07-13'),
	(3,	'2006-10-18'),
	(4,	'2007-01-23'),
	(5,	'2017-11-01'),
	(6,	'2007-08-05'),
	(7,	'2007-11-10'),
	(8,	'2017-11-10'),
	(9,	'2008-05-22'),
	(10,	'2008-08-27'),
	(11,	'2008-12-02'),
	(12,	'2009-03-09'),
	(13,	'2009-06-14'),
	(14,	'2009-09-19');

INSERT INTO Staff(staff_id, job_class) VALUES
	(1,	'Receptionist'),
	(2,	'Janitor');

INSERT INTO Nurse(nurse_id, care_center_name) VALUES
	(5,		'Emergency Clinic'),
	(6,		'Emergency Clinic'),
	(7,		'Semi Care Center'),
	(8,		'Emergency Clinic'),
	(9,		'Pregnancy Care Center'),
	(10,		'Emergency Clinic');

INSERT INTO CareCenter VALUES
	('Semi Care Center', 		'10 Simei Street 3', 	'Cardiology', 7),
	('Pregnancy Care Center', 	'321 Clementi Ave 3', 	'Maternity',  6),
	('Emergency Clinic', 		'23 James Road',		'Emergency',  5);

INSERT INTO Room VALUES
	(1,	'Pregnancy Care Center'),
	(2,	'Pregnancy Care Center'),
	(3,	'Emergency Clinic'),
	(4,	'Emergency Clinic'),
	(5,	'Emergency Clinic');

INSERT INTO Bed VALUES
	(1,	1),
	(2,	1),
	(3,	1),
	(1,	2),
	(2,	2),
	(3,	2),
	(1,	3),
	(2,	3),
	(1,	4),
	(2,	4),
	(3,	4),
	(1,	5),
	(2,	5);

INSERT INTO NurseCertificate VALUES
	(5,		'Certified in Inpatient Obstetrics'),
(5,		‘Registered Nurse Certificate’),
	(6,		'Certified Emergency Nurse (CEN)'),
(6,		‘Registered Nurse Certificate’),
	(7,		'Cardiac-Vascular Nursing Certification'),
(7,		‘Registered Nurse Certificate’),
	(8,		'Certified Emergency Nurse (CEN)'),
	(9,		'Certified in Inpatient Obstetrics'),
	(10,		'Certified Emergency Nurse (CEN)');


INSERT INTO Technician VALUES
	(3,	'Welding'),
	(4,	'Circuits');

INSERT INTO Volunteer VALUES
	(11, 'Dancing'),
	(16, 'Welding'),
	(17, 'Circuits'),
	(15, 	NULL);

INSERT INTO Physician VALUES
	(12,  'Maternity',	'64238492'),
	(13,  'Emergency',	'66583614'),
	(14,  'Cardiology',	'68928736');


INSERT INTO Patient VALUES
	(15, 12, '2017-4-15'),
	(16, 12, '2017-5-8'),
	(17, 13, '2017-5-31'),
	(18, 13, '2017-6-23'),
	(19, 14, '2017-7-16'),
	(20, 12, '2017-8-8');

INSERT INTO Resident(resident_id, date_admitted, room_number, bed_number) VALUES
	(15, '2017-4-18',3,	1),
	(16, '2017-9-1', 1,	1);

INSERT INTO OutPatient VALUES
	(17),
	(18),
	(19),
	(20);

INSERT INTO Visit VALUES
	(13, 17, '2017-6-4', 'health diet'),
	(12, 18, '2017-7-1', 'drink water'),
	(13, 20, '2017-8-16', NULL),
	(14, 20, '2017-8-17', NULL),
	(13, 20, '2017-8-20', NULL),
	(13, 18, '2017-8-20', NULL),
	(13, 17, '2017-8-20', NULL),
	(13, 19, '2017-8-20', NULL);

INSERT INTO AssignTech VALUES
	(3,'Welding Lab'),
	(3,'Circuits Lab'),
	(4,'Circuits Lab');





