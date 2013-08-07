module game;

import client;
import map;
import player;
import position;
import structuremanager;
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
	private StructureManager structureManager;
	private int currentYear;

	public this() {
		this.initLanguages();

		this.structureManager = new StructureManager();
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


	public void startGame() {
		foreach (Nation nation; this.nations) {
			nation.getResources().setResource("structureToken", 3.0);
		}
	}


	public const(Structure[]) getStructures() const {
		return this.structureManager.getStructures();
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
			++this.currentYear;

			foreach (Nation nationCursor; this.nations) {
				nationCursor.getResources().setResource("structureToken", 3.0);
			}

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
}
