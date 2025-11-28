-- =====================================================
-- SCRIPT DE CRÉATION BASE DE DONNÉES CY-RH
-- Projet : Système de Gestion des Ressources Humaines
-- Version : 1.0 - Rendu Final
-- =====================================================

-- Suppression et création de la base
DROP DATABASE IF EXISTS CY_RH;
CREATE DATABASE CY_RH;
USE CY_RH;

-- =====================================================
-- CRÉATION DES TABLES
-- =====================================================

-- Table Departement
CREATE TABLE Departement (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Intitule VARCHAR(100) NOT NULL UNIQUE,
  Chef_departement INT NULL
) ENGINE=InnoDB;

-- Table Employer (Employés)
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
) ENGINE=InnoDB;

-- Contrainte clé étrangère pour Chef_departement
ALTER TABLE Departement
  ADD CONSTRAINT fk_chef_dept FOREIGN KEY (Chef_departement) REFERENCES Employer(Id) ON DELETE SET NULL;

-- Table Projet
CREATE TABLE Projet (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Nom_projet VARCHAR(150) NOT NULL,
  Etat_projet VARCHAR(30) NOT NULL DEFAULT 'EN_COURS', -- EN_COURS, TERMINE, ANNULE, PAS_COMMENCE
  Date_debut DATE NOT NULL,
  Date_fin_prevue DATE,
  Date_fin_reelle DATE,
  Chef_projet INT,
  Id_departement INT,
  CONSTRAINT fk_chef_projet FOREIGN KEY (Chef_projet) REFERENCES Employer(Id) ON DELETE SET NULL,
  CONSTRAINT fk_projet_dept FOREIGN KEY (Id_departement) REFERENCES Departement(Id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table Affectation_projet (Many-to-Many : Employé <-> Projet)
CREATE TABLE Affectation_projet (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Id_employer INT NOT NULL,
  Id_projet INT NOT NULL,
  Date_affectation DATE NOT NULL,
  Date_fin_affectation DATE NULL,
  CONSTRAINT fk_affectation_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id) ON DELETE CASCADE,
  CONSTRAINT fk_affectation_projet FOREIGN KEY (Id_projet) REFERENCES Projet(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table Fiche_de_paie
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
  CONSTRAINT fk_fiche_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table Absence
CREATE TABLE Absence (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  Id_employer INT NOT NULL,
  Date_debut DATE NOT NULL,
  Date_fin DATE NOT NULL,
  Type_absence VARCHAR(50) NOT NULL, -- CONGE, MALADIE, ABSENCE_INJUSTIFIEE
  Motif TEXT NULL,
  CONSTRAINT fk_absence_employer FOREIGN KEY (Id_employer) REFERENCES Employer(Id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- INSERTION DES DONNÉES DE TEST
-- =====================================================

-- 1) DÉPARTEMENTS
INSERT INTO Departement (Id, Intitule, Chef_departement) VALUES
(1, 'DIRECTION GENERALE', NULL),
(2, 'RESSOURCES HUMAINES', NULL),
(3, 'INFORMATIQUE', NULL),
(4, 'FINANCE', NULL),
(5, 'MARKETING', NULL),
(6, 'COMMERCIAL', NULL),
(7, 'LOGISTIQUE', NULL);

-- 2) EMPLOYÉS
-- Mot de passe par défaut : 'password' hashé en SHA-256 = 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
-- Mot de passe admin : 'admin123' hashé en SHA-256 = 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9

INSERT INTO Employer (Id, Matricule, Nom, Prenom, Email, Telephone, Password, Poste, Grade, Salaire_base, Date_embauche, Id_departement, Role) VALUES
-- DIRECTION GÉNÉRALE (pas de chef de département car c'est la direction)
(1,  'EMP001', 'Admin',    'System',     'admin@cy-rh.local',           '0600000001', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Administrateur Système',      'DIRECTEUR', 80000.00, '2020-01-10', 1, 'ADMIN'),
(2,  'EMP002', 'Martin',   'Claire',     'claire.martin@cy-rh.local',   '0600000002', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Directrice Générale Adjointe','DIRECTEUR', 65000.00, '2021-03-01', 1, 'EMPLOYE'),
(3,  'EMP003', 'Rousseau', 'Jean',       'jean.rousseau@cy-rh.local',   '0600000003', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Directeur Stratégie',         'DIRECTEUR', 62000.00, '2021-05-15', 1, 'EMPLOYE'),

-- RESSOURCES HUMAINES
(4,  'EMP004', 'Durand',   'Sophie',     'sophie.durand@cy-rh.local',   '0600000004', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département RH',      'MANAGER',   45000.00, '2022-02-15', 2, 'CHEF_DEPT'),
(5,  'EMP005', 'Bernard',  'Lucas',      'lucas.bernard@cy-rh.local',   '0600000005', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chargé de Recrutement',       'CONFIRME',  32000.00, '2023-04-01', 2, 'EMPLOYE'),
(6,  'EMP006', 'Lefevre',  'Camille',    'camille.lefevre@cy-rh.local', '0600000006', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Gestionnaire Paie',           'CONFIRME',  33000.00, '2023-06-10', 2, 'EMPLOYE'),

-- INFORMATIQUE
(7,  'EMP007', 'Nguyen',   'Thierry',    'thierry.nguyen@cy-rh.local',  '0600000007', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département IT',      'MANAGER',   50000.00, '2021-09-01', 3, 'CHEF_DEPT'),
(8,  'EMP008', 'Ali',      'Karim',      'karim.ali@cy-rh.local',       '0600000008', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Projet IT',           'SENIOR',    42000.00, '2022-10-05', 3, 'CHEF_PROJET'),
(9,  'EMP009', 'Lopez',    'Maria',      'maria.lopez@cy-rh.local',     '0600000009', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Développeuse Full-Stack',     'CONFIRME',  35000.00, '2023-01-12', 3, 'EMPLOYE'),
(10, 'EMP010', 'Diallo',   'Amine',      'amine.diallo@cy-rh.local',    '0600000010', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Développeur Backend',         'JUNIOR',    30000.00, '2024-05-02', 3, 'EMPLOYE'),
(11, 'EMP011', 'Blanc',    'Thomas',     'thomas.blanc@cy-rh.local',    '0600000011', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Administrateur Réseau',       'SENIOR',    40000.00, '2022-08-20', 3, 'EMPLOYE'),
(12, 'EMP012', 'Chen',     'Li',         'li.chen@cy-rh.local',         '0600000012', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Développeuse Frontend',       'CONFIRME',  34000.00, '2023-09-15', 3, 'EMPLOYE'),

-- FINANCE
(13, 'EMP013', 'Petit',    'Nadia',      'nadia.petit@cy-rh.local',     '0600000013', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département Finance', 'MANAGER',   52000.00, '2020-11-23', 4, 'CHEF_DEPT'),
(14, 'EMP014', 'Rossi',    'Enzo',       'enzo.rossi@cy-rh.local',      '0600000014', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Comptable Principal',         'CONFIRME',  36000.00, '2022-06-15', 4, 'EMPLOYE'),
(15, 'EMP015', 'Girard',   'Elise',      'elise.girard@cy-rh.local',    '0600000015', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Analyste Financier',          'SENIOR',    38000.00, '2022-11-05', 4, 'EMPLOYE'),
(16, 'EMP016', 'Lemoine',  'Baptiste',   'baptiste.lemoine@cy-rh.local','0600000016', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Contrôleur de Gestion',       'CONFIRME',  35000.00, '2023-03-20', 4, 'EMPLOYE'),

-- MARKETING
(17, 'EMP017', 'Moreau',   'Eva',        'eva.moreau@cy-rh.local',      '0600000017', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département Marketing','MANAGER',  46000.00, '2021-02-10', 5, 'CHEF_DEPT'),
(18, 'EMP018', 'Cheikh',   'Omar',       'omar.cheikh@cy-rh.local',     '0600000018', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chargé Marketing Digital',    'JUNIOR',    29000.00, '2024-01-20', 5, 'EMPLOYE'),
(19, 'EMP019', 'Fournier', 'Sarah',      'sarah.fournier@cy-rh.local',  '0600000019', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Community Manager',           'CONFIRME',  31000.00, '2023-07-01', 5, 'EMPLOYE'),
(20, 'EMP020', 'Garcia',   'Pablo',      'pablo.garcia@cy-rh.local',    '0600000020', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Graphiste Designer',          'SENIOR',    37000.00, '2022-04-12', 5, 'EMPLOYE'),

-- COMMERCIAL
(21, 'EMP021', 'Bonnet',   'Julie',      'julie.bonnet@cy-rh.local',    '0600000021', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département Commercial','MANAGER', 48000.00, '2021-08-05', 6, 'CHEF_DEPT'),
(22, 'EMP022', 'Mercier',  'Antoine',    'antoine.mercier@cy-rh.local', '0600000022', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Projet Commercial',   'SENIOR',    41000.00, '2022-02-28', 6, 'CHEF_PROJET'),
(23, 'EMP023', 'Simon',    'Léa',        'lea.simon@cy-rh.local',       '0600000023', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Ingénieur Commercial',        'CONFIRME',  34000.00, '2023-05-10', 6, 'EMPLOYE'),
(24, 'EMP024', 'Roux',     'Maxime',     'maxime.roux@cy-rh.local',     '0600000024', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Commercial Terrain',          'JUNIOR',    28000.00, '2024-03-15', 6, 'EMPLOYE'),

-- LOGISTIQUE
(25, 'EMP025', 'Lambert',  'Isabelle',   'isabelle.lambert@cy-rh.local','0600000025', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Chef de Département Logistique','MANAGER', 44000.00, '2021-10-18', 7, 'CHEF_DEPT'),
(26, 'EMP026', 'Faure',    'Nicolas',    'nicolas.faure@cy-rh.local',   '0600000026', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Gestionnaire Stock',          'CONFIRME',  32000.00, '2023-02-20', 7, 'EMPLOYE'),
(27, 'EMP027', 'Gauthier', 'Chloe',      'chloe.gauthier@cy-rh.local',  '0600000027', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Coordinateur Transport',      'CONFIRME',  33000.00, '2023-08-12', 7, 'EMPLOYE'),
(28, 'EMP028', 'Perrin',   'Hugo',       'hugo.perrin@cy-rh.local',     '0600000028', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'Magasinier',                  'JUNIOR',    27000.00, '2024-06-01', 7, 'EMPLOYE');

-- Mise à jour des chefs de département (un chef par département UNIQUEMENT)
UPDATE Departement SET Chef_departement = 1  WHERE Id = 1; -- Direction Générale : Admin System (ADMIN)
UPDATE Departement SET Chef_departement = 4  WHERE Id = 2; -- RH : Sophie Durand (CHEF_DEPT)
UPDATE Departement SET Chef_departement = 7  WHERE Id = 3; -- IT : Thierry Nguyen (CHEF_DEPT)
UPDATE Departement SET Chef_departement = 13 WHERE Id = 4; -- Finance : Nadia Petit (CHEF_DEPT)
UPDATE Departement SET Chef_departement = 17 WHERE Id = 5; -- Marketing : Eva Moreau (CHEF_DEPT)
UPDATE Departement SET Chef_departement = 21 WHERE Id = 6; -- Commercial : Julie Bonnet (CHEF_DEPT)
UPDATE Departement SET Chef_departement = 25 WHERE Id = 7; -- Logistique : Isabelle Lambert (CHEF_DEPT)

-- 3) PROJETS
-- RÈGLE : Un projet appartient à UN département → seuls les employés de CE département peuvent y être affectés
-- RÈGLE : Si Id_departement = NULL → projet transversal, n'importe qui peut y participer
INSERT INTO Projet (Id, Nom_projet, Etat_projet, Date_debut, Date_fin_prevue, Date_fin_reelle, Chef_projet, Id_departement) VALUES
-- Projets INFORMATIQUE (département 3)
(1,  'Intranet RH',                'EN_COURS',      '2025-01-15', '2025-06-30', NULL,         8,  3), -- Chef: Karim (IT)
(2,  'Refonte Infrastructure',     'EN_COURS',      '2025-01-20', '2025-04-30', NULL,         8,  3), -- Chef: Karim (IT)
(3,  'Plateforme E-commerce',      'PAS_COMMENCE',  '2025-05-01', '2025-12-31', NULL,         7,  3), -- Chef: Thierry (IT)
(4,  'Formation Cybersécurité',    'TERMINE',       '2024-10-15', '2024-12-20', '2024-12-18', 7,  3), -- Chef: Thierry (IT)

-- Projets FINANCE (département 4)
(5,  'Migration Comptable ERP',    'EN_COURS',      '2025-02-01', '2025-08-31', NULL,         13, 4), -- Chef: Nadia (Finance)
(6,  'Audit Financier 2025',       'TERMINE',       '2024-11-01', '2025-01-31', '2025-01-28', 13, 4), -- Chef: Nadia (Finance)

-- Projets MARKETING (département 5)
(7,  'Site Vitrine Corporate',     'EN_COURS',      '2025-03-05', '2025-05-30', NULL,         17, 5), -- Chef: Eva (Marketing)
(8,  'Campagne Publicitaire Q2',   'PAS_COMMENCE',  '2025-04-01', '2025-06-30', NULL,         17, 5), -- Chef: Eva (Marketing)

-- Projets COMMERCIAL (département 6)
(9,  'CRM Commercial',             'EN_COURS',      '2025-02-10', '2025-07-15', NULL,         22, 6), -- Chef: Antoine (Commercial)

-- Projets LOGISTIQUE (département 7)
(10, 'Optimisation Supply Chain',  'EN_COURS',      '2025-03-01', '2025-09-30', NULL,         25, 7), -- Chef: Isabelle (Logistique)

-- Projet TRANSVERSAL (NULL = tout le monde peut participer)
(11, 'Transformation Digitale',    'EN_COURS',      '2025-01-10', '2025-12-31', NULL,         1,  NULL); -- Chef: Admin, projet transversal

-- 4) AFFECTATIONS EMPLOYÉ <-> PROJET
-- RÈGLE STRICTE : Seuls les employés du MÊME département que le projet peuvent y être affectés
-- EXCEPTION : Si projet.Id_departement = NULL, n'importe qui peut être affecté

INSERT INTO Affectation_projet (Id, Id_employer, Id_projet, Date_affectation, Date_fin_affectation) VALUES
-- Projet 1 : Intranet RH (département IT = 3)
(1,  8,  1, '2025-01-15', NULL), -- Karim (IT, chef projet)
(2,  9,  1, '2025-01-20', NULL), -- Maria (IT)
(3,  10, 1, '2025-02-01', NULL), -- Amine (IT)
(4,  12, 1, '2025-02-05', NULL), -- Li (IT)

-- Projet 2 : Refonte Infrastructure (département IT = 3)
(5,  8,  2, '2025-01-20', NULL), -- Karim (IT, chef projet)
(6,  9,  2, '2025-02-01', NULL), -- Maria (IT)
(7,  11, 2, '2025-02-01', NULL), -- Thomas (IT)

-- Projet 3 : Plateforme E-commerce (département IT = 3)
(8,  7,  3, '2025-05-01', NULL), -- Thierry (IT, chef projet)
(9,  10, 3, '2025-05-02', NULL), -- Amine (IT)
(10, 12, 3, '2025-05-02', NULL), -- Li (IT)

-- Projet 4 : Formation Cybersécurité - TERMINÉ (département IT = 3)
(11, 7,  4, '2024-10-15', '2024-12-18'), -- Thierry (IT, chef projet)
(12, 11, 4, '2024-10-15', '2024-12-18'), -- Thomas (IT)

-- Projet 5 : Migration Comptable ERP (département Finance = 4)
(13, 13, 5, '2025-02-01', NULL), -- Nadia (Finance, chef projet)
(14, 14, 5, '2025-02-10', NULL), -- Enzo (Finance)
(15, 15, 5, '2025-02-10', NULL), -- Elise (Finance)

-- Projet 6 : Audit Financier - TERMINÉ (département Finance = 4)
(16, 13, 6, '2024-11-01', '2025-01-28'), -- Nadia (Finance, chef projet)
(17, 14, 6, '2024-11-01', '2025-01-28'), -- Enzo (Finance)
(18, 16, 6, '2024-11-15', '2025-01-28'), -- Baptiste (Finance)

-- Projet 7 : Site Vitrine Corporate (département Marketing = 5)
(19, 17, 7, '2025-03-05', NULL), -- Eva (Marketing, chef projet)
(20, 18, 7, '2025-03-10', NULL), -- Omar (Marketing)
(21, 19, 7, '2025-03-10', NULL), -- Sarah (Marketing)
(22, 20, 7, '2025-03-12', NULL), -- Pablo (Marketing)

-- Projet 9 : CRM Commercial (département Commercial = 6)
(23, 22, 9, '2025-02-10', NULL), -- Antoine (Commercial, chef projet)
(24, 23, 9, '2025-02-15', NULL), -- Léa (Commercial)
(25, 24, 9, '2025-02-20', NULL), -- Maxime (Commercial)

-- Projet 10 : Optimisation Supply Chain (département Logistique = 7)
(26, 25, 10, '2025-03-01', NULL), -- Isabelle (Logistique, chef projet)
(27, 26, 10, '2025-03-05', NULL), -- Nicolas (Logistique)
(28, 27, 10, '2025-03-05', NULL), -- Chloe (Logistique)

-- Projet 11 : Transformation Digitale (TRANSVERSAL - département NULL)
-- Projet transversal : employés de TOUS les départements peuvent participer
(29, 1,  11, '2025-01-10', NULL), -- Admin (Direction, chef projet)
(30, 4,  11, '2025-01-15', NULL), -- Sophie (RH)
(31, 7,  11, '2025-01-15', NULL), -- Thierry (IT)
(32, 13, 11, '2025-01-15', NULL), -- Nadia (Finance)
(33, 17, 11, '2025-01-15', NULL), -- Eva (Marketing)
(34, 21, 11, '2025-01-15', NULL); -- Julie (Commercial)

-- 5) FICHES DE PAIE (Janvier et Février 2025)
INSERT INTO Fiche_de_paie (Id, Id_employer, Mois, Annee, Salaire_base, Primes, Deductions, Net_a_payer, Date_generation) VALUES
-- Janvier 2025
(1,  1,  1, 2025, 80000.00, 0.00,   0.00,   80000.00, '2025-01-31'),
(2,  2,  1, 2025, 65000.00, 500.00, 0.00,   65500.00, '2025-01-31'),
(3,  4,  1, 2025, 45000.00, 300.00, 0.00,   45300.00, '2025-01-31'),
(4,  7,  1, 2025, 50000.00, 400.00, 0.00,   50400.00, '2025-01-31'),
(5,  8,  1, 2025, 42000.00, 300.00, 50.00,  42250.00, '2025-01-31'),
(6,  9,  1, 2025, 35000.00, 150.00, 0.00,   35150.00, '2025-01-31'),
(7,  13, 1, 2025, 52000.00, 600.00, 0.00,   52600.00, '2025-01-31'),
(8,  14, 1, 2025, 36000.00, 0.00,   0.00,   36000.00, '2025-01-31'),
(9,  17, 1, 2025, 46000.00, 350.00, 0.00,   46350.00, '2025-01-31'),
(10, 21, 1, 2025, 48000.00, 800.00, 0.00,   48800.00, '2025-01-31'),

-- Février 2025
(11, 1,  2, 2025, 80000.00, 500.00, 0.00,   80500.00, '2025-02-28'),
(12, 2,  2, 2025, 65000.00, 0.00,   0.00,   65000.00, '2025-02-28'),
(13, 8,  2, 2025, 42000.00, 0.00,   0.00,   42000.00, '2025-02-28'),
(14, 9,  2, 2025, 35000.00, 0.00,   100.00, 34900.00, '2025-02-28'),
(15, 13, 2, 2025, 52000.00, 400.00, 0.00,   52400.00, '2025-02-28'),
(16, 17, 2, 2025, 46000.00, 200.00, 0.00,   46200.00, '2025-02-28'),
(17, 21, 2, 2025, 48000.00, 1000.00,0.00,   49000.00, '2025-02-28'),
(18, 5,  2, 2025, 32000.00, 0.00,   120.00, 31880.00, '2025-02-28');

-- 6) ABSENCES
INSERT INTO Absence (Id, Id_employer, Date_debut, Date_fin, Type_absence, Motif) VALUES
(1,  9,  '2025-02-12', '2025-02-14', 'MALADIE',              'Grippe saisonnière'),
(2,  18, '2025-03-18', '2025-03-19', 'CONGE',                'Congé exceptionnel mariage'),
(3,  5,  '2025-01-29', '2025-01-29', 'ABSENCE_INJUSTIFIEE',  'Retard non justifié'),
(4,  10, '2025-02-05', '2025-02-07', 'MALADIE',              'Gastro-entérite'),
(5,  23, '2025-03-10', '2025-03-14', 'CONGE',                'Congés payés'),
(6,  14, '2025-01-22', '2025-01-22', 'CONGE',                'Jour RTT'),
(7,  26, '2025-02-20', '2025-02-21', 'MALADIE',              'Angine'),
(8,  12, '2025-03-03', '2025-03-05', 'CONGE',                'Congé famille'),
(9,  19, '2025-02-26', '2025-02-26', 'ABSENCE_INJUSTIFIEE',  'Absence non justifiée'),
(10, 27, '2025-03-17', '2025-03-21', 'CONGE',                'Vacances');

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================

-- Vérification des données insérées
USE CY_RH;

SELECT * FROM Departement;
SELECT * FROM Employer;
SELECT * FROM Projet;
SELECT * FROM Affectation_projet;
SELECT * FROM Affectation_projet;
SELECT * FROM Fiche_de_paie;
SELECT * FROM Absence;