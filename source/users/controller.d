module indcms.users.controller;

import vibe.d;

import mysql.connection;

import temple;

import std.stdio;
import std.digest.sha;

import indcms.mysql;
import indcms.functions;
import indcms.users.models.users;


class UsersController
{
	private string viewsDir = "/users/";
	private MySQL db;
	private UsersModel users;
	private URLRouter router;
	
	this(URLRouter router, MySQL db) {
		this.db = db;
		this.router = router;
		users = new UsersModel(db);

		router
			.any(viewsDir ~ "in.dhtml", &(users.userIn))
			.get(viewsDir ~ "out.dhtml", &(users.userOut))
			.get(viewsDir ~ "profile/:profileLogin", &(users.userProfile))
			.any(viewsDir ~ "reg.dhtml", &(users.userReg));
	}

	public void toGlobalVars(TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
	{
		context.userLogin = users.getLogin(req);
		context.userAutho = funcs.isAuthorized(req);
	}

	// encryption of password sha224
	public static ubyte[28] encryptionPass(string pass)
	{
		ubyte[28] hash224 = sha224Of(pass);
		return hash224; //toHexString(hash224);
	}
}
alias UsersCtr = UsersController;
