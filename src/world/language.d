module world.language;

import std.random;

/**
 * groups information that is specific to one spoken language
 **/
class Language {
	private string name;
	private string[] maleNames;
	private string[] femaleNames;
	private string nobiliaryParticleMale;
	private string nobiliaryParticleFemale;

	public this(string name,
				string[] maleNames,
				string[] femaleNames,
				string nobiliaryParticleMale,
				string nobiliaryParticleFemale) {
		this.name = name;
		this.maleNames = maleNames;
		this.femaleNames = femaleNames;
		this.nobiliaryParticleMale = nobiliaryParticleMale;
		this.nobiliaryParticleFemale = nobiliaryParticleFemale;
	}

	public const(string) getName() const {
		return this.name;
	}

	public const(string[]) getMaleNames() const {
		return this.maleNames;
	}

	public string getRandomMaleName() const {
		if (this.maleNames.length > 0) {
			return this.maleNames[uniform(0, this.maleNames.length)];
		}
		return "";
	}

	public const(string[]) getFemaleNames() const {
		return this.femaleNames;
	}

	public string getRandomFemaleName() const {
		if (this.femaleNames.length > 0) {
			return this.femaleNames[uniform(0, this.femaleNames.length)];
		}
		return "";
	}

	public const(string) getNobiliaryParticleMale() const {
		return this.nobiliaryParticleMale;
	}

	public const(string) getNobiliaryParticleFemale() const {
		return this.nobiliaryParticleFemale;
	}
}
