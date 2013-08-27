module world.nation;

import script.scriptcontext;
import world.character;
import world.nationprototype;
import world.structure;
import world.resourcemanager;

import std.typecons;

class Nation : ScriptContext {
	private Rebindable!(const(NationPrototype)) prototype;
	private Character ruler;
	private ResourceManager resources;
	private Rebindable!(const(Structure)) seat;

	invariant() {
		assert(this.seat is null || this.seat.getNation() == this,
			   "Nation::invariant seat is not of nation");
	}

	public this(const(NationPrototype) nationPrototype) {
		this.prototype = nationPrototype;
		this.resources = new ResourceManager();
	}

	public const(Character) getRuler() const {
		return this.ruler;
	}
	public void setRuler(Character ruler) {
		this.ruler = ruler;
	}

	public const(Structure) getSeat() const {
		return this.seat;
	}
	public void setSeat(const(Structure) seat) {
		this.seat = seat;
	}

	// convenience methods to implement ScriptContext
	public Nation getNation() {
		return this;
	}
	public const(Nation) getNation() const {
		return this;
	}

	public ResourceManager getResources() {
		return this.resources;
	}
	public const(ResourceManager) getResources() const {
		return this.resources;
	}

	public const(NationPrototype) getPrototype() const {
		return this.prototype;
	}
	public void setPrototype(const(NationPrototype) prototype) {
			this.prototype = prototype;
	}

	public const(string) getName() const {
		return this.prototype.getName();
	}
}
