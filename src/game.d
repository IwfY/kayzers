module game;

import map;
import client;
import world.language;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;

public class Game {
	private Map map;
	private Client[] clients;
	private Language[] languages;
	private StructurePrototype[] structurePrototypes;

	public this() {
		this.initLanguages();
		this.initStructurePrototypes();
	}

	public Map getMap() {
		return this.map;
	}

	public void setMap(Map map) {
		this.map = map;
	}

	public void addClient(Client client) {
		this.clients ~= client;
	}


	public const(StructurePrototype[]) getStructurePrototypes() const {
		return this.structurePrototypes;
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
