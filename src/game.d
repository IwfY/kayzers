module game;

import client;
import color;
import gamedb;
import map;
import message;
import player;
import position;
import structuremanager;
import world.character;
import world.charactermanager;
import world.dynasty;
import world.language;
import world.nation;
import world.nationprototype;
import world.scenario;
import world.settlementcreator;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;
import std.typecons;
import std.random;

public class Game {
	private string name;
	private Map map;
	private Client client;
	private Player[] players;
	private Nation[] nations;
	private uint currentNationIndex;
	private NationPrototype[] nationPrototypes;
	private Language[] languages;
	private CharacterManager characterManager;
	private StructureManager structureManager;
	private int currentYear;
	private Random gen;

	private static Color[] nationColors = [
		new Color(63, 56, 190),
		new Color(234, 205, 44),
		new Color(56, 125, 44),
		new Color(115, 57, 164),
		new Color(164, 57, 130)
];

	public this(Client client, Scenario scenario) {
		this.gen = Random(unpredictableSeed);

		this.client = client;

		this.initLanguages();
		this.initNations();
		this.structureManager = new StructureManager(this);
		this.characterManager = new CharacterManager(this);

		this.initGame(scenario);

	}

	/************************
	 * Getters and Setters
	 ************************/
	public const(CharacterManager) getCharacterManager() const {
		return this.characterManager;
	}

	public const(string) getName() const {
		return this.name;
	}
	public void setName(string name) {
		this.name = name;
	}
	public const(Map) getMap() const {
		return this.map;
	}
	public void setMap(Map map) {
		this.map = map;
	}
	public void setMapTile(int i, int j, byte value) {
		this.map.setTile(i, j, value);
	}

	public const(Nation[]) getNations() const {
		return this.nations;
	}
	public void setNations(Nation[] nations) {
		this.nations = nations;
	}
	public void addNation(Nation nation) {
		this.nations ~= nation;
	}

	public const(Nation) getCurrentNation() const {
		return this.nations[this.currentNationIndex];
	}

	public void addNation(string nationName) {
		const(NationPrototype) prototype = this.getNationPrototype(nationName);
		if (prototype is null) {
			return;
		}
		const(Language) language = prototype.getLanguage();
		Nation newNation = new Nation(prototype);

		// create dynasty
		Dynasty dynasty = new Dynasty();
		dynasty.setName(newNation.getName());
		dynasty.setLanguage(language);
		dynasty.setFlagImageName(prototype.getFlagImageName());
		this.characterManager.addDynasty(dynasty);

		// create ruler
		Character male = CharacterManager.characterFactory(null, null, dynasty);
		male.setSex(Sex.MALE);
		male.setBirth(this.currentYear - 18 - uniform(0, 10, this.gen));
		male.setDeath(male.getBirth() - 1);
		male.setName(language.getRandomMaleName());

		Character female = CharacterManager.characterFactory(null, null, dynasty);
		female.setSex(Sex.FEMALE);
		female.setBirth(this.currentYear - 18 - uniform(0, 10, this.gen));
		female.setDeath(female.getBirth() - 1);
		female.setName(language.getRandomFemaleName());

		female.setPartner(male);
		male.setPartner(female);

		if (uniform(0, 2, this.gen) == 0) {
			newNation.setRuler(male);
		} else {
			newNation.setRuler(female);
		}

		this.nations ~= newNation;
	}

	/**
	 * un-const a given nation
	 **/
	public Nation getNation(const(Nation) nation) {
		foreach (Nation nationCursor; this.nations) {
			if (nationCursor == nation) {
				return nationCursor;
			}
		}
		return null;
	}

	public const(NationPrototype[]) getNationPrototypes() const {
		return this.nationPrototypes;
	}

	public const(int) getCurrentYear() const {
		return this.currentYear;
	}
	public void setCurrentYear(int currentYear) {
		this.currentYear = currentYear;
	}

	public Player[] getPlayers() {
		return this.players;
	}
	public void setPlayers(Player[] players) {
		this.players = players;
	}
	public void addPlayer(Player player) {
		this.players ~= player;
	}

	/**
	 * method is called every time a new round is started and at the beginning
	 * of the game
	 **/
	public void startNewRound()
		out {
			// check if proposals were sent
			foreach (const(Proposal) proposal;
					 this.characterManager.getProposalQueue()) {
				if (!proposal.isSent) {
					assert(false,
						   "Game::startNewRound: not all proposals were sent");
				}
			}
		}
		body {
			++this.currentYear;

			foreach (Nation nation; this.nations) {
				nation.getResources().setResource("structureToken", 3.0);
			}

			debug(script) {
				writeln("Game::startNewRound run produce script");
			}
			this.structureManager.runProduceScripts();
			debug(script) {
				writeln("Game::startNewRound run consume script");
			}
			this.structureManager.runConsumeScripts();

			this.giveBirth();
			this.characterDeaths();
			this.sendProposals();
		}


