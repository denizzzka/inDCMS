module indcms.system.system;

import vibe.d;

import temple;

import indcms.system.postgresql;

static final class System
{
static:
	private bool isInit = false;
	private URLRouter urlRouter;
	public immutable string bindAddresses = "127.0.0.1";
	public immutable int port = 8000;
	private PGConnection dbConnection;

	public void init()
	{
		if (this.isInit) return;
		this.urlRouter = new URLRouter;
		this.isInit = true;
	}

	public URLRouter getRouter ()
	{
		return this.urlRouter;
	}

	public PGConnection getDBConncection ()
	{
		return this.dbConnection;
	}
	public void setDBConncection (PGConnection dbConnection)
	{
		this.dbConnection = dbConnection;
	}
}

