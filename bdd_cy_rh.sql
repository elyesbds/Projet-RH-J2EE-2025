DROP DATABASE CY_RH;
CREATE DATABASE CY_RH;
USE CY_RH;

DROP TABLE IF EXISTS Affectation_projet;
DROP TABLE IF EXISTS Fiche_de_paie;
DROP TABLE IF EXISTS Absence;
DROP TABLE IF EXISTS Projet;
DROP TABLE IF EXISTS Employer;
DROP TABLE IF EXISTS Departement;

-- Departements
CREATE TABLE Departement (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Intitule VARCHAR(100) NOT NULL UNIQUE,
  Chef_departement INT NULL
);

-- Employés 
CREATE TABLE Employer (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Matricule VARCHAR(30) UNIQUE,
  Nom VARCHAR(50) NOT NULL,
  Prenom VARCHAR(50) NOT NULL,
  Email VARCHAR(100) NOT NULL UNIQUE,
  Telephone VARCHAR(20),
  Password VARCHAR(255) NOT NULL,
  Poste VARCHAR(100) NOT NULL,
  Grade VARCHAR(50) NOT NULL,
  Salaire_base DECIMAL(10,2) NOT NULL,
  Date_embauche DATE NOT NULL,
  Id_departement INT,
  Role VARCHAR(30) NOT NULL DEFAULT 'EMPLOYE', -- ADMIN, CHEF_DEPT, CHEF_PROJET, EMPLOYE
  CONSTRAINT fk_employer_dept FOREIGN KEY (Id_departement) REFERENCES Departement(Id) ON DELETE SET NULL
);

ALTER TABLE Departement
  ADD CONSTRAINT fk_chef_dept FOREIGN KEY (Chef_departement) REFERENCES Employer(Id) ON DELETE SET NULL;

-- Projets 
CREATE TABLE Projet (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Nom_projet VARCHAR(150) NOT NULL,
  Etat_projet VARCHAR(30) NOT NULL DEFAULT 'EN_COURS', -- EN_COURS, TERMINE, ANNULE
  Date_debut DATE NOT NULL,
  Date_fin_prevue DATE,
  Date_fin_reelle DATE,
  Chef_projet INT,
  Id_departement INT,
  CONSTRAINT fk_chef_projet FOREIGN KEY (Chef_projet) REFERENCES Employer(Id) ON DELETE SET NULL,
  CONSTRAINT fk_projet_dept FOREIGN KEY (Id_departement) REFERENCES Departement(Id) ON DELETE SET NULL
);

-- Affectations (employé <=> projet)
CREATE TABLE Affectation_projet (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Id_employer INT NOT NULL,
  Id_projet INT NOT NULL,
  Date_affectation DATE NOT NULL,
  Date_fin_affectation DATE NULL,
  CONSTRAINT fk_affectation_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id),
  CONSTRAINT fk_affectation_projet FOREIGN KEY (Id_projet) REFERENCES Projet(Id)
);

-- Fiches de paie (par employé, mois/année)
CREATE TABLE Fiche_de_paie (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Id_employer INT NOT NULL,
  Mois INT NOT NULL,
  Annee INT NOT NULL,
  Salaire_base DECIMAL(10,2) NOT NULL,
  Primes DECIMAL(10,2) NOT NULL DEFAULT 0,
  Deductions DECIMAL(10,2) NOT NULL DEFAULT 0,
  Net_a_payer DECIMAL(10,2) NOT NULL,
  Date_generation DATE NOT NULL,
  CONSTRAINT fk_fiche_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id)
);

-- Absences
CREATE TABLE Absence (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Id_employer INT NOT NULL,
  Date_debut DATE NOT NULL,
  Date_fin DATE NOT NULL,
  Type_absence VARCHAR(50) NOT NULL, -- CONGE, MALADIE, ABSENCE_INJUSTIFIEE
  Motif TEXT NULL,
  CONSTRAINT fk_absence_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id)
);


-- Jeux de TEST
USE CY_RH;

