module inDCMS.users.controller;
import vibe.d;
import temple;
import std.stdio;
import std.digest.sha;
import mysql.connection;
import inDCMS.MySQL;
import inDCMS.functions;
import inDCMS.users.models.users;


class controllerUsers
{
	private string dirViews = "/users/";
	private MySQL db;
	private ModelUsers users;
	private URLRouter router;
	
	this(URLRouter router, MySQL db) {
		this.db = db;
		this.router = router;
		users = new ModelUsers(db);

		router
			.any(dirViews ~ "in.dhtml", &(users.userIn))
			.get(dirViews ~ "out.dhtml", &(users.userOut))
			.get(dirViews ~ "profile/:profileLogin", &(users.userProfile))
			.any(dirViews ~ "reg.dhtml", &(users.userReg));
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
alias ctrUsers = controllerUsers;
