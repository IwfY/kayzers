module game;

import client;
import map;
import player;
import position;
import world.dynasty;
import world.language;
import world.nation;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;

public class Game {
	private Map map;
	private Client client;
	private Player[] players;
	private Nation[] nations;
	private Language[] languages;
	private Structure[] structures;
	private StructurePrototype[] structurePrototypes;

	public this() {
		this.initLanguages();
		this.initStructurePrototypes();
	}

	/************************
	 * Getters and Setters
	 ************************/

	public Map getMap() {
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

	public const(Structure[]) getStructures() const {
		return this.structures;
	}
	public void setStructures(Structure[] structures) {
		this.structures = structures;
	}
	public void addStructure(Structure structure) {
		this.structures ~= structure;
	}

	public bool addStructure(string structurePrototypeName,
							  const(Nation) nation,
							  Position position) {
		const(StructurePrototype) prototype =
				this.getStructurePrototypeByName(structurePrototypeName);
		if (prototype is null) {
			debug(1) {
				writefln("Game::addStructure Structure %s not found",
						 structurePrototypeName);
			}
			return false;
		}

		Structure newStructure = new Structure();
		newStructure.setPrototype(prototype);
		newStructure.setPosition(position);
		newStructure.setNation(nation);
		newStructure.setCreatingNation(nation);

		this.structures ~= newStructure;
		debug(1) {
			writefln("Game::addStructure Add structure %s at position (%d, %d) for nation %s",
					 prototype.getName(), position.i, position.j,
					 nation.getName());
		}
		return true;
	}
	

	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.structurePrototypes;
	}

	private StructurePrototype getStructurePrototypeByName(string name) {
		foreach (StructurePrototype prototype; this.structurePrototypes) {
			if (prototype.getName() == name) {
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
		if (i >= this.nations.length) {
			i = 0;
		}
		this.client.setCurrentNation(this.nations[i]);

		return true;
	}


	/**
	 * load structure prototypes as JSON from files; create objects and add
	 * them to the stucture prototype list
	 **/
	private void initStructurePrototypes() {
		foreach (string filename;
				 dirEntries("resources/structures", "*.json", SpanMode.depth)) {
			File structureFile = File(filename, "r");
			string all = structureFile.readln('\0');

			JSONValue json = parseJSON!string(all);
			if (json["_fileType"].str != "structure") {		// file type check
				continue;
			}

			string[string] structureData;
			foreach(string s; json.object.keys) {
				structureData[s] = json[s].str;
			}
			this.structurePrototypes ~= new StructurePrototype(structureData);
		}
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
}