	/**
	 * check every female of every dynasty and check if she could give birth to
	 * a child; role dice to determine success
	 **/
	private void giveBirth() {
		foreach (Dynasty dynasty; this.characterManager.getDynasties()) {
			foreach (Character character; dynasty.getMembers()) {
				Character father = character.getPartner();
				if (character.getSex() == Sex.FEMALE &&
						!character.isDead() &&
						father !is null &&
						father.getAge(this.currentYear) >= 14 &&
						father.getAge(this.currentYear) <= 49 &&
						character.getAge(this.currentYear) >= 16 &&
						character.getAge(this.currentYear) <= 41) {
					// give birth
					if (uniform(0.0, 1.0, this.gen) > 0.75) {
						Character child = CharacterManager.characterFactory(
							father, character, father.getDynasty());
						child.setBirth(this.currentYear);
						child.setDeath(this.currentYear - 1);
						//TODO: birthNation
						if (uniform(0.0, 1.0, this.gen) > 0.51) {
							child.setSex(Sex.FEMALE);
						} else {
							child.setSex(Sex.MALE);
						}

						// let client name the child
						this.client.serverNotify(
							new ObjectMessage!(const(Character))(
								"nameCharacter", child));
					}
				}
			}
		}
	}


	/**
	 * calculate which characters die
	 **/
	private void characterDeaths() {
		foreach (Dynasty dynasty; this.characterManager.getDynasties()) {
			foreach (Character character; dynasty.getMembers()) {
				if (!character.isDead()) {
					if ((uniform(0.0, 1.0, this.gen) < (character.getAge(this.currentYear) / 1800.0) ||
					    uniform(0.0, 1.0, this.gen) < ((4.0 - character.getAge(this.currentYear)) / 100.0)) &&
					    character.getAge(this.currentYear) != 0) {
						this.characterManager.characterDied(character);
						debug(1) {
							writefln("Game::characterDeath %s %s",
							         character.getFullName(), character.getAge(this.currentYear));
						}

						foreach (Nation nation; this.nations) {	// check if ruler died
							if (nation.getRuler == character) {
								Character heir = this.characterManager.getHeir(character);
								nation.setRuler(heir);
								// TODO send client notification "newRuler": nation, ruler
							}
						}

						// send client notification
						this.client.serverNotify(
							new ObjectMessage!(const(Character))(
							"characterDied", character));
					}
				}
			}
		}
	}

	/**
	 * send proposal to receiver for answer
	 **/
	private void sendProposals() {
		foreach (Proposal proposal;
				 this.characterManager.getProposalQueue()) {
			this.client.serverNotify(
				new ObjectMessage!(Tuple!(int, int))(
					"proposal",
					Tuple!(int, int)(proposal.sender.getId(),
									 proposal.receiver.getId())));
			proposal.isSent = true;
		}
	}


	public StructureManager getStructureManager() {
		return this.structureManager;
	}
	public const(StructureManager) getStructureManager() const {
		return this.structureManager;
	}
	public const(Structure[]) getStructures() const {
		return this.structureManager.getStructures();
	}
	public const(Structure) getStructure(int i, int j) const {
		return this.structureManager.getStructure(i, j);
	}


	public void setStructureName(const(Structure) structure, string name) {
		this.structureManager.setStructureName(structure, name);
	}


