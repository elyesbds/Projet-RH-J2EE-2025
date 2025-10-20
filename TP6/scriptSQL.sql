
USE BDD_Cinema;

DROP TABLE IF EXISTS projection;
DROP TABLE IF EXISTS cinema;
DROP TABLE IF EXISTS jouer;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS individu;

CREATE TABLE individu(
  num_ind INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(30),
  prenom VARCHAR(30)
);

CREATE TABLE film(
  num_film INT PRIMARY KEY AUTO_INCREMENT,
  num_ind INT,
  titre VARCHAR(60),
  genre VARCHAR(20),
  annee INT,
  FOREIGN KEY (num_ind) REFERENCES individu(num_ind)
);

CREATE TABLE jouer(
  num_ind INT,
  num_film INT,
  rolee VARCHAR(30),
  PRIMARY KEY (num_ind, num_film),
  FOREIGN KEY (num_ind) REFERENCES individu(num_ind),
  FOREIGN KEY (num_film) REFERENCES film(num_film)
);

CREATE TABLE cinema(
  num_cine INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(30),
  adresse VARCHAR(50)
);

CREATE TABLE projection(
  num_cine INT,
  num_film INT,
  pdate DATE,
  PRIMARY KEY (num_cine, num_film, pdate),
  FOREIGN KEY (num_cine) REFERENCES cinema(num_cine),
  FOREIGN KEY (num_film) REFERENCES film(num_film)
);


insert into individu values(01,'Kidman','Nicole'); 
insert into individu values(02,'Bettany','Paul');
insert into individu values(03,'Watson','Emily'); 
insert into individu values(04,'Skarsgard','Stellan'); 
insert into individu values(05,'Travolta','John'); 
insert into individu values(06,'L. Jackson','Samuel'); 
insert into individu values(07,'Willis','Bruce');
insert into individu values(08,'Irons','Jeremy');
insert into individu values(09,'Spader','James');
insert into individu values(10,'Hunter','Holly'); 
insert into individu values(11,'Arquette','Rosanna'); 
insert into individu values(12,'Wayne','John');
insert into individu values(13,'von Trier','Lars'); 
insert into individu values(14,'Tarantino','Quentin'); 
insert into individu values(15,'Cronenberg','David'); 
insert into individu values(16,'Mazursky','Paul'); 
insert into individu values(17,'Jones','Grace');
insert into individu values(18,'Glen','John');

insert into film values(05,13,'Dogville','Drame',2002);
insert into film values(04,13,'Breaking the waves','Drame',1996);
insert into film values(03,14,'Pulp Fiction','Policier',1994);
insert into film values(02,15,'Faux-Semblants','Epouvante',1988);
insert into film values(01,15,'Crash','Drame',1996);
insert into film values(06,12,'Alamo','Western',1960);
insert into film values(07,18,'Dangereusement vôtre','Espionnage',1985);

insert into jouer values(01,05,'Grace');
insert into jouer values(02,05,'Tom Edison'); 
insert into jouer values(03,04,'Bess');
insert into jouer values(04,04,'Jan');
insert into jouer values(05,03,'Vincent Vega');
insert into jouer values(06,03,'Jules Winnfield');
insert into jouer values(07,03,'Butch Coolidge');
insert into jouer values(08,02,'Beverly "&" Elliot Mantle');
insert into jouer values(09,01,'James Ballard');
insert into jouer values(10,01,'Helen Remington');
insert into jouer values(11,01,'Gabrielle');
insert into jouer values(04,05,'Chuck');
insert into jouer values(16,07,'May Day');

insert into cinema values(02,'Le Fontenelle','78160 Marly-le-Roi');
insert into cinema values(01,'Le Renoir','13100 Aix-en-Provence');
insert into cinema values(03,'Gaumont Wilson','31000 Toulouse');
insert into cinema values(04,'Espace Ciné','93800 Epinay-sur-Seine');


insert into projection values(02,05,'2002-05-01');
insert into projection values(02,05,'2002-05-02');
insert into projection values(02,05,'2002-05-03');
insert into projection values(02,04,'1996-12-02');
insert into projection values(01,01,'1996-05-07');
insert into projection values(02,07,'1985-05-09');
insert into projection values(01,04,'1996-08-02');
insert into projection values(04,03,'1994-04-08');
insert into projection values(03,06,'1990-12-02');
insert into projection values(02,02,'1990-09-25');
insert into projection values(03,03,'1994-11-05');
insert into projection values(04,03,'1994-11-06');
insert into projection values(01,06,'1980-07-05');
insert into projection values(02,04,'1996-09-02');
insert into projection values(04,06,'2002-08-01');
insert into projection values(03,06,'1960-11-09');
insert into projection values(01,02,'1988-03-12');
