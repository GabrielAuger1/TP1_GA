CREATE TABLE BO.LIVRES (
    ID NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    SECTIONS_ID NUMBER(3),
    AUTEURS_ID NUMBER(10),
    GENRES_ID NUMBER(10)

 );

CREATE TABLE BO.MEMBRES (
    ID NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    CODE CHAR(12),
    PRENOM VARCHAR2(100),
    NOM VARCHAR2(100),
    GENRE CHAR(1),
    DATE_NAISSANCE DATE,
    COURRIEL VARCHAR2(50),
    ADRESSE_LIGNE1 VARCHAR2(50),
    ADRESSE_LIGNE2 VARCHAR2(50),
    VILLE VARCHAR2(50),
    PROVINCE CHAR(50),
    CODE_POSTAL VARCHAR2(50),
    PAYS VARCHAR2(50),
    TELEPHONE VARCHAR2(50),
    DATE_DEBUT_MEMBRE DATE,
    STATUT_MEMBRE VARCHAR2(15),
    THEME_PREFERE VARCHAR2(15)
);

CREATE TABLE BO.EMPRUNTS (
    ID NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    LIVRES_ID NUMBER(10),
    MEMBRES_ID NUMBER(10),
    DATE_EMPRUNT DATE,
    DATE_RETOUR_PREVU DATE,
    DATE_RETOUR DATE
);

CREATE TABLE BO.GENRES (
    ID NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    NOM_GENRE VARCHAR2(50)
);

CREATE TABLE BO.AUTEURS (
    ID NUMBER(10) GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    NOM_AUTEUR VARCHAR2(50)
);

CREATE TABLE BO.SECTIONS (
    ID NUMBER(3) PRIMARY KEY,
    NOM VARCHAR2(100),
    DESCRIPTION VARCHAR2(255)
);

ALTER TABLE BO.MEMBRES ADD CONSTRAINT CODE_UK UNIQUE (CODE);

ALTER TABLE BO.EMPRUNTS ADD CONSTRAINT EMPRUNTS_FK1 FOREIGN KEY (LIVRES_ID) REFERENCES BO.LIVRES(ID);
ALTER TABLE BO.EMPRUNTS ADD CONSTRAINT EMPRUNTS_FK2 FOREIGN KEY (MEMBRES_ID) REFERENCES BO.MEMBRES(ID);

ALTER TABLE BO.GENRES ADD CONSTRAINT GENRES_NOM_I UNIQUE (NOM_GENRE);

ALTER TABLE BO.SECTIONS ADD CONSTRAINT SECTIONS_NOM_I UNIQUE (DESCRIPTION);

ALTER TABLE BO.LIVRES ADD CONSTRAINT LIVRES_FK1 FOREIGN KEY (SECTIONS_ID) REFERENCES BO.SECTIONS(ID);
ALTER TABLE BO.LIVRES ADD CONSTRAINT LIVRES_FK2 FOREIGN KEY (AUTEURS_ID) REFERENCES BO.AUTEURS(ID);
--ALTER TABLE BO.LIVRES ADD CONSTRAINT LIVRES_FK2 FOREIGN KEY (GENRES_ID) REFERENCES BO.GENRES(ID);

ALTER TABLE BO.LIVRES ADD ISBN VARCHAR2(20);
ALTER TABLE BO.LIVRES ADD TITRE VARCHAR2(100);
ALTER TABLE BO.LIVRES ADD MAISON_EDITION VARCHAR2(100);
ALTER TABLE BO.LIVRES ADD ANNEE_PUBLICATION NUMBER(4);
ALTER TABLE BO.LIVRES ADD LANGAGE VARCHAR2(50);
ALTER TABLE BO.LIVRES ADD PRIX NUMBER(5,2);

COMMIT;