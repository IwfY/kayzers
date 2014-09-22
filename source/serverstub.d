module serverstub;

import game;
import map;
import position;
import world.character;
import world.dynasty;
import world.nation;
import world.nationprototype;
import world.structure;
import world.structureprototype;

/**
 * ServerStub is a client-side interface to the server
 **/
class ServerStub {
	private Game game;

	public this(Game game) {
		this.game = game;
	}


	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.game.getStructurePrototypes();
	}

	public const(NationPrototype[]) getNationPrototypes() const {
		return this.game.getNationPrototypes();
	}


	public const(Nation[]) getNations() const {
		return this.game.getNations();
	}


	public const(Nation) getCurrentNation() const {
		return this.game.getCurrentNation();
	}

	public const(Dynasty) getCurrentDynasty() const {
		const(Nation) currentNation = this.getCurrentNation();
		const(Character) ruler = currentNation.getRuler();
		return ruler.getDynasty();
	}


	// character management
	public void setCharacterName(const(Character) character,
	                             string name) {
		this.game.setCharacterName(character, name);
	}

	public const(const(Character)[]) getMarryableCharacters(int characterId) {
		return this.game.getMarryableCharacters(characterId);
	}

	public const(Character) getCharacter(int id) const {
		return this.game.getCharacter(id);
	}
	public const(bool) isMarryable(const(Character) c) const {
		return this.game.isMarryable(c);
	}
	public const(bool) isMarryable(
			const(Character) c1, const(Character) c2) const {
		return this.game.isMarryable(c1, c2);
	}
	public const(bool) isMarryable(int c1, int c2) const {
		return this.game.isMarryable(c1, c2);
	}
	public const(Character) getProposedToCharacter(int charId) const {
		return this.game.getProposedToCharacter(charId);
	}

	public const(bool) canPropose(const(Character) c) const {
		return this.game.canPropose(c);
	}

	public void sendProposal(int senderCharId, int receiverCharId) {
		this.game.sendProposal(senderCharId, receiverCharId);
	}

	public void proposalAnswered(
			int senderCharId, int receiverCharId, bool answer) {
		this.game.proposalAnswered(
			senderCharId, receiverCharId, answer);
	}


	// structure management
	public bool canBuildStructure(string structurePrototypeName,
	                              const(Nation) nation,
	                              const(Position) position) const {
		return this.game.canBuildStructure(
			structurePrototypeName, nation, position);
	}

	public void setStructureName(const(Structure) structure, string name) {
		this.game.setStructureName(structure, name);
	}


	public bool addStructure(string structurePrototypeName,
	                         const(Nation) nation,
	                         const(Position) position) {
		return this.game.addStructure(structurePrototypeName, nation, position);
	}

	public const(Structure[]) getStructures() const {
		return this.game.getStructures();
	}
	public const(Structure) getStructure(int i, int j) const {
		return this.game.getStructure(i, j);
	}

	public const(Map) getMap() const {
		return this.game.getMap();
	}

	public const(int) getCurrentYear() const {
		return this.game.getCurrentYear();
	}

	public void endTurn() {
		this.game.endTurn();
	}

	public void save(string filename) {
		this.game.save(filename);
	}
}

