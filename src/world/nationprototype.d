module world.nationprototype;

import world.language;

import std.typecons;

class NationPrototype {
	private string name;
	private Rebindable!(const(Language)) language;
	private string flagImage;	// file path to image
	private string flagImageName;


	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	public const(Language) getLanguage() const {
		return this.language;
	}
	public void setLanguage(const(Language) language) {
		this.language = language;
	}

	public const(string) getFlagImageName() const {
		return this.flagImageName;
	}
	public void setFlagImageName(string flagImageName) {
		this.flagImageName = flagImageName;
	}

	public const(string) getFlagImage() const {
		return this.flagImage;
	}
	public void setFlagImage(string flagImage) {
		this.flagImage = flagImage;
	}
}
