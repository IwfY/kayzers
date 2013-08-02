module game;

import map;
import client;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;

public class Game {
	private Map map;
	private Client[] clients;
	private StructurePrototype[] structurePrototypes;

	public this() {
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
		int i = 0;
		foreach (string filename;
				 dirEntries("resources/structures", "*.json", SpanMode.depth)) {
			File structureFile = File(filename, "r");
			string all = structureFile.readln('\0');
			
			JSONValue json = parseJSON!string(all);
			
			string[string] structureData;
			foreach(string s; json.object.keys) {
				structureData[s] = json[s].str;
			}
			this.structurePrototypes ~= new StructurePrototype(structureData);
			
		}
	}
}
