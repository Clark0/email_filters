CREATE TABLE ZipCode 
  ( 
     zip     CHAR(6) PRIMARY KEY -- Singapore zip contains 6 digits
     city    VARCHAR(20) NOT NULL, 
     state   VARCHAR(20) NOT NULL,
     
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
     person_id  INT AUTO_INCREMENT PRIMARY KEY, -- 'IDENTITY(1,1) for MS SQL'
     name       VARCHAR(50) NOT NULL, 
     birth_date DATE, 
     phone_num  CHAR(10) CHECK (phone_num NOT LIKE'%[^0-9]%'),       -- most phone numbers have less then 10 digits
     address    VARCHAR(256), 

     FOREIGN KEY (address) REFERENCES Address(address) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
  ); 

CREATE TABLE Employees 
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

     FOREIGN KEY (staff_id) REFERENCES Employees(employee_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
  ); 

CREATE TABLE Technician 
  ( 
     technician_id INT PRIMARY KEY, 
     skill         VARCHAR(20), 

     FOREIGN KEY (technician_id) REFERENCES Employees(employee_id)
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

     FOREIGN KEY (nurse_id) REFERENCES Employees(employee_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
  ); 


CREATE TABLE NurseCertificate
  (
     nurse_id    INT NOT NULL,
     certificate VARCHAR(20) NOT NULL,
     PRIMARY KEY (nurse_id, certificate),

     FOREIGN KEY (nurse_id) REFERENCES Nurse(nurse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
  );


CREATE VIEW RN(nurse_id) AS
  ( 
     SELECT nurse_id
     FROM NurseCertificate
     WHERE certificate = "Regisitered Nurse Certificae"
  ); 

CREATE TABLE CareCenter 
  ( 
     care_center_name VARCHAR(30) PRIMARY KEY, 
     location        VARCHAR(30) NOT NULL, 
     type            VARCHAR(30) NOT NULL, 
     nurse_ic_id     INT  NOT NULL UNIQUE,

    
     CHECK (nurse_ic_id IN (SELECT nurse_id
                            FROM   RN))
  ); 


ALTER TABLE Nurse
ADD FOREIGN KEY (care_center_name) REFERENCES CareCenter(care_center_name)
    ON DELETE CASCADE 
    ON UPDATE CASCADE;


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
     contact_date DATE NOT NULL,
     physician_id INT NOT NULL, 

    FOREIGN KEY (patient_id) REFERENCES person(person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE, 

    FOREIGN KEY (physician_id) REFERENCES physician(physician_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION, 

    CHECK (patient_id <> physician_id)   -- patients should not be their physician
  ); 

CREATE TABLE Resident -- can add triggers
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

CREATE TABLE ZipCode 
  ( 
     zip     CHAR(6) PRIMARY KEY -- Singapore zip contains 6 digits
     city    VARCHAR(20) NOT NULL, 
     state   VARCHAR(20) NOT NULL,
     
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
     person_id  INT AUTO_INCREMENT PRIMARY KEY, -- 'IDENTITY(1,1) for MS SQL'
     name       VARCHAR(50) NOT NULL, 
     birth_date DATE, 
     phone_num  CHAR(10) CHECK (phone_num NOT LIKE'%[^0-9]%'),       -- most phone numbers have less then 10 digits
     address    VARCHAR(256), 

     FOREIGN KEY (address) REFERENCES Address(address) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
  ); 

CREATE TABLE Employees 
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

     FOREIGN KEY (staff_id) REFERENCES Employees(employee_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
  ); 

CREATE TABLE Technician 
  ( 
     technician_id INT PRIMARY KEY, 
     skill         VARCHAR(20), 

     FOREIGN KEY (technician_id) REFERENCES Employees(employee_id)
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

     FOREIGN KEY (nurse_id) REFERENCES Employees(employee_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
  ); 


CREATE TABLE NurseCertificate
  (
     nurse_id    INT NOT NULL,
     certificate VARCHAR(20) NOT NULL,
     PRIMARY KEY (nurse_id, certificate),

     FOREIGN KEY (nurse_id) REFERENCES Nurse(nurse_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
  );


CREATE VIEW RN(nurse_id) AS
  ( 
     SELECT nurse_id
     FROM NurseCertificate
     WHERE certificate = "Regisitered Nurse Certificae"
  ); 

CREATE TABLE CareCenter 
  ( 
     care_center_name VARCHAR(30) PRIMARY KEY, 
     location        VARCHAR(30) NOT NULL, 
     type            VARCHAR(30) NOT NULL, 
     nurse_ic_id     INT  NOT NULL UNIQUE,

    
     CHECK (nurse_ic_id IN (SELECT nurse_id
                            FROM   RN))
  ); 


ALTER TABLE Nurse
ADD FOREIGN KEY (care_center_name) REFERENCES CareCenter(care_center_name)
    ON DELETE CASCADE 
    ON UPDATE CASCADE;


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
     contact_date DATE NOT NULL,
     physician_id INT NOT NULL, 

    FOREIGN KEY (patient_id) REFERENCES person(person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE, 

    FOREIGN KEY (physician_id) REFERENCES physician(physician_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION, 

    CHECK (patient_id <> physician_id)   -- patients should not be their physician
  ); 

CREATE TABLE Resident -- can add triggers
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
     visit_date   DATETIME DEFAULT GETDATE(),
     comment      VARCHAR(128), 
     
     PRIMARY KEY (visit_date, visitor_id, outpatient_id), 
     
     FOREIGN KEY (outpatient_id) REFERENCES OutPatient(outpatient_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE, 
     FOREIGN KEY (physician_id) REFERENCES Physician(physician_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 

CREATE TABLE Volunteer 
  ( 
     volunteer_id INT PRIMARY KEY, 
     skill        VARCHAR(20), 
     
     FOREIGN KEY (volunteer_id) REFERENCES person (person_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 


CREATE TABLE Volunteer 
  ( 
     volunteer_id INT PRIMARY KEY, 
     skill        VARCHAR(20), 
     
     FOREIGN KEY (volunteer_id) REFERENCES person (person_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
  ); 
