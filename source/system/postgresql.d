module indcms.system.postgresql;

public import ddb.db;
public import ddb.postgres;

import vibe.d;

import std.datetime;
import std.stdio;
import std.string;
import std.variant;

alias PgSQL = PostgresSQL;
static class PostgresSQL
{
static:
	const string prefixRole = "indcms_";

	// prepends backslashes to the following characters in String Constants with C-style Escapes: \x00, \n, \r, \, ' and \x1a
	string escape (string str)
	{
		str = str
			.replace("\\", "\\\\")
			.replace("\n", "\\n")
			.replace("\r", "\\r")
			.replace("'", "\\'")
			.replace("\x00", "\\x00")
			.replace("\x1a", "\\x1a");
		str = "E'" ~ str ~ "'";
		return str;
	}

	// return role with prefix
	string role(in string strRole)
	{
		return this.prefixRole ~ strRole;
	}

	/*
	// Convert a Timestamp to DateTime
	DateTime toDateTime(Timestamp value) pure
	{
		auto x = value.rep;
		int second = cast(int) (x%100);
		x /= 100;
		int minute = cast(int) (x%100);
		x /= 100;
		int hour   = cast(int) (x%100);
		x /= 100;
		int day    = cast(int) (x%100);
		x /= 100;
		int month  = cast(int) (x%100);
		x /= 100;
		int year   = cast(int) (x%10000);
		
		return DateTime(year, month, day, hour, minute, second);
	}
	*/
}

