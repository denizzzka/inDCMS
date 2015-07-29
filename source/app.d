import vibe.d;

import mysql.connection;

import temple;

import std.stdio;

import indcms.mysql;
import indcms.functions;
import indcms.users.controller;


private MySQL db; 

static this()
{	
	// settings
	db = new MySQL("host=localhost;port=3306;user=root;pwd=;db=dlang");
	// connect to MySQL
	db.connect();
	
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore;
	settings.bindAddresses = ["127.0.0.1"];
	settings.port = 8000;

	auto router = new URLRouter;
	router.get("/", &index);

	// registration of add-ons
	auto usersController = new UsersController(router, db);
	funcsGlobalVars ~= &usersController.toGlobalVars; // добавление глобальных переменных для шаблонов

	// all static files
	router.get("*", serveStaticFiles("./public/"));

	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:8000/ in your browser.");

}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
    auto tlate = compile_temple_file!"index.dte";
    auto context = new TempleContext();
	funcs.render(tlate, context, req, res);
}


// destructor
static ~this()
{
	db.close();
}