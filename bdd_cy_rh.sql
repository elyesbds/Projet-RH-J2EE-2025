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