-- 1) DEPARTEMENTS
INSERT INTO Departement (Id, Intitule, Chef_departement) VALUES
(1, 'DIRECTION GENERALE', NULL),
(2, 'RESSOURCES HUMAINES', NULL),
(3, 'INFORMATIQUE',       NULL),
(4, 'FINANCE',            NULL),
(5, 'MARKETING',          NULL);


-- 2) EMPLOYES
INSERT INTO Employer
  (Id, Matricule, Nom, Prenom, Email, Telephone, Password, Poste, Grade, Salaire_base, Date_embauche, Id_departement, Role)
VALUES
-- Direction générale
(1,  'EMP001', 'Admin',   'System',  'admin@cy-rh.local',   '0600000001', 'admin123',  'Administrateur', 'DIRECTEUR', 80000.00, '2020-01-10', 1, 'ADMIN'),
(2,  'EMP002', 'Martin',  'Claire',  'claire.martin@cy-rh.local', '0600000002', 'pwd', 'Directrice Générale Adjointe', 'DIRECTEUR', 65000.00, '2021-03-01', 1, 'EMPLOYE'),

-- Ressources Humaines
(3,  'EMP003', 'Durand',  'Sophie',  'sophie.durand@cy-rh.local', '0600000003', 'pwd', 'Responsable RH', 'MANAGER', 45000.00, '2022-02-15', 2, 'CHEF_DEPT'),
(4,  'EMP004', 'Bernard', 'Lucas',   'lucas.bernard@cy-rh.local', '0600000004', 'pwd', 'Chargé RH',      'CONFIRME', 32000.00, '2023-04-01', 2, 'EMPLOYE'),

-- Informatique
(5,  'EMP005', 'Nguyen',  'Thierry', 'thierry.nguyen@cy-rh.local','0600000005', 'pwd', 'DSI',            'MANAGER', 50000.00, '2021-09-01', 3, 'CHEF_DEPT'),
(6,  'EMP006', 'Ali',     'Karim',   'karim.ali@cy-rh.local',     '0600000006', 'pwd', 'Chef de Projet', 'SENIOR',   42000.00, '2022-10-05', 3, 'CHEF_PROJET'),
(7,  'EMP007', 'Lopez',   'Maria',   'maria.lopez@cy-rh.local',   '0600000007', 'pwd', 'Développeuse',   'CONFIRME', 35000.00, '2023-01-12', 3, 'EMPLOYE'),
(8,  'EMP008', 'Diallo',  'Amine',   'amine.diallo@cy-rh.local',  '0600000008', 'pwd', 'Développeur',    'JUNIOR',   30000.00, '2024-05-02', 3, 'EMPLOYE'),

-- Finance
(9,  'EMP009', 'Petit',   'Nadia',   'nadia.petit@cy-rh.local',   '0600000009', 'pwd', 'DAF',            'MANAGER', 52000.00, '2020-11-23', 4, 'CHEF_DEPT'),
(10, 'EMP010','Rossi',    'Enzo',    'enzo.rossi@cy-rh.local',    '0600000010', 'pwd', 'Comptable',      'CONFIRME', 36000.00, '2022-06-15', 4, 'EMPLOYE'),

-- Marketing
(11, 'EMP011','Moreau',   'Eva',     'eva.moreau@cy-rh.local',    '0600000011', 'pwd', 'Resp. Marketing','MANAGER',  46000.00, '2021-02-10', 5, 'CHEF_DEPT'),
(12, 'EMP012','Cheikh',   'Omar',    'omar.cheikh@cy-rh.local',   '0600000012', 'pwd', 'Chargé Marketing','JUNIOR',  29000.00, '2024-01-20', 5, 'EMPLOYE');

