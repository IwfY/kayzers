module world.nationprototype;

import world.language;

import std.random;
import std.typecons;

class NationPrototype {
	private static int lastId = 0;
	private int id;
	private string name;
	private Rebindable!(const(Language)) language;
	private string flagImage;	// file path to image
	private string flagImageName;
	private string[] defaultCityNames;

	public this() {
		NationPrototype.lastId++;
		this(NationPrototype.lastId);
	}

	public this(int id) {
		this.id = id;
		if (id > NationPrototype.lastId) {
			NationPrototype.lastId = id;
		}
	}

	public const(int) getId() const {
		return this.id;
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
	public void setLanguage(const(Language) language) {
		this.language = language;
	}

	public const(string) getFlagImageName() const {
		return this.flagImageName;
	}
	public void setFlagImageName(string flagImageName) {
		this.flagImageName = flagImageName;
	}

	public const(string[]) getDefaultCityNames() const {
		return this.defaultCityNames;
	}
	public void setDefaultCityNames(string[] defaultCityNames) {
		this.defaultCityNames = defaultCityNames;
	}
	public string getRandomCityName() const {
		if (this.defaultCityNames.length > 0) {
			return this.defaultCityNames[
				uniform(0, this.defaultCityNames.length)];
		}
		return "";
	}

	public const(string) getFlagImage() const {
		return this.flagImage;
	}
	public void setFlagImage(string flagImage) {
		this.flagImage = flagImage;
	}
}
