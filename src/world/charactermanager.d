module world.charactermanager;

import world.character;
import world.dynasty;

class CharacterManager {
	private Dynasty[] dynasties;

	public this() {
	}

	public void addDynasty(Dynasty dynasty) {
		this.dynasties ~= dynasty;
	}
	public const(Dynasty[]) getDynasties() const {
		return this.dynasties;
	}
	public Dynasty[] getDynasties() {
		return this.dynasties;
	}

	public const(Character[]) getMarryableCharacters(const(Character) character) const {
		return null;
	}


	/**
	 * create a character and link it with parents and dynasty
	 **/
	public static Character characterFactory(
			Character father,
			Character mother,
			Dynasty dynasty) {
		Character newCharacter = new Character();
		newCharacter.setFather(father);
		newCharacter.setMother(mother);
		newCharacter.setDynasty(dynasty);

		if (father !is null) {
			father.addChild(newCharacter);
		}
		if (mother !is null) {
			mother.addChild(newCharacter);
		}
		if (dynasty !is null) {
			dynasty.addMember(newCharacter);
		}

		return newCharacter;
	}
}

