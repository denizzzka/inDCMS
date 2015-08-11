module indcms.users.models.profiles;

import vibe.d;

import temple;

import std.stdio;
import std.variant;
import std.digest.digest;

import indcms.system.addon;
import indcms.system.postgresql;
static import funcs = indcms.system.functions;
import indcms.users.users;

class ProfilesModel: AddonModel {
	private PGConnection db;
	
	this(PGConnection db)
	{
		this.db = db;
	}

	void userProfile(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (!Users.isAutho(req))
		{
			res.redirect("/");
			return;
		}
		auto tlate = compile_temple_file!("users.profile.dte");
		auto context = new TempleContext();
		context.title = "Профиль пользователя " ~ funcs.htmlspecialchars(req.params["profileLogin"]);
		string eProfileLogin = PgSQL.escape(req.params["profileLogin"]);

		if (db.executeScalar!long(`SELECT COUNT(*) FROM "users" WHERE "login" = ` ~ eProfileLogin) == 0)
		{
			context.isProfile = false;
			context.error = "Пользователь с данным логином не существует.";
		}
		else
		{
			auto row = db.executeRow(`
				SELECT "name", "family", "patronymic", "aboutMyself", "mail", "regTime"
				FROM "users" WHERE "login" = ` ~ eProfileLogin ~ `
			`);
			context.isProfile = true;
			context.profileName = funcs.htmlspecialchars(row[0] == null ? "" : row[0].get!string);
			context.profileFamily = funcs.htmlspecialchars(row[1] == null ? "" : row[1].get!string);
			context.profilePatronymic = funcs.htmlspecialchars(row[2] == null ? "" : row[2].get!string);
			context.profileAbout = funcs.htmlspecialchars(row[3] == null ? "" : row[3].get!string);
			context.profileMail = funcs.htmlspecialchars(row[4].get!string);
			//context.profileDate = 
		}
		context.isAutho = Users.isAutho(req);
		context.profileLogin = req.params["profileLogin"];

		render(tlate, context, req, res);
	}

}