module indcms.functions;

import vibe.d;

import temple;

import std.array;
import std.regex;
import std.stdio;


public static void delegate(TempleContext, HTTPServerRequest, HTTPServerResponse)[] funcsGlobalVars;

class Functions
{
static:
	const int ENT_COMPAT = 0; // Преобразует двойные кавычки, одинарные кавычки не изменяются.
	const int ENT_QUOTES = 1; // Преобразует как двойные, так и одинарные кавычки.
	const int ENT_NOQUOTES = 2; // Оставляет без изменения как двойные, так и одинарные кавычки.

	bool inArray(T)(in string[] keys, in T array)
	{
		foreach(string key; keys)
		{
			if (key !in array)
				return false;
		}
		return true;
	}

	bool isAuthorized(HTTPServerRequest req)
	{
		return req.session && req.session.isKeySet("userLogin") && req.session.isKeySet("userPermission");
	}

	string nl2br(string str)
	{
		return
			str
				.replace("\r", "")
				.replace("\n", "<br>");
	}

	/*
	 *  Производятся следующие преобразования:
     * '&' (амперсанд) преобразуется в '&amp;'
     * '"' (двойная кавычка) преобразуется в '&quot;' в режиме ENT_NOQUOTES is not set.
     * "'" (одиночная кавычка) преобразуется в '&#039;' (или &apos;) только в режиме ENT_QUOTES.
     * '<' (знак "меньше чем") преобразуется в '&lt;'
     * '>' (знак "больше чем") преобразуется в '&gt;'
     * 
     * Flags:
     * ENT_COMPAT - Преобразует двойные кавычки, одинарные кавычки не изменяются.
	 * ENT_QUOTES - Преобразует как двойные, так и одинарные кавычки.
	 * ENT_NOQUOTES - Оставляет без изменения как двойные, так и одинарные кавычки.
	*/
	string htmlspecialchars (string str, int flag = this.ENT_COMPAT)
	{
		str = str
			.replace("&", "&amp;")
			.replace("<", "&lt;")
			.replace(">", "&gt;");
		switch (flag)
		{
			case this.ENT_QUOTES:
				str = str.replace("'", "&#039;");
				break;
			case this.ENT_NOQUOTES:
				break;
			default: // ENT_COMPAT
				str = str.replace("\"", "&quot;");
		}
		return str;
	}

	string trim (string str)
	{
		return str;
	}

	bool isRegexMatch (in string pattern, in string subject, in string flags = "")
	{
		auto ctR = regex(pattern, flags);
		auto mf = matchFirst(subject, ctR); 
		return !mf.empty;
	}

	void globalVarsContext (TempleContext context)
	{
		if (context.isSet("error"))
		{
			string str = context.error.toString();
			if (str != "")
				context.error = "<div class=\"error\">" ~ nl2br(str) ~ "</div>";
		}
		else
			context.error = null;
		if (context.isSet("success"))
		{
			string str = context.success.toString();
			if (str != "")
				context.success = "<div class=\"success\">" ~ nl2br(str) ~ "</div>";
		}
		else
			context.success = null;
	}

	void render(CompiledTemple temple, TempleContext context, HTTPServerRequest req, HTTPServerResponse res)
	{
		globalVarsContext(context);
		foreach(void delegate(TempleContext, HTTPServerRequest, HTTPServerResponse) f; funcsGlobalVars)
			f(context, req, res);
		temple.render(res.bodyWriter, context);
	}

	void addPermission (Session ses, string str)
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

	bool inPermission(Session ses, string right)
	{
		import std.algorithm: canFind;
		if (!ses.isKeySet("userPermission")) return false;
		return (strPermissionToArray(ses.get!string("userPermission")).canFind(right));
	}

	void setPermission (Session ses, string rights)
	{		
		ses.set("userPermission", rights);
	}

	string[] strPermissionToArray(string right)
	{
		return right.split(",");
	}
}
alias funcs = Functions;
