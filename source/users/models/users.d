module inDCMS.users.models.users;
import vibe.d;
import temple;
import std.stdio;
import std.variant;
import std.digest.digest;
import mysql.connection;
import inDCMS.MySQL;
import inDCMS.functions;
import inDCMS.users.controller;

class ModelUsers {
	private MySQL db;

	this(MySQL db) {
		this.db = db;
	}

	string getLogin (HTTPServerRequest req)
	{
		return funcs.isAuthorized(req) ? req.session.get!string("userLogin") : "Гость";
	}


	void userIn(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (funcs.isAuthorized(req))
		{
			res.redirect("/");
			return;
		}
		auto tlate = compile_temple_file!("users.in.dte");
		auto context = new TempleContext();
		FormFields form = req.form;
		context.title = "Авторизация";
		context.isAutho = false;

		if (funcs.in_array(["login", "pass"], form))
		{
			string escapeLogin = db.escapeStr(form["login"]);
			try{
				if (db.queryScalar("SELECT COUNT(*) FROM `users` WHERE `login` = '" ~ escapeLogin ~ "'").get!long > 0)
				{
					context.isAutho = true;
					auto session = res.startSession();
					session.set("userLogin", form["login"]);
					auto rows = db.query("
						SELECT `nameSystem` FROM `users`
						LEFT JOIN `rightsUsers` USING(`idUser`)
						LEFT JOIN `rightsComponents` USING(`idRightComponent`)
						WHERE `login` = '" ~ escapeLogin ~ "'");
					foreach (Row value; rows)
						funcs.addRight(session, value[0].get!string);
					res.headers["Refresh"] =  "5; URL=/";
					context.success = "Вы успешно авторизированы.\nЧерез 5 сек. вы будете перенаправлены на <a href=\"/\">главную страницу</a>";
				}
			} catch (MySQLException e) {
				context.error = "Ошибка входа";
			}
		}
		funcs.render(tlate, context, req, res);
	}


	void userProfile(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (!funcs.isAuthorized(req))
		{
			res.redirect("/");
			return;
		}
		auto tlate = compile_temple_file!("users.profile.dte");
		auto context = new TempleContext();
		context.title = "Профиль пользователя " ~ funcs.htmlspecialchars(req.params["profileLogin"]);

		auto rows = db.query("SELECT `name`, `family`, `patronymic`, `aboutMyself`, `mail`, `timeReg` FROM `users` WHERE `login` = '" ~ db.escapeStr(req.params["profileLogin"]) ~ "' limit 1");
		if (rows.length == 0)
		{
			context.isProfile = false;
			context.error = "Пользователь с данным логином не существует.";
		}
		else
		{
			context.isProfile = true;
			auto row = rows[0];
			context.profileName = funcs.htmlspecialchars(row.isNull(0) ? "" : row[0].get!string);
			context.profileFamily = funcs.htmlspecialchars(row.isNull(1) ? "" : row[1].get!string);
			context.profilePatronymic = funcs.htmlspecialchars(row.isNull(2) ? "" : row[2].get!string);
			context.profileAbout = funcs.htmlspecialchars(row.isNull(3) ? "" : row[3].get!string);
			context.profileMail = funcs.htmlspecialchars(row[4].get!string);
			//context.profileDate = 
		}
		context.isAutho = funcs.isAuthorized(req);
		context.profileLogin = req.params["profileLogin"];

		funcs.render(tlate, context, req, res);
	}


	void userOut(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (req.session) res.terminateSession(); // мочим сессию
		res.redirect("/");
	}

	void userReg(HTTPServerRequest req, HTTPServerResponse res)
	{
	    auto tlate = compile_temple_file!("users.reg.dte");
	    auto context = new TempleContext();
		context.title = "Регистрация";
		context.isNewReg = false;

		FormFields form = req.method == HTTPMethod.GET ? req.query : req.form;
		if (funcs.in_array(["login", "pass", "pass2", "mail"], form))
		{
			if (!funcs.isRegexMatch("^[\\da-z_-]{4,20}$", form["login"], "i"))
				context.error = "Логин имеет неверный формат.\n";
			else if (form["pass"].length < 5 || form["pass"].length > 20)
				context.error = "Неверная длина пароля";	
			else if (form["pass"] != form["pass2"])
				context.error = "Пароли должны совпадать.\n";
			else if (form["mail"].length < 7 || form["mail"].length > 20)
				context.error = "Неверная длина e-mail";
			else if (db.queryScalar("SELECT COUNT(*) FROM `users` WHERE `login` = '" ~ db.escapeStr(form["login"]) ~ "'").get!long > 0)
				context.error = "Пользователь с данным логином уже существует.\n";
			else if (db.queryScalar("SELECT COUNT(*) FROM `users` WHERE `mail` = '" ~ db.escapeStr(form["mail"]) ~ "'").get!long > 0)
				context.error = "Пользователь с данным e-mail уже существует.\n";
			else
			{
				ulong ra;
				auto c = Command(db.getCtn());
				try {
					c.sql = "INSERT INTO `users` (`login`, `password`, `mail`, `timeReg`)  VALUES('" ~ db.escapeStr(form["login"]) ~ "', '" ~ toHexString(controllerUsers.encryptionPass(form["pass"])) ~ "', '" ~ db.escapeStr(form["mail"]) ~ "', UNIX_TIMESTAMP());";
					c.execSQL(ra);
					c.sql = "INSERT INTO `rightsUsers` (`idUser`, `idRightComponent`, `idComponent`)
						 VALUES((SELECT `idUser` FROM `users` WHERE `login` = '" ~ db.escapeStr(form["login"]) ~ "' LIMIT 1), 1, 0)";
					c.execSQL(ra);
					res.headers["Refresh"] =  "5; URL=./profile/" ~ form["login"];
					context.success = "Вы успешно зарегистрированы.\nЧерез 5 сек. вы будете перенаправлены в свой <a href=\"./profile/" ~ form["login"] ~ "\">профиль</a>";
					// new session
					auto session = res.startSession();
					session.set("userLogin", form["login"]);
					funcs.addRight(session, "user");
					context.isNewReg = true;
				} catch (MySQLException e) {
					context.error = "Ошибка добавления записи.\n" ~ e.toString();
				}
			}
		}
	    
		funcs.render(tlate, context, req, res);
	}

}