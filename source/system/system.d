module indcms.system;

import vibe.d;

import temple;

static final class System
{
static:
	private bool isInit = false;
	private URLRouter urlRouter;

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
}

