import vibe.d;
import std.string;
import std.file;



void image (HTTPServerRequest req, HTTPServerResponse res)
{
	auto file = format("./public/images/%s", req.params["f"]);
	
	if(exists(file))
	{
		auto image = cast(ubyte[]) read(file);
		res.writeBody(image,"image");
	}
	else
	{
		res.writeBody("Not Found","text/plain");
	}
}


shared static this()
{

	auto router = new URLRouter;
	router
		.get("/", &index)
		// matches all GET requests
		.get("*", serveStaticFiles("./public/"));




	auto settings = new HTTPServerSettings;
	settings.port = 8000;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:8000/ in your browser.");
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
	//res.render!("index.dt", req);
}