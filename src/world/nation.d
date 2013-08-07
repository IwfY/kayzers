module world.nation;

import world.character;
import world.language;
import world.resourcemanager;

class Nation {
	private string name;
	private Character ruler;
	private Language language;
	private ResourceManager resources;

	public this() {
		this.resources = new ResourceManager();
	}

	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	public const(Language) getLanguage() const {
		return this.language;
	}
	public void setLanguage(Language language) {
		this.language = language;
	}

	public const(Character) getRuler() const {
		return this.ruler;
	}
	public void setRuler(Character ruler) {
		this.ruler = ruler;
	}

	public ResourceManager getResources() {
		return this.resources;
	}

	public const(ResourceManager) getResources() const {
		return this.resources;
	}
}
