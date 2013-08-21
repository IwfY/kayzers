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
	private Rebindable!(const(StructurePrototype)) prototype;
	private Position position;
	private Rebindable!(const(Nation)) nation;
	private Rebindable!(const(Nation)) creatingNation;
	private ResourceManager resources;

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
	public void setPrototype(const(StructurePrototype) prototype) {
		this.prototype = prototype;
	}

	public const(Position) getPosition() const {
		return this.position;
	}
	public void setPosition(Position position) {
		this.position = position;
	}

	public const(Nation) getNation() const {
		return this.nation;
	}
	public void setNation(const(Nation) nation) {
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

	public void runProduceScript() {
		if (this.produceScript is null) {
			this.produceScript = new Script(
					this.prototype.getProduceScriptString());
		}
		this.produceScript.execute(this);
	}
}
