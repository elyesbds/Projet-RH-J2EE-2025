CREATE TABLE Employer(
	Id VARCHAR(30) PRIMARY KEY,
    Nom VARCHAR(30) NOT NULL,
    Prenom VARCHAR(30) NOT NULL,
    Password VARCHAR(30),
    id_departement VARCHAR(30),
    FOREIGN KEY fk_departement(id_departement) REFERENCES Departement(Intituler));
CREATE TABLE Departement(
	Intituler VARCHAR(30) PRIMARY KEY);
CREATE TABLE Fiche_de_paie(
	Mois DATE PRIMARY KEY,
    Id_employer VARCHAR(30) PRIMARY KEY,
    FOREIGN KEY fk_employer(Id_employer) REFERENCES Employer(Id));
CREATE TABLE Projet(
	Etat_projet VARCHAR(30),
    id_departement VARCHAR(30),
    FOREIGN KEY fk_departement(id_departement) REFERENCES Departement(Intituler));
CREATE TABLE Affectation_projet(
    Id_employer VARCHAR(30) PRIMARY KEY,
    Id_departement VARCHAR(30) PRIMARY KEY,
    Poste VARCHAR(30),
    Salaire VARCHAR(30),
	Jour DATE,
    FOREIGN KEY fk_employer(Id_employer) REFERENCES Employer(Id),
    FOREIGN KEY fk_departement(id_departement) REFERENCES Departement(Intituler));
CREATE TABLE Absence (
	Jour DATE PRIMARY KEY,
    Id_employer VARCHAR(30) PRIMARY KEY,
    FOREIGN KEY fk_employer(Id_employer) REFERENCES Employer(Id));