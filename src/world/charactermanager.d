module world.charactermanager;

import constants;
import game;
import world.character;
import world.dynasty;

class CharacterManager {
	private Dynasty[] dynasties;
	private Game game;

	public this(Game game) {
		this.game = game;
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

	public Character getCharacter(int id) {
		foreach (Dynasty dynasty; this.getDynasties()) {
			foreach (Character character; dynasty.getMembers()) {
				if (character.getId() == id) {
					return character;
				}
			}
		}
		return null;
	}
	public const(Character) getCharacter(int id) const {
		foreach (const(Dynasty) dynasty; this.getDynasties()) {
			foreach (const(Character) character; dynasty.getMembers()) {
				if (character.getId() == id) {
					return character;
				}
			}
		}
		return null;
	}

	public const(const(Character)[]) getMarryableCharacters(int characterId) const {
		const(Character) character = this.getCharacter(characterId);
		if (character is null) {
			return null;
		}
		return this.getMarryableCharacters(character);
	}
	public const(const(Character)[]) getMarryableCharacters(const(Character) character) const {
		const(Character)[] marryableCharacters;
		foreach (const(Dynasty) dynasty; this.getDynasties()) {
			foreach (const(Character) charCursor; dynasty.getMembers()) {
				if (this.isMarryable(character, charCursor)) {
					marryableCharacters ~= charCursor;
				}
			}
		}
		return marryableCharacters;
	}

	public const(bool) isMarryable(const(Character) c1, const(Character) c2) const {
		if (c1.getSex() != c2.getSex() &&
				this.isMarryable(c1) && this.isMarryable(c2) &&
				!CharacterManager.isSibling(c1, c2) &&
				c1.getFather() != c2 && c1.getMother() != c2 &&
				c2.getFather() != c1 && c2.getMother() != c1) {
			return true;
		}
		return false;
	}

	public const(bool) isMarryable(const(Character) c) const {
		import std.stdio;writeln("CharManager::isMarryable pre");
		if (!c.isDead() &&
				c.getPartner() is null &&
				c.getAge(this.game.getCurrentYear()) >= MIN_MARRIAGE_AGE) {
			return true;
		}
		return false;
	}


	/**
	 * return true if two characters have at least one parent in common
	 **/
	public static bool isSibling(const(Character) c1, const(Character) c2) {
		return (c1.getFather() == c2.getFather() || c1.getMother() == c2.getMother());
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