-- Définir officiellement les chefs de département
UPDATE Departement SET Chef_departement = 1  WHERE Id = 1; -- DG = Admin
UPDATE Departement SET Chef_departement = 3  WHERE Id = 2; -- RH
UPDATE Departement SET Chef_departement = 5  WHERE Id = 3; -- IT
UPDATE Departement SET Chef_departement = 9  WHERE Id = 4; -- Finance
UPDATE Departement SET Chef_departement = 11 WHERE Id = 5; -- Marketing


-- 3) PROJETS
INSERT INTO Projet
  (Id, Nom_projet, Etat_projet, Date_debut, Date_fin_prevue, Date_fin_reelle, Chef_projet, Id_departement)
VALUES
(1, 'Intranet RH',        'EN_COURS', '2025-01-15', '2025-06-30', NULL, 6, 3),
(2, 'Migration Comptable','EN_COURS', '2025-02-01', '2025-08-31', NULL, 9, 4),
(3, 'Site Vitrine 2025',  'EN_COURS', '2025-03-05', '2025-05-30', NULL,11, 5),
(4, 'Refonte Réseau',     'EN_COURS', '2025-01-20', '2025-04-30', NULL, 6, 3);


-- 4) AFFECTATIONS EMPLOYE ←→ PROJET
INSERT INTO Affectation_projet
  (Id, Id_employer, Id_projet, Date_affectation, Date_fin_affectation)
VALUES
(1, 6, 1, '2025-01-15', NULL), -- Karim chef projet Intranet RH
(2, 7, 1, '2025-01-20', NULL), -- Maria dev sur Intranet RH
(3, 8, 1, '2025-02-01', NULL), -- Amine dev sur Intranet RH

(4, 9, 2, '2025-02-01', NULL), -- Nadia (DAF) chef sur Migration Comptable
(5,10, 2, '2025-02-10', NULL), -- Enzo comptable projet 2

(6,11, 3, '2025-03-05', NULL), -- Eva chef projet site vitrine
(7,12, 3, '2025-03-10', NULL), -- Omar marketing projet 3

(8, 6, 4, '2025-01-20', NULL), -- Karim chef projet refonte réseau
(9, 7, 4, '2025-02-01', NULL), -- Maria dev projet 4
(10,8, 4, '2025-02-15', NULL); -- Amine dev projet 4


-- 5) FICHES DE PAIE 
INSERT INTO Fiche_de_paie
  (Id, Id_employer, Mois, Annee, Salaire_base, Primes, Deductions, Net_a_payer, Date_generation)
VALUES
-- Admin
(1, 1, 1, 2025, 80000.00, 0.00,   0.00, 80000.00, '2025-01-31'),
(2, 1, 2, 2025, 80000.00, 500.00, 0.00, 80500.00, '2025-02-28'),

-- Karim (Chef Projet)
(3, 6, 1, 2025, 42000.00, 300.00, 50.00, 42250.00, '2025-01-31'),
(4, 6, 2, 2025, 42000.00, 0.00,   0.00, 42000.00, '2025-02-28'),

-- Maria (Dev)
(5, 7, 1, 2025, 35000.00, 150.00, 0.00, 35150.00, '2025-01-31'),
(6, 7, 2, 2025, 35000.00, 0.00,  100.00, 34900.00, '2025-02-28'),

-- Enzo (Comptable)
(7,10, 1, 2025, 36000.00, 0.00,   0.00, 36000.00, '2025-01-31');


-- 6) ABSENCES
INSERT INTO Absence
  (Id, Id_employer, Date_debut, Date_fin, Type_absence, Motif)
VALUES
(1, 7, '2025-02-12', '2025-02-14', 'MALADIE', 'Grippe'),
(2,12, '2025-03-18', '2025-03-19', 'CONGE',   'Congé exceptionnel'),
(3, 4, '2025-01-29', '2025-01-29', 'ABSENCE_INJUSTIFIEE', 'Retard et absence demi-journée');


USE CY_RH;

SELECT * FROM Departement;
SELECT * FROM Employer;
SELECT * FROM Projet;
SELECT * FROM Affectation_projet;
SELECT * FROM Fiche_de_paie;
SELECT * FROM Absence;

