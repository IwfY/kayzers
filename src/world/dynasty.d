module world.dynasty;

import world.character;

class Dynasty {
	private string name;
	private Character founder;
	private Character[] members;

	public string getName() {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	public Character getFounder() {
		return this.founder;
	}
	public void setFounder(Character founder) {
		this.founder = founder;
	}

	public Character[] getMembers() {
		return this.members;
	}
	public void setMembers(Character[] members) {
		this.members = members;
	}
}
