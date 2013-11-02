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
	private ResourceManager resources;
	private string name;

	private Script consumeScript;
	private Script produceScript;

	public this() {
		this.resources = new ResourceManager();
	}

	/************************
	 * Getters and Setters
	 ************************/
	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	/**
	 * get the complete name of the structure
	 **/
	public const(string) getNameString() const {
		string ret;
		ret = this.prototype.getName();
		if (this.prototype.isNameable()) {
			ret ~= ": " ~ this.name;
		}

		return ret;
	}

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
