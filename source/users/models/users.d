module indcms.users.models.users;

import vibe.d;

import temple;

import std.stdio;
import std.variant;
import std.digest.digest;

import indcms.system.addon;
import indcms.system.postgresql;
static import funcs = indcms.system.functions;
import indcms.users.users;

class UsersModel: AddonModel {
	private PGConnection db;

	this(PGConnection db)
	{
		this.db = db;
	}

	string getLogin (HTTPServerRequest req)
	{
		return Users.isAutho(req) ? req.session.get!string("userLogin") : "Гость";
	}


	void userIn(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (Users.isAutho(req))
		{
			res.redirect("/");
			return;
		}
		auto tlate = compile_temple_file!("users.in.dte");
		auto context = new TempleContext();
		FormFields form = req.form;
		context.title = "Авторизация";
		context.isAutho = false;

		if (funcs.inArray(["login", "pass"], form))
		{
			string escapeLogin = PgSQL.escape(form["login"]);
			try {
				if (db.executeScalar!long(
						`SELECT COUNT(*) FROM "users"
							WHERE "login" = ` ~ escapeLogin ~
							`AND "password" = ` ~ PgSQL.escape(toHexString(Users.encryptionPass(form["pass"])))
						) > 0
					)
				{
					context.isAutho = true;
					auto session = res.startSession();
					session.set("userLogin", form["login"]);
					auto rows = db.executeQuery(`
						SELECT "systemName" FROM "users"
						LEFT JOIN "users_permissions" USING("idUser")
						LEFT JOIN "addons_permissions" USING("idAddonPermission")
						WHERE "login" = ` ~ escapeLogin);
					foreach (row; rows)
					{
						Users.addPermission(session, row[0].get!string);
					}
					rows.close();
					res.headers["Refresh"] =  "5; URL=/";
					context.success = "Вы успешно авторизированы.\n"
						~ `Через 5 сек. вы будете перенаправлены на <a href="/">главную страницу</a>`;
				}
				else
				{
					context.error = "Неверный логин или пароль";
				}
			} catch (ServerErrorException e) {
				context.error = "Ошибка входа";
				logInfo(e.toString());
			} catch(ParamException e) {
				context.error = "Ошибка входа";
				logInfo(e.toString());
			}
		}
		render(tlate, context, req, res);
	}


	void userOut(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (req.session)
			res.terminateSession(); // мочим сессию
		res.redirect("/");
	}

	void userReg(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto tlate = compile_temple_file!("users.reg.dte");
		auto context = new TempleContext();
		context.title = "Регистрация";
		context.isNewReg = false;

		FormFields form = req.method == HTTPMethod.GET ? req.query : req.form;
		if (funcs.inArray(["login", "pass", "pass2", "mail"], form))
		{
			if (!funcs.isRegexMatch("^[\\da-z_-]{4,20}$", form["login"], "i"))
				context.error = "Логин имеет неверный формат.\n";
			else if (form["pass"].length < 5 || form["pass"].length > 20)
				context.error = "Неверная длина пароля";	
			else if (form["pass"] != form["pass2"])
				context.error = "Пароли должны совпадать.\n";
			else if (form["mail"].length < 7 || form["mail"].length > 20)
				context.error = "Неверная длина e-mail";
			else if (db.executeScalar!int(`SELECT COUNT(*) FROM "users" WHERE "login"=` ~ PgSQL.escape(form["login"])) > 0)
				context.error = "Пользователь с данным логином уже существует";
			else if (db.executeScalar!int(`SELECT COUNT(*) FROM "users" WHERE "mail"=` ~ PgSQL.escape(form["mail"])) > 0)
				context.error = "Пользователь с данным e-mail уже существует";
			else
			{
				try {
					db.executeNonQuery(`
						INSERT INTO "users" ("login", "password", "mail", "regTime")
						VALUES(
							` ~ PgSQL.escape(form["login"]) ~ ",
							" ~ PgSQL.escape(toHexString(Users.encryptionPass(form["pass"]))) ~ ",
							" ~ PgSQL.escape(form["mail"]) ~ `,
							CURRENT_TIMESTAMP
						);`);
					db.executeNonQuery(`
						INSERT INTO "users_permissions" ("idUser", "idAddonPermission", "idAddon")
						VALUES(
							(SELECT "idUser" FROM "users" WHERE "login" = ` ~ PgSQL.escape(form["login"]) ~ " LIMIT 1),
 							2, 
							1
						);"
					); // user for all system
					res.headers["Refresh"] =  "5; URL=./profile/" ~ form["login"];
					context.success = "Вы успешно зарегистрированы.\n"
						~ `Через 5 сек. вы будете перенаправлены в свой <a href="./profile/` ~ form["login"] ~ `">профиль</a>`;
					// new session
					auto session = res.startSession();
					session.set("userLogin", form["login"]);
					Users.addPermission(session, "user");
					context.isNewReg = true;

				} catch (ServerErrorException e) {
					context.error = "Ошибка на сервере при регистрации";
					logInfo(e.toString());
				}
			}
		}
	    
		render(tlate, context, req, res);
	}

}