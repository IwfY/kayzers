module script.scriptcontext;

import world.nation;
import world.resourcemanager;

interface ScriptContext {
	public ResourceManager getResources();
	public const(ResourceManager) getResources() const;
	public Nation getNation();
	public const(Nation) getNation() const;
}
