module world.charactermanager;

import std.typecons;

import constants;
import game;
import list;
import world.character;
import world.dynasty;

class Proposal {
	public const(Character) sender;
	public const(Character) receiver;
	public bool isSent;

	public this(
			const(Character) sender,
			const(Character) receiver,
			bool isSent=false) {
		this.sender = sender;
		this.receiver = receiver;
		this.isSent = isSent;
	}
}

class CharacterManager {
	private Dynasty[] dynasties;
	private Game game;

	private List!(Proposal) proposalQueue;

	public this(Game game) {
		this.game = game;
		this.proposalQueue = new List!(Proposal)();
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
		if (!c.isDead() &&
				c.getPartner() is null &&
				c.getAge(this.game.getCurrentYear()) >= MIN_MARRIAGE_AGE &&
				this.characterProposedTo(c.getId()) is null) {
			return true;
		}
		return false;
	}

	/**
	 * get character that a given character proposed to
	 **/
	public const(Character) characterProposedTo(int charId) const {
		foreach (const(Proposal) proposal; this.proposalQueue) {
			if (proposal.sender.getId() == charId) {
				return proposal.receiver;
			}
		}
		return null;
	}

	public List!(Proposal) getProposalQueue() {
		return this.proposalQueue;
	}

	/**
	 * a proposal was send - request answer
	 **/
	public void sendProposal(int senderCharId, int receiverCharId) {
		Character sender = this.getCharacter(senderCharId);
		Character receiver = this.getCharacter(receiverCharId);

		if (!this.isMarryable(sender, receiver)) {
			return;
		}

		this.proposalQueue ~= new Proposal(sender, receiver, false);
	}

	public void proposalAnswered(
			int senderCharId, int receiverCharId, bool answer) {
		Character sender = this.getCharacter(senderCharId);
		Character receiver = this.getCharacter(receiverCharId);

		if (answer) {	// receiver said Yes
			sender.setPartner(receiver);
			receiver.setPartner(sender);
		}
		// remove proposal from queue
		int i = 0;
		int proposalIndex = -1;
		foreach (const(Proposal) proposal; this.proposalQueue) {
			if (proposal.sender == sender && proposal.receiver == receiver) {
				proposalIndex = i;
				break;
			}
			++i;
		}
		assert(proposalIndex >= 0,
			   "CharacterManger::proposalAnswered proposal not found");
		this.proposalQueue.removeIndex(proposalIndex);
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

