module world.resourcemanager;

class ResourceManager {
	private double[string] resources;

	public const(double) getResourceAmount(string resource) const {
		if ((resource in this.resources) is null) {
			return 0.0;
		}
		return this.resources[resource];
	}

	public const(double[string]) getResources() const {
		return this.resources;
	}

	public void addResource(string resource, double amount) {
		// is there a resource entry already?
		if ((resource in this.resources) !is null) {
			this.resources[resource] += amount;
		} else {
			this.resources[resource] = amount;
		}
	}

	public void setResource(string resource, double amount) {
		debug(2) {
			import std.stdio;
			writefln("new resource value: %s -> %f", resource, amount);
		}
		this.resources[resource] = amount;
	}
}
