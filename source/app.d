import indcms;

shared static this()
{	
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore;
	settings.bindAddresses = [System.bindAddresses];
	settings.port = System.port;

	System.init();
	// all static files
	System.getRouter().get("*", serveStaticFiles("./public/"));

	listenHTTP(settings, System.getRouter());
}

