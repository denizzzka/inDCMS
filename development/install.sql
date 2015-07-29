/*
Created: 18.07.2015
Modified: 27.07.2015
Model: MySQL 5.6
Database: MySQL 5.6
*/


-- Create tables section -------------------------------------------------

-- Table users

CREATE TABLE `users`
(
  `idUser` Int NOT NULL AUTO_INCREMENT,
  `login` Varchar(20) NOT NULL,
  `password` Varchar(56) NOT NULL,
  `mail` Varchar(20) NOT NULL,
  `family` Varchar(20),
  `name` Varchar(20),
  `patronymic` Varchar(20),
  `aboutMyself` Varchar(250),
  `timeReg` Int UNSIGNED NOT NULL,
  PRIMARY KEY (`idUser`)
)
;

ALTER TABLE `users` ADD UNIQUE `login` (`login`)
;

ALTER TABLE `users` ADD UNIQUE `mail` (`mail`)
;

-- Table newUserOrPass

CREATE TABLE `newUserOrPass`
(
  `idNew` Int NOT NULL,
  `idUser` Int NOT NULL,
  `type` Varchar(20) NOT NULL,
  `isSuccess` Tinyint(1) NOT NULL DEFAULT 0,
  `confirmationCode` Varchar(30) NOT NULL,
  `timeQuery` Int UNSIGNED NOT NULL
)
;

CREATE INDEX `IX_Relationship1` ON `newUserOrPass` (`idUser`)
;

ALTER TABLE `newUserOrPass` ADD  PRIMARY KEY (`idNew`)
;

-- Table rightsUsers

CREATE TABLE `rightsUsers`
(
  `idRightUser` Int NOT NULL AUTO_INCREMENT,
  `idUser` Int NOT NULL,
  `idRightComponent` Int NOT NULL,
  `idComponent` Int NOT NULL,
  PRIMARY KEY (`idRightUser`)
)
;

CREATE INDEX `IX_Relationship2` ON `rightsUsers` (`idUser`)
;

CREATE INDEX `IX_Relationship6` ON `rightsUsers` (`idRightComponent`,`idComponent`)
;

-- Table components

CREATE TABLE `components`
(
  `idComponent` Int NOT NULL,
  `name` Varchar(20) NOT NULL,
  `version` Varchar(10)
)
;

ALTER TABLE `components` ADD  PRIMARY KEY (`idComponent`)
;

ALTER TABLE `components` ADD UNIQUE `name` (`name`)
;

-- Table rightsComponents

CREATE TABLE `rightsComponents`
(
  `idRightComponent` Int NOT NULL,
  `idComponent` Int NOT NULL,
  `nameSystem` Varchar(20) NOT NULL
 COMMENT 'only english',
  `descriptiveName` Varchar(20)
 COMMENT 'подробное имя (пример: Сисадмин)',
  `description` Varchar(255)
)
;

ALTER TABLE `rightsComponents` ADD  PRIMARY KEY (`idRightComponent`,`idComponent`)
;

ALTER TABLE `rightsComponents` ADD UNIQUE `nameSystem` (`nameSystem`)
;

-- Create relationships section ------------------------------------------------- 

ALTER TABLE `newUserOrPass` ADD CONSTRAINT `Relationship1` FOREIGN KEY (`idUser`) REFERENCES `users` (`idUser`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `rightsUsers` ADD CONSTRAINT `Relationship2` FOREIGN KEY (`idUser`) REFERENCES `users` (`idUser`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `rightsComponents` ADD CONSTRAINT `Relationship5` FOREIGN KEY (`idComponent`) REFERENCES `components` (`idComponent`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `rightsUsers` ADD CONSTRAINT `Relationship6` FOREIGN KEY (`idRightComponent`, `idComponent`) REFERENCES `rightsComponents` (`idRightComponent`, `idComponent`) ON DELETE RESTRICT ON UPDATE RESTRICT
;



/* registration of components */
INSERT INTO `components` (`idComponent`, `name`)
  VALUES  (0, 'global'),
          (1, 'users');

/* rights of components */
INSERT INTO `rightsComponents` (`idRightComponent`, `idComponent`, `nameSystem`)
  VALUES  (0, 0, 'admin'), /* администратор сайта */
          (1, 0, 'user');  /* обычный пользователь (по умолчанию) */   

/* admin, password=11111*/
INSERT INTO `users` (`idUser`, `login`, `password`, `mail`, `timeReg`)
  VALUES (0, 'userAdmin', 'DCA08C944A652FBF0131BF7B15ECD38FDE5539D5A6226171379A1816', 'admin@this.ru', UNIX_TIMESTAMP());

/* rights of admin */
INSERT INTO `rightsUsers` (`idRightUser`, `idUser`, `idRightComponent`, `idComponent`)
  VALUES (0, 0, 0, 0),
        (0, 0, 1, 0);