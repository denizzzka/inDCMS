module indcms.users.controller;

import vibe.d;

import temple;

import std.stdio;

import indcms.system.addon;
import indcms.system.postgresql;
import indcms.system.system;
import indcms.users.users;
import indcms.users.models.profiles;
import indcms.users.models.users;


const string ADDON_NAME = "users";

//constructor of module
static this()
{
	new UsersController();
}

class UsersController: AddonController
{
	private string viewsDir = "/users/";
	private UsersModel usersModel;
	private ProfilesModel profilesModel;

	this() {
		super(ADDON_NAME, true);

		usersModel = new UsersModel(this.db);
		profilesModel = new ProfilesModel(this.db);

		System.getRouter()
			.any(viewsDir ~ "in.dhtml", &usersModel.userIn)
			.get(viewsDir ~ "out.dhtml", &usersModel.userOut)
			.get(viewsDir ~ "profile/:profileLogin", &profilesModel.userProfile)
			.any(viewsDir ~ "reg.dhtml", &usersModel.userReg);

		funcsGlobalTempleVars ~= &this.toGlobalVars;
	}

	override
	{
		void install ()
		{
			super.install();
			this.initializeForDB();
		}

		void toGlobalVars(TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
		{
			context.userLogin = usersModel.getLogin(req);
			context.userAutho = Users.isAutho(req);
		}
	}
}
