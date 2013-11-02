module world.character;

import world.dynasty;
import world.nation;

import std.typecons;

static enum Sex {MALE, FEMALE};

class Character {
	private string name;
	private string dna;
	private Dynasty dynasty;
	private int birth;
	private Rebindable!(const(Nation)) birthNation;
	private int death;
	private Sex sex;
	private Character father;
	private Character mother;
	private Character partner;
	private Character[] children;

	this() {
	}

	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
			this.name = name;
	}
	public const(string) getFullName() const {
		string ret = this.name ~ " ";
		if (this.sex == Sex.MALE) {
			ret ~= this.dynasty.getLanguage().getNobiliaryParticleMale();
		} else {
			ret ~= this.dynasty.getLanguage().getNobiliaryParticleFemale();
		}
		ret ~= " " ~ this.dynasty.getName();

		return ret;
	}

	public const(string) getDna() const {
		return this.dna;
	}
	public void setDna(string dna) {
		this.dna = dna;
	}

	public const(Nation) getBirthNation() const {
		return this.birthNation;
	}
	public void setBirthNation(const(Nation) nation) {
		this.birthNation = nation;
	}

	public const(int) getBirth() const {
		return this.birth;
	}
	public void setBirth(int birth) {
		this.birth = birth;
	}

	public const(int) getDeath() const {
		return this.death;
	}
	public void setDeath(int death) {
		this.death = death;
	}

	public const(Sex) getSex() const {
		return this.sex;
	}
	public void setSex(Sex sex) {
		this.sex = sex;
	}

	public const(Character) getFather() const {
		return this.father;
	}
	public void setFather(Character father) {
		this.father = father;
	}

	public const(Character) getMother() const {
		return this.mother;
	}
	public void setMother(Character mother) {
		this.mother = mother;
	}

	public const(Character) getPartner() const {
		return this.partner;
	}
	public void setPartner(Character partner) {
		this.partner = partner;
	}

	public const(Character[]) getChildren() const {
		return this.children;
	}
	public void setChildren(Character[] children) {
		this.children = children;
	}

	public const(Dynasty) getDynasty() const {
		return this.dynasty;
	}
	public void setDynasty(Dynasty dynasty) {
		this.dynasty = dynasty;
	}

}
