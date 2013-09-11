module world.nation;

import color;
import utils;
import script.scriptcontext;
import world.character;
import world.nationprototype;
import world.structure;
import world.resourcemanager;

import std.random;
import std.typecons;

class Nation : ScriptContext {
	private Rebindable!(const(NationPrototype)) prototype;
	private Character ruler;
	private ResourceManager resources;
	private Rebindable!(const(Structure)) seat;
	private Structure[] structures;
	private Color color;

	invariant() {
		assert(this.seat is null || this.seat.getNation() == this,
			   "Nation::invariant seat is not of nation");
	}

	public this(const(NationPrototype) nationPrototype) {
		this.prototype = nationPrototype;
		this.resources = new ResourceManager();
		this.color = new Color();
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

	public void addStructure(Structure structure) {
		this.structures ~= structure;
	}
	public void removeStructure(Structure structure) {
		for (int i = 0; i < this.structures.length; ++i) {
			if (this.structures[i] == structure) {
				this.structures =
						this.structures[0..i] ~
						this.structures[(i + 1)..this.structures.length];
				return;
			}
		}
	}

	public const(Color) getColor() const {
		return this.color;
	}
	public void setColor(Color color) {
		this.color = color;
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

	/**
	 * consume resources from nations global inventory and from all structures
	 *
	 * @return the proportion of available to wanted resource amount [0.0, 1.0]
	 **/
	public double consume(string resourceName, double amount) {
		double consumed = 0.0;

		// consume from global resources
		double globalAvailable = this.resources.getResourceAmount(resourceName);
		double consumedGlobal = min(amount, globalAvailable);
		this.resources.addResource(resourceName, -consumedGlobal);
		consumed += consumedGlobal;

		if (consumed >= amount) {
			return 1.0;
		}

		// consume from structures
		// iterate over structures randomly
		Random random = Random(unpredictableSeed);
		foreach (Structure structure; randomCover(this.structures, random)) {
			double localAvailable = structure.getResources().
					getResourceAmount(resourceName);
			double consumedLocal = min(amount, localAvailable);
			structure.getResources().addResource(resourceName, -consumedLocal);
			consumed += consumedLocal;

			if (consumed >= amount) {
				return 1.0;
			}
		}

		return (consumed / amount);
	}


	public double produce(ScriptContext context,
						  string resourceName,
						  double amount) {
		context.getResources().addResource(resourceName, amount);
		return 1.0;
	}
}
