module world.dynasty;

import world.character;
import world.language;

import std.typecons;

class Dynasty {
	private static int lastId = 0;
	private int id;
	private string name;
	private Character[] members;
	private Rebindable!(const(Language)) language;
	private string flagImageName;

	public this() {
		Dynasty.lastId++;
		this(Dynasty.lastId);
	}

	public this(int id) {
		this.id = id;
		if (id > Dynasty.lastId) {
			Dynasty.lastId = id;
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

	public const(Character[]) getMembers() const {
		return this.members;
	}
	public Character[] getMembers() {
		return this.members;
	}
	public void setMembers(Character[] members) {
		this.members = members;
	}
	public void addMember(Character character) {
		this.members ~= character;
	}

	public const(string) getFlagImageName() const {
		return this.flagImageName;
	}
	public void setFlagImageName(string flagImageName) {
		this.flagImageName = flagImageName;
	}
}
