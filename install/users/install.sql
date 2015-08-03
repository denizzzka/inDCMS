/* in database user indicms_system */

-- Table users

CREATE TABLE "users"(
 "idUser" Serial NOT NULL,
 "login" Character varying(20) NOT NULL,
 "password" Character varying(56) NOT NULL,
 "mail" Character varying(20) NOT NULL,
 "family" Character varying(20),
 "name" Character varying(20),
 "patronymic" Character varying(20),
 "aboutMyself" Character varying(250),
 "regTime" Integer NOT NULL
);

-- Add keys for table users

ALTER TABLE "users" ADD CONSTRAINT "Key1" PRIMARY KEY ("idUser");
ALTER TABLE "users" ADD CONSTRAINT "login" UNIQUE ("login");
ALTER TABLE "users" ADD CONSTRAINT "mail" UNIQUE ("mail");

-- Table users_new

CREATE TABLE "users_new"(
 "idNew" Serial NOT NULL,
 "idUser" Integer NOT NULL,
 "type" Character varying(20) NOT NULL,
 "isSuccess" Boolean DEFAULT false NOT NULL,
 "confirmationCode" Character varying(30) NOT NULL,
 "queryTime" Integer NOT NULL
);

-- Create indexes for table users_new

CREATE INDEX "IX_Relationship1" ON "users_new" ("idUser");

-- Add keys for table users_new

ALTER TABLE "users_new" ADD CONSTRAINT "Key2" PRIMARY KEY ("idNew");

-- Table users_permissions

CREATE TABLE "users_permissions"(
 "idUserPermission" Serial NOT NULL,
 "idUser" Integer NOT NULL,
 "idAddonPermission" Integer,
 "idAddon" Integer
);

-- Create indexes for table users_permissions

CREATE INDEX "IX_Relationship2" ON "users_permissions" ("idUser");
CREATE INDEX "IX_Relationship5" ON "users_permissions" ("idAddonPermission","idAddon");

-- Add keys for table users_permissions

ALTER TABLE "users_permissions" ADD CONSTRAINT "Key3" PRIMARY KEY ("idUserPermission");

-- Create relationships section ------------------------------------------------- 

ALTER TABLE "users_permissions" ADD CONSTRAINT "Relationship2" FOREIGN KEY ("idUser")
	REFERENCES "users" ("idUser") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "users_new" ADD CONSTRAINT "Relationship1" FOREIGN KEY ("idUser")
	REFERENCES "users" ("idUser") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "users_permissions" ADD CONSTRAINT "Relationship5" FOREIGN KEY ("idAddonPermission", "idAddon")
	REFERENCES "addons_permissions" ("idAddonPermission", "idAddon") ON DELETE NO ACTION ON UPDATE NO ACTION;


-- create user

CREATE USER indcms_users WITH PASSWORD '1';
GRANT SELECT ON TABLE addons TO indcms_users;
GRANT SELECT, UPDATE, INSERT, DELETE, TRUNCATE ON TABLE "users", "users_new", "users_permissions", "addons_permissions"  TO indcms_users;

-- admin, password=11111
INSERT INTO "users" ("login", "password", "mail", "regTime")
  VALUES ('userAdmin', 'DCA08C944A652FBF0131BF7B15ECD38FDE5539D5A6226171379A1816', 'admin@this.ru', 0 /* timestamp on postgreSQL or unix timestamp */);

-- permissions of admin
INSERT INTO "users_permissions" ("idUser", "idAddonPermission", "idAddon")
  VALUES (1, 1, 1),
        (1, 2, 1);