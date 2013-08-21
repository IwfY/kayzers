module script.scriptcontext;

import world.resourcemanager;

interface ScriptContext {
	public ResourceManager getResources();
	public const(ResourceManager) getResources() const;
}
