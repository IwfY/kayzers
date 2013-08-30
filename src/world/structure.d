module world.structure;

import position;
import script.script;
import script.scriptcontext;
import world.nation;
import world.resourcemanager;
import world.structureprototype;

import std.typecons;

/**
 * represents a tile filling structure on the map belonging to one nation
 **/
class Structure : ScriptContext {
	private StructurePrototype prototype;
	private Position position;
	private Nation nation;
	private Rebindable!(const(Nation)) creatingNation;
	private ResourceManager resources;

	private Script consumeScript;
	private Script produceScript;

	public this() {
		this.resources = new ResourceManager();
	}

	/************************
	 * Getters and Setters
	 ************************/

	public const(StructurePrototype) getPrototype() const {
		return this.prototype;
	}
	public void setPrototype(StructurePrototype prototype) {
		this.prototype = prototype;
	}

	public const(Position) getPosition() const {
		return this.position;
	}
	public void setPosition(Position position) {
		this.position = position;
	}

	public Nation getNation() {
		return this.nation;
	}
	public const(Nation) getNation() const {
		return this.nation;
	}
	public void setNation(Nation nation) {
		this.nation = nation;
	}

	public const(Nation) getCreatingNation() const {
		return this.creatingNation;
	}
	public void setCreatingNation(const(Nation) creatingNation) {
		this.creatingNation = creatingNation;
	}

	public ResourceManager getResources() {
		return this.resources;
	}
	public const(ResourceManager) getResources() const {
		return this.resources;
	}

	public void runInitScript() {
		this.prototype.runInitScript(this);
	}


	public void runConsumeScript() {
		this.prototype.runConsumeScript(this);
	}

	public void runProduceScript() {
		this.prototype.runProduceScript(this);
	}
}
