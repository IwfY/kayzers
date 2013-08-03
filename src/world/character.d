module world.character;

import world.nation;

static enum Sex {MALE, FEMALE};

class Character {
	private string name;
	private string dna;
	private int birth;
	private int death;
	private Sex sex;
	private Nation birthNation;
	private Character father;
	private Character mother;
	private Character partner;
	private Character[] children;

	this() {
	}

	public string getName() {
        return this.name;
	}
	public void setName(string name) {
			this.name = name;
	}

	public string getDna() {
        return this.dna;
	}
	public void setDna(string dna) {
		this.dna = dna;
	}

	public int getBirth() {
        return this.birth;
	}
	public void setBirth(int birth) {
		this.birth = birth;
	}

	public int getDeath() {
        return this.death;
	}
	public void setDeath(int death) {
		this.death = death;
	}

	public Sex getSex() {
		return this.sex;
	}
	public void setSex(Sex sex) {
		this.sex = sex;
	}

	public Character getFather() {
        return this.father;
	}
	public void setFather(Character father) {
		this.father = father;
	}

	public Character getMother() {
        return this.mother;
	}
	public void setMother(Character mother) {
		this.mother = mother;
	}

	public Character getPartner() {
        return this.partner;
	}
	public void setPartner(Character partner) {
		this.partner = partner;
	}

	public Character[] getChildren() {
        return this.children;
	}
	public void setChildren(Character[] children) {
		this.children = children;
	}
	
}
