/* SUPERUSER */

-- system user

CREATE USER indcms_system WITH PASSWORD '1' CREATEROLE;

-- database

CREATE DATABASE indcms
  WITH ENCODING = 'UTF8'
       LC_COLLATE = 'Russian_Russia.1251'
       LC_CTYPE = 'Russian_Russia.1251'
       CONNECTION LIMIT = -1;

GRANT CONNECT, TEMPORARY ON DATABASE indcms TO public;
GRANT ALL PRIVILEGES ON DATABASE indcms TO indcms_system;


-- Table addons

CREATE TABLE "addons"(
 "idAddon" Serial NOT NULL,
 "name" Character varying(20) NOT NULL,
 "version" Character varying(10)
)
;

-- Add keys for table addons

ALTER TABLE "addons" ADD CONSTRAINT "Key4" PRIMARY KEY ("idAddon")
;

ALTER TABLE "addons" ADD CONSTRAINT "name" UNIQUE ("name")
;

-- Table addons_permissions

CREATE TABLE "addons_permissions"(
 "idAddonPermission" Serial NOT NULL,
 "idAddon" Integer NOT NULL,
 "systemName" Character varying(20) NOT NULL,
 "descriptiveName" Character varying(20),
 "description" Character varying(255)
);
COMMENT ON COLUMN "addons_permissions"."systemName" IS 'only english';
COMMENT ON COLUMN "addons_permissions"."descriptiveName" IS 'подробное имя (пример: Сисадмин)';

-- Add keys for table addons_permissions

ALTER TABLE "addons_permissions" ADD CONSTRAINT "Key5" PRIMARY KEY ("idAddonPermission","idAddon");
ALTER TABLE "addons_permissions" ADD CONSTRAINT "nameSystem" UNIQUE ("systemName");

-- Create relationships section ------------------------------------------------- 

ALTER TABLE "addons_permissions" ADD CONSTRAINT "Relationship4" FOREIGN KEY ("idAddon")
	REFERENCES "addons" ("idAddon") ON DELETE NO ACTION ON UPDATE NO ACTION;


-- registration of addons
INSERT INTO "addons" ("name")
  VALUES  ('system'),
          ('users');

-- permissions for addons
INSERT INTO "addons_permissions" ("idAddon", "systemName")
  VALUES  (1, 'admin'), /* администратор сайта */
          (1, 'user');  /* обычный пользователь (по умолчанию) */  