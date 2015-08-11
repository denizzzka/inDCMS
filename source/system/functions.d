module indcms.system.functions;

import std.array;
import std.regex;
import std.stdio;


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
string htmlspecialchars (string str, int flag = ENT_COMPAT)
{
	str = str
		.replace("&", "&amp;")
		.replace("<", "&lt;")
		.replace(">", "&gt;");
	switch (flag)
	{
		case ENT_QUOTES:
			str = str.replace("'", "&#039;");
			break;
		case ENT_NOQUOTES:
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
