module player;

import world.dynasty;

class Player {
	private string name;
	// all the dynasties the player controlls
	private const(Dynasty)[] dynasties;

	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}

	public const(Dynasty)[] getDynasties() const {
		return this.dynasties;
	}
	public void setDynasties(const(Dynasty)[] dynasties) {
		this.dynasties = dynasties;
	}
	public void addDynastie(const(Dynasty) dynastie) {
		this.dynasties ~= dynastie;
	}
}
