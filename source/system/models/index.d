module indcms.system.models.index;

import vibe.d;

import temple;

import std.stdio;
import std.variant;

import indcms.system.addon;

class IndexModel: AddonModel {
	
	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
	    auto tlate = compile_temple_file!"index.dte";
	    auto context = new TempleContext();
		render(tlate, context, req, res);
	}
	
}