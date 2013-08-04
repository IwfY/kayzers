module world.nation;

import world.character;
import world.language;

class Nation {
	private string name;
	private Character ruler;
	private Language language;

	public this() {
		
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
}
