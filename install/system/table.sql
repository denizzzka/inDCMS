-- Table addons

CREATE TABLE "addons"(
 "idAddon" Serial NOT NULL,
 "name" Character varying(20) NOT NULL,
 "version" Character varying(10)
);

-- Add keys for table addons

ALTER TABLE "addons" ADD CONSTRAINT "Key4" PRIMARY KEY ("idAddon");
ALTER TABLE "addons" ADD CONSTRAINT "name" UNIQUE ("name");

-- Table addons_permissions

CREATE TABLE "addons_permissions"(
 "idAddonPermission" Serial NOT NULL,
 "idAddon" Integer NOT NULL,
 "systemName" Character varying(20) NOT NULL,
 "descriptiveName" Character varying(20),
 "description" Character varying(255)
);
COMMENT ON COLUMN "addons_permissions"."descriptiveName" IS 'подробное имя (пример: Сисадмин)';

-- Add keys for table addons_permissions

ALTER TABLE "addons_permissions" ADD CONSTRAINT "Key5" PRIMARY KEY ("idAddonPermission","idAddon");
ALTER TABLE "addons_permissions" ADD CONSTRAINT "systemName" UNIQUE ("systemName");
ALTER TABLE "addons_permissions" ADD CONSTRAINT "onlyNumberAndLatin" CHECK ("systemName" ~ '^[\da-zA-Z_-]+$'); -- POSIX regular Expression

-- Create relationships section ------------------------------------------------- 

ALTER TABLE "addons_permissions" ADD CONSTRAINT "Relationship4" FOREIGN KEY ("idAddon")
	REFERENCES "addons" ("idAddon") ON DELETE NO ACTION ON UPDATE NO ACTION;


-- registration of addons
INSERT INTO "addons" ("name")
  VALUES  ('system'),
          ('users');
 