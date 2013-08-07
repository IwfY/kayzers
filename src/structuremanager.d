module structuremanager;

import position;
import world.nation;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;

class StructureManager {
	private StructurePrototype[] structurePrototypes;
	private Structure[int[2]] structures;


	public this() {
		this.initStructurePrototypes();
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


	public const(Structure[]) getStructures() const {
		return this.structures.values;
	}

	public void setStructures(Structure[int[2]] structures) {
		this.structures = structures;
	}

	public void addStructure(Structure structure) {
		const(Position) position = structure.getPosition();
		this.structures[[position.i, position.j]] = structure;
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

		this.structures[[position.i, position.j]] = newStructure;
		debug(1) {
			writefln("Game::addStructure Add structure %s at position (%d, %d) for nation %s",
					 prototype.getName(), position.i, position.j,
					 nation.getName());
		}
		return true;
	}
}
