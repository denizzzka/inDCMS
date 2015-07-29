/*
Created: 18.07.2015
Modified: 30.07.2015
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
  `regTime` Int UNSIGNED NOT NULL,
  PRIMARY KEY (`idUser`)
)
 AUTO_INCREMENT = 1
;

ALTER TABLE `users` ADD UNIQUE `login` (`login`)
;

ALTER TABLE `users` ADD UNIQUE `mail` (`mail`)
;

-- Table users_new

CREATE TABLE `users_new`
(
  `idNew` Int NOT NULL,
  `idUser` Int NOT NULL,
  `type` Varchar(20) NOT NULL,
  `isSuccess` Tinyint(1) NOT NULL DEFAULT 0,
  `confirmationCode` Varchar(30) NOT NULL,
  `queryTime` Int UNSIGNED NOT NULL
)
 AUTO_INCREMENT = 1
;

CREATE INDEX `IX_Relationship1` ON `users_new` (`idUser`)
;

ALTER TABLE `users_new` ADD  PRIMARY KEY (`idNew`)
;

-- Table users_permissions

CREATE TABLE `users_permissions`
(
  `idUserPermission` Int NOT NULL AUTO_INCREMENT,
  `idUser` Int NOT NULL,
  `idComponentPermission` Int NOT NULL,
  `idComponent` Int NOT NULL,
  PRIMARY KEY (`idUserPermission`)
)
 AUTO_INCREMENT = 1
;

CREATE INDEX `IX_Relationship2` ON `users_permissions` (`idUser`)
;

CREATE INDEX `IX_Relationship6` ON `users_permissions` (`idComponentPermission`,`idComponent`)
;

-- Table components

CREATE TABLE `components`
(
  `idComponent` Int NOT NULL AUTO_INCREMENT,
  `name` Varchar(20) NOT NULL,
  `version` Varchar(10),
  PRIMARY KEY (`idComponent`)
)
 AUTO_INCREMENT = 1
;

ALTER TABLE `components` ADD UNIQUE `name` (`name`)
;

-- Table components_permissions

CREATE TABLE `components_permissions`
(
  `idComponentPermission` Int NOT NULL AUTO_INCREMENT,
  `idComponent` Int NOT NULL,
  `systemName` Varchar(20) NOT NULL
 COMMENT 'only english',
  `descriptiveName` Varchar(20)
 COMMENT 'подробное имя (пример: Сисадмин)',
  `description` Varchar(255),
  PRIMARY KEY (`idComponentPermission`,`idComponent`)
)
 AUTO_INCREMENT = 1
;

ALTER TABLE `components_permissions` ADD UNIQUE `nameSystem` (`systemName`)
;

-- Create relationships section ------------------------------------------------- 

ALTER TABLE `users_new` ADD CONSTRAINT `Relationship1` FOREIGN KEY (`idUser`) REFERENCES `users` (`idUser`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `users_permissions` ADD CONSTRAINT `Relationship2` FOREIGN KEY (`idUser`) REFERENCES `users` (`idUser`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `components_permissions` ADD CONSTRAINT `Relationship5` FOREIGN KEY (`idComponent`) REFERENCES `components` (`idComponent`) ON DELETE RESTRICT ON UPDATE RESTRICT
;

ALTER TABLE `users_permissions` ADD CONSTRAINT `Relationship6` FOREIGN KEY (`idComponentPermission`, `idComponent`) REFERENCES `components_permissions` (`idComponentPermission`, `idComponent`) ON DELETE RESTRICT ON UPDATE RESTRICT
;



/* registration of components */
INSERT INTO `components` (`name`)
  VALUES  ('global'),
          ('users');

/* permissions for components */
INSERT INTO `components_permissions` (`idComponent`, `systemName`)
  VALUES  (1, 'admin'), /* администратор сайта */
          (1, 'user');  /* обычный пользователь (по умолчанию) */   

/* admin, password=11111*/
INSERT INTO `users` (`login`, `password`, `mail`, `regTime`)
  VALUES ('userAdmin', 'DCA08C944A652FBF0131BF7B15ECD38FDE5539D5A6226171379A1816', 'admin@this.ru', UNIX_TIMESTAMP());

/* permissions of admin */
INSERT INTO `users_permissions` (`idUser`, `idComponentPermission`, `idComponent`)
  VALUES (1, 1, 1),
        (1, 2, 1);