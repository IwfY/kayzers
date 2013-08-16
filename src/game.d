module game;

import client;
import map;
import player;
import position;
import structuremanager;
import world.dynasty;
import world.language;
import world.nation;
import world.nationprototype;
import world.scenario;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;

public class Game {
	private string name;
	private Map map;
	private Client client;
	private Player[] players;
	private Nation[] nations;
	private NationPrototype[] nationPrototypes;
	private Language[] languages;
	private StructureManager structureManager;
	private int currentYear;

	public this(Scenario scenario) {
		this.initLanguages();
		this.initNations();
		this.structureManager = new StructureManager(this);

		this.name = scenario.getName();
		this.currentYear = scenario.getStartYear();
		this.map = new Map(scenario.getMapName);
		foreach (string nationName; scenario.getNationNames()) {
			this.addNation(nationName);
		}

	}

	/************************
	 * Getters and Setters
	 ************************/
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

	public Nation[] getNations() {
		return this.nations;
	}
	public void setNations(Nation[] nations) {
		this.nations = nations;
	}
	public void addNation(Nation nation) {
		this.nations ~= nation;
	}

	public void addNation(string nationName) {
		const(NationPrototype) prototype = this.getNationPrototype(nationName);
		if (prototype is null) {
			return;
		}
		Nation newNation = new Nation(prototype);

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

	public Client getClient() {
		return this.client;
	}
	public void setClient(Client client) {
		this.client = client;
		if (this.nations.length > 0) {
			this.client.setCurrentNation(this.nations[0]);
		}
	}


	public void startNewRound() {
		++this.currentYear;

		foreach (Nation nation; this.nations) {
			nation.getResources().setResource("structureToken", 3.0);
		}
	}


	public const(Structure[]) getStructures() const {
		return this.structureManager.getStructures();
	}
	public const(Structure) getStructure(int i, int j) const {
		return this.structureManager.getStructure(i, j);
	}


	public bool addStructure(string structurePrototypeName,
							 const(Nation) nation,
							 Position position) {
		return this.structureManager.addStructure(structurePrototypeName,
												  nation,
												  position);
	}

	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.structureManager.getStructurePrototypes();
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
	 * called by client to signal end of turn; performes book keeping and
	 * sends next Nation to the client
	 *
	 * @param nation nation that ends turn
	 **/
	public bool endTurn(const(Nation) nation) {
		int i;

		// get index of nation
		for(i = 0; i < this.nations.length; ++i) {
			if (this.nations[i] == nation) {
				break;
			}
		}
		// check which nation turns next
		++i;
		if (i >= this.nations.length) {		// new year
			i = 0;
			this.startNewRound();

		}
		this.client.setCurrentNation(this.nations[i]);

		return true;
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

			this.nationPrototypes ~= nation;

		}
	}
}
