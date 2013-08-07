module world.resourcemanager;

class ResourceManager {
	private float[string] resources;

	public const(float) getResourceAmount(string resource) const {
		if ((resource in this.resources) is null) {
			return 0.0;
		}
		return this.resources[resource];
	}

	public const(float[string]) getResources() const {
		return this.resources;
	}

	public void addResource(string resource, float amount) {
		// is there a resource entry already?
		if ((resource in this.resources) !is null) {
			this.resources[resource] += amount;
		} else {
			this.resources[resource] = amount;
		}
	}

	public void setResource(string resource, float amount) {
		this.resources[resource] = amount;
	}
}
