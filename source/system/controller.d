module indcms.system.controller;

import vibe.d;

import temple;

import std.stdio;

import indcms.system.addon;
import indcms.system.postgresql;
import indcms.system.system;
import indcms.system.models.index;


const string ADDON_NAME = "system";

//constructor of module
static this()
{
	new SystemController();
}

class SystemController: AddonController
{
	private IndexModel indexModel;

	this() {
		super(ADDON_NAME);
		System.setDBConncection(this.db);

		indexModel = new IndexModel();

		System.getRouter()
			.any("/", &indexModel.index);

		//funcsGlobalTempleVars ~= &this.toGlobalVars;
	}

	override
	{
		void install ()
		{
			super.install();
			string login, pass;
			try {
				writeln("For installing the system required permissions PostgreSQL superuser.");
				write("Login: ");
				login = stdin.readln().replace("\r", "").replace("\n", "");
				write("Password: ");
				pass = stdin.readln().replace("\r", "").replace("\n", "");
			}
			catch (Exception e)
			{
				writeln("Error: ", e.msg);
				stdin.readln();
			}
			PGConnection superUserCtn;
			try {
				superUserCtn = new PGConnection([
					"host" :  "localhost",
					"database" : "",
					"user" : login,
					"password" : pass
				]);
			} catch (ServerErrorException e) {
				logInfo(e.toString());
				stdin.readln();
				//exit;
			}
			this.initializeForDB(superUserCtn, "db.sql");
			this.initializeForDB(superUserCtn, "system_user.sql");
			superUserCtn.close();
			dbConnect();
			System.setDBConncection(this.db);
			this.initializeForDB("table.sql");
		}

		void toGlobalVars(TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
		{
		}
	}
}
