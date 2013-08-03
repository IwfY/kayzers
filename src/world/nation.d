module world.nation;

import world.character;
import world.language;

class Nation {
	private string name;
	private Character ruler;
	private Language language;

	public this() {
		
	}

	public string getName() {
        return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	public Language getLanguage() {
        return this.language;
	}
	public void setLanguage(Language language) {
		this.language = language;
	}

	public Character getRuler() {
        return this.ruler;
	}
	public void setRuler(Character ruler) {
		this.ruler = ruler;
	}
}
