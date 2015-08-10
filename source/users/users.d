module indcms.users.users;

import vibe.d;

import temple;

import std.stdio;
import std.digest.sha;

final class Users
{
static:

	bool isAuthorized(HTTPServerRequest req)
	{
		return req.session && req.session.isKeySet("userLogin") && req.session.isKeySet("userPermission");
	}
	alias isAutho = isAuthorized;

	public void addPermission (Session ses, string str)
	{
		string right= "";
		if (ses.isKeySet("userPermission"))
			right = ses.get!string("userPermission");
		
		if (right == "")
			right = str;
		else
			right ~= "," ~ str;
		
		ses.set("userPermission", right);
	}
	
	public bool inPermission(Session ses, string right)
	{
		import std.algorithm: canFind;
		if (!ses.isKeySet("userPermission")) return false;
		return (strPermissionToArray(ses.get!string("userPermission")).canFind(right));
	}
	
	
	public void setPermission (Session ses, string rights)
	{		
		ses.set("userPermission", rights);
	}
	
	
	private string[] strPermissionToArray(string right)
	{
		return right.split(",");
	}


	// encryption of password sha224
	public static ubyte[28] encryptionPass(string pass)
	{
		ubyte[28] hash224 = sha224Of(pass);
		return hash224; //toHexString(hash224);
	}
}