	public bool addStructure(string structurePrototypeName,
							 const(Nation) nation,
							 const(Position) position) {
		return this.structureManager.addStructure(structurePrototypeName,
												  nation,
												  position);
	}

	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.structureManager.getStructurePrototypes();
	}


	public bool canBuildStructure(string structurePrototypeName,
								  const(Nation) nation,
								  const(Position) position) const {
		return this.structureManager.canBuildStructure(
			structurePrototypeName, nation, position);
	}


	public void setCharacterName(const(Character) character,
								 string name) {
		Character unconstCharacter = this.getCharacter(character.getId());
		if (unconstCharacter.getName() == "") {
			unconstCharacter.setName(name);
		}
	}

	public const(bool) isMarryable(const(Character) c) const {
		return this.characterManager.isMarryable(c);
	}

	public const(bool)
			isMarryable(const(Character) c1, const(Character) c2) const {
		return this.characterManager.isMarryable(c1, c2);
	}
	public const(bool) isMarryable(int c1, int c2) const {
		return this.characterManager.isMarryable(
			this.characterManager.getCharacter(c1),
			this.characterManager.getCharacter(c2));
	}

	public const(const(Character)[]) getMarryableCharacters(int characterId) const {
		return this.characterManager.getMarryableCharacters(characterId);
	}

	public const(bool) canPropose(const(Character) c) const {
		return this.characterManager.canPropose(c);
	}
	public const(Character) getProposedToCharacter(int charId) const {
		return this.characterManager.getProposedToCharacter(charId);
	}

	/**
	 * a proposal was sent from a client
	 **/
	public void sendProposal(int senderCharId, int receiverCharId) {
		this.characterManager.sendProposal(senderCharId, receiverCharId);
	}

	public void proposalAnswered(
			int senderCharId, int receiverCharId, bool answer) {
		this.characterManager.proposalAnswered(
			senderCharId, receiverCharId, answer);
	}

	public Character getCharacter(int id) {
		return this.characterManager.getCharacter(id);
	}
	public const(Character) getCharacter(const(int) id) const {
		return this.characterManager.getCharacter(id);
	}


	/**
	 * get language by name
	 **/
	public const(Language) getLanguage(string languageName) {
		foreach (Language languageCursor; this.languages) {
			if (languageCursor.getName() == languageName) {
				return languageCursor;
			}
		}

		return null;
	}


	/**
	 * get nation prototype by name
	 **/
	public const(NationPrototype) getNationPrototype(string nationName) {
		foreach (const(NationPrototype) prototype; this.nationPrototypes) {
			if (prototype.getName() == nationName) {
				return prototype;
			}
		}

		return null;
	}


	/**
	 * called by client to signal end of turn; performes book keeping
	 **/
	public void endTurn() {
		// check which nation turns next
		++this.currentNationIndex;
		if (this.currentNationIndex >= this.nations.length) {	// new year
			this.currentNationIndex = 0;
			this.startNewRound();

		}
		this.client.serverNotify(new Message("nationChanged"));
	}


	/**
	 * load scenario data and initialize game accordingly
	 **/
	public void initGame(Scenario scenario) {
		this.name = scenario.getName();
		this.currentYear = scenario.getStartYear();
		this.map = new Map(scenario.getMapName);
		foreach (string nationName; scenario.getNationNames()) {
			this.addNation(nationName);
		}

		int i = 0;
		randomShuffle(this.nationColors);
		foreach (Nation nation; this.nations) {
			// create settlement
			SettlementCreator.create(this, nation);
			// set nation color
			nation.setColor(this.nationColors[i % nationColors.length]);

			++i;
		}

		this.currentNationIndex = 0;
	}


	/**
	 * save the current game
	 **/
	public void save(string filename) {
		GameDB.saveToFile(this, filename);
	}


	/**
	 * load languages from JSON files, create objects, add to list
	 **/
	private void initLanguages() {
		foreach (string filename;
				 dirEntries("resources/languages", "*.json", SpanMode.depth)) {
			File file = File(filename, "r");
			string all = file.readln('\0');

			JSONValue json = parseJSON!string(all);
			if (json["_fileType"].str != "language") {		// file type check
				continue;
			}

			string[] maleNames;
			foreach(JSONValue name; json["maleNames"].array) {
				maleNames ~= name.str;
			}
			string[] femaleNames;
			foreach(JSONValue name; json["femaleNames"].array) {
				femaleNames ~= name.str;
			}
			string name = json["name"].str;
			string nobiliaryParticleMale = json["nobiliaryParticleMale"].str;
			string nobiliaryParticleFemale = json["nobiliaryParticleFemale"].str;

			Language language = new Language(name, maleNames, femaleNames,
											 nobiliaryParticleMale,
											 nobiliaryParticleFemale);
			this.languages ~= language;

		}
	}

	/**
	 * load nation prototypes from JSON files, create objects, add to list
	 *
	 * languages have to be loaded first.
	 **/
	private void initNations() {
		foreach (string filename;
				 dirEntries("resources/nations", "*.json", SpanMode.depth)) {
			File file = File(filename, "r");
			string all = file.readln('\0');

			JSONValue json = parseJSON!string(all);
			if (json["_fileType"].str != "nation") {		// file type check
				continue;
			}

			string name = json["name"].str;
			string languageName = json["language"].str;
			string flagImage = json["flagImage"].str;
			string flagImageName = json["flagImageName"].str;

			string[] defaultCityNames;
			foreach(JSONValue cityName; json["defaultCityNames"].array) {
				defaultCityNames ~= cityName.str;
			}

			const(Language) language = this.getLanguage(languageName);
			if (language is null) {
				debug (1) {
					writefln("Game::initNations language %s not found",
							 languageName);
				}
				continue;
			}

			NationPrototype nation = new NationPrototype();
			nation.setName(name);
			nation.setLanguage(language);
			nation.setFlagImage(flagImage);
			nation.setFlagImageName(flagImageName);
			nation.setDefaultCityNames(defaultCityNames);

			this.nationPrototypes ~= nation;

		}
	}
}
