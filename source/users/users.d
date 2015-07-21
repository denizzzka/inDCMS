module inDCMS.users;
import vibe.d;
import temple;
import std.stdio;
import mysql.connection;
import inDCMS.MySQL;

class Users {
	private string dirViews = "/users/";
	private MySQL db;

	this(URLRouter router, MySQL db) {
		this.db = db;

		router
			.get(dirViews ~ "isAuto.dhtml", &isAuto)
			.get(dirViews ~ "in.dhtml", &userIn)
			.get(dirViews ~ "out.dhtml", &userOut)
			.get(dirViews ~ "test.dhtml", &test);
	}


	private void isAuto(HTTPServerRequest req, HTTPServerResponse res)
	{
		string info;
		auto tlate = compile_temple!q{
			<%= var("info") %>
		};
		auto context = new TempleContext();
		if (req.session && req.session.isKeySet("userName") && req.session.isKeySet("userRight"))
		{
			info = "\nAuthorized user.\n";
			info ~= "Login: " ~ req.session.get!string("userName") ~ "\n";
			info ~= "Right: " ~ req.session.get!string("userRight") ~ "\n";

		}
		else
		{
			info = "Unauthorized user";
		}

		context.info = info;
		tlate.render(res.bodyWriter, context);
	}

	private void userIn(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (req.session)
		{
			res.redirect("/");
			return;
		}
		auto session = res.startSession();
		session.set("userName", "userAdmin");
		session.set("userRight", "admin");
		res.redirect("/");
	}


	private void userOut(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (req.session) res.terminateSession();
		res.redirect("/");
	}


	private void test(HTTPServerRequest req, HTTPServerResponse res)
	{
	    auto tlate = compile_temple_file!("users.reg.dte");
	    auto context = new TempleContext();

		auto sql = "select first from test limit 1";
		context.name = db.queryScalar(sql);
	    
		tlate.render(res.bodyWriter, context);
	}

}