module world.charactermanager;

import std.algorithm;
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

	/**
	 * get a list of characters the given character may propose to
	 **/
	public const(const(Character)[]) getMarryableCharacters(
			int characterId) const {
		const(Character) character = this.getCharacter(characterId);
		return this.getMarryableCharacters(character);
	}


	/**
	 * get a list of characters the given character may propose to
	 **/
	public const(const(Character)[])
			getMarryableCharacters(const(Character) character) const {
		const(Character)[] marryableCharacters;

		if (!this.canPropose(character)) {
			return marryableCharacters;
		}

		foreach (const(Dynasty) dynasty; this.getDynasties()) {
			foreach (const(Character) charCursor; dynasty.getMembers()) {
				if (this.isMarryable(character, charCursor)) {
					marryableCharacters ~= charCursor;
				}
			}
		}
		return marryableCharacters;
	}


	/**
	 * check if two characters can marry
	 **/
	public const(bool)
			isMarryable(const(Character) c1, const(Character) c2) const {
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
				c.getAge(this.game.getCurrentYear()) >= MIN_MARRIAGE_AGE) {
			return true;
		}
		return false;
	}

	/**
	 * check if a character is allowed to propose to someone
	 *
	 * includes check if a proposal was already sent this year
	 **/
	public const(bool) canPropose(const(Character) c) const {
		return (this.isMarryable(c) &&
				this.getProposedToCharacter(c.getId()) is null);
	}

	/**
	 * get character that a given character proposed to
	 **/
	public const(Character) getProposedToCharacter(int charId) const {
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

	/**
	 * a proposal was answered by the receiver
	 **/
	public void proposalAnswered(
			int senderCharId, int receiverCharId, bool answer) {
		Character sender = this.getCharacter(senderCharId);
		Character receiver = this.getCharacter(receiverCharId);

		// remove this proposal from queue
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

		// couple them
		if (answer &&	// receiver said Yes
				this.isMarryable(sender, receiver)) {	// still marryable?
			sender.setPartner(receiver);
			receiver.setPartner(sender);

			// remove other proposals connected with both partners from queue
			i = 0;
			while (i < this.proposalQueue.length) {
				Proposal proposal = this.proposalQueue[i];
				if (proposal.sender == sender ||
						proposal.receiver == sender ||
						proposal.sender == receiver ||
						proposal.receiver == receiver) {
					this.proposalQueue.removeIndex(i);
				} else {
					++i;
				}
			}
		}
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


	public void characterDied(Character character) {
		Character partner = character.getPartner();
		if (partner !is null) {
			partner.setPartner(null);
			character.setPartner(null);
		}

		// remove proposals
		bool found = true;
		while (found) {
			found = false;
			int i = 0;
			foreach (Proposal proposal; this.proposalQueue) {
				if (proposal.sender == character || proposal.receiver == character) {
					found = true;
					break;
				}
				++i;
			}

			if (found) {
				this.proposalQueue.removeIndex(i);
			}
		}

		character.setDeath(this.game.getCurrentYear());
	}

	/**
	 * get the first heir of a character
	 * 
	 * order:
	 * 		sons
	 * 		grandsons, ...
	 * 		partner
	 **/
	public Character getHeir(Character character) {
		// iterate sons
		Character heir = this.getMaleHeir(character);
		if (heir !is null) {
			return heir;
		}

		// partner if there is one
		if (character.getPartner() !is null) {
			return character.getPartner();
		}
		
		// TODO choose heir of the throne more wisely
		return CharacterManager.characterFactory(null, null, character.getDynasty());
	}


	public Character getMaleHeir(Character character) {
		// iterate sons
		foreach (Character child; sort!(Character.birthSort)(character.getChildren())) {
			if (child.getSex() == Sex.MALE) {
				if (!child.isDead()) {
					return child;
				}
			}
		}
		
		// iterate male descendents
		foreach (Character child; sort!(Character.birthSort)(character.getChildren())) {
			if (child.getSex() == Sex.MALE) {
				Character heir = this.getMaleHeir(child);
				if (heir !is null) {
					return heir;
				}
			}
		}

		return null;
	}
}

