module indcms.system.addon;

import vibe.d;

import temple;

import std.file;
import std.json;
import std.path;
import std.stdio;

import funcs = indcms.system.functions;
import indcms.system.postgresql;
import indcms.system.system;


static void delegate(TempleContext, HTTPServerRequest, HTTPServerResponse)[] funcsGlobalTempleVars;


abstract class AddonController
{
protected:
	const string addonName;
	JSONValue jsonConf;
	PGConnection db;
	bool isDBConnection = false;

	this (in string addonName, bool autoDBConnection = false)
	{
		this.addonName = addonName;
		string path = "./source/";
		string strAddonsConf;
		string pathToJsonAddons = path ~ "/addons.json";
		string pathToJsonAddon = path ~ this.addonName ~ "/conf.json";
		try {
			if (!exists(pathToJsonAddons))
			{
				logInfo("Not configuration file \"addons.json\"");
				return;
			}
			else if(!exists(pathToJsonAddon))
			{
				logInfo("Not configuration file for addon \"" ~ this.addonName ~ "\"");
				return;
			}
			jsonConf = parseJSON(readText(pathToJsonAddon));
			JSONValue jAddons = parseJSON(readText(pathToJsonAddons));

			if (this.addonName !in jAddons)
			{
				jAddons[this.addonName] = JSONValue
				([
					"install": "true",
					"version": jsonConf["version"].str
				]);
				this.install();
			}
			else if("unistall" in jAddons[this.addonName] && jAddons[this.addonName].str == "true")
			{
				this.uninstall();
			}
			else // upgrade
			{

			}

			if (autoDBConnection && !isDBConnection) dbConnect();
			// saving
			std.file.write(pathToJsonAddons, jAddons.toString().replace(",", ",\n"));
		} catch (JSONException e) {
			logInfo(e.toString());
		} catch (FileException e) {
			logInfo(e.toString());
		}
	}

	void dbConnect ()
	{
		try {
			auto dbconf = jsonConf["dbconf"];
			db = new PGConnection([
					"host" :  dbconf["host"].str,
					"database" : dbconf["database"].str,
					"user" : PgSQL.role(dbconf.object["user"].str),
					"password" : dbconf.object["password"].str
				]);
			this.isDBConnection = true;
		} catch (JSONException e) {
			logInfo(e.toString());
		} catch (ServerErrorException e) {
			logInfo(e.toString());
		}
	}

	void install ()
	{
		logInfo(`Install addon "` ~ this.addonName ~ `"`);
	}

	void initializeForDB (PGConnection db, in string fileName = "install.sql")
	{
		try {
			string[] sql = readText("./install/" ~ addonName ~ "/" ~ fileName).split(";");
			auto cmd = new PGCommand(db);
			foreach(value; sql)
			{
				cmd.query = value;
				cmd.executeNonQuery;
			}
		} catch (ServerErrorException e) {
			logInfo(e.toString());
		} catch (FileException e) {
			logInfo(e.toString());
		}
	}
	void initializeForDB (in string fileName = "install.sql")
	{
		initializeForDB(System.getDBConncection(), fileName);
	}

	void uninstall ()
	{
		logInfo("Uninstall addon \"" ~ this.addonName ~ "\"");
	}

	void upgrade ()
	{
		logInfo("Upgrade addon \"" ~ this.addonName ~ "\"");
	}


	void toGlobalVars(TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
	{
	}
}


abstract class AddonModel
{

	protected void globalVarsContext(TempleContext context)
	{
		if (context.isSet("error"))
		{
			string str = context.error.toString();
			if (str != "") context.error = funcs.nl2br(str);
		}
		else
			context.error = null;
		
		if (context.isSet("success"))
		{
			string str = context.success.toString();
			if (str != "") context.success = funcs.nl2br(str);
		}
		else
			context.success = null;
	}

	protected void render(CompiledTemple tlate, TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
	{
		globalVarsContext(context);
		foreach(void delegate(TempleContext, HTTPServerRequest, HTTPServerResponse) f; funcsGlobalTempleVars)
			f(context, req, res);
		tlate.render(res.bodyWriter, context);
	}
}