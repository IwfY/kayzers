module world.character;

import std.typecons;

import world.dynasty;
import world.nation;

static enum Sex {MALE, FEMALE};

class Character {
	private static int lastId = 0;
	private int id;
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

	public this() {
		Character.lastId++;
		this(Character.lastId);
	}

	public this(int id) {
		this.id = id;
		if (id > Character.lastId) {
			Character.lastId = id;
		}
	}

	public const(bool) opEquals(const(Character) character) const {
		if (character.getId() == this.getId()) {
			return true;
		}
		return false;
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

	public const(int) getAge(int currentYear) const {
		if (this.isDead()) {
			return this.death - this.birth;
		} else {
			return currentYear - this.birth;
		}
	}
	public const(bool) isDead() const {
		return (this.death >= this.birth);
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

	public Character getPartner()
		in {
			assert(this.partner is null || !this.partner.isDead(),
				   "Character::getPartner partner must not be dead");
		}
		body {
			return this.partner;
		}
	public const(Character) getPartner() const
		in {
			assert(this.partner is null || !this.partner.isDead(),
				   "Character::getPartner partner must not be dead");
		}
		body {
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
	public void addChild(Character child) {
		this.children ~= child;
	}

	public Dynasty getDynasty() {
		return this.dynasty;
	}
	public const(Dynasty) getDynasty() const {
		return this.dynasty;
	}
	public void setDynasty(Dynasty dynasty) {
		this.dynasty = dynasty;
	}

}
