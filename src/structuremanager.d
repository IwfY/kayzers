module structuremanager;

import game;
import map;
import position;
import world.nation;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.stdio;
import std.typecons;

class StructureManager {
	private StructurePrototype[] structurePrototypes;
	private Structure[int[2]] structures;
	private Game game;


	public this(Game game) {
		this.game = game;
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

			bool nameable = json["nameable"].type == JSON_TYPE.TRUE;

			string[string] structureData;
			foreach(string s; json.object.keys) {
				structureData[s] = json[s].str;
			}

			StructurePrototype newPrototype =
					new StructurePrototype(structureData);
			newPrototype.setNameable(nameable);
			this.structurePrototypes ~= newPrototype;
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

	public Structure getStructure(int i, int j) {
		Structure tmp = this.structures.get([i, j], null);
		return tmp;
	}
	public const(Structure) getStructure(int i, int j) const {
		const(Structure) tmp = this.structures.get([i, j], null);
		return tmp;
	}
	public Structure getStructure(Position position) {
		return this.getStructure(position.i, position.j);
	}


	public bool isTileEmpty(int i, int j) const {
		return (this.getStructure(i, j) is null);
	}
	public bool isTileEmpty(Position position) const {
		return this.isTileEmpty(position.i, position.j);
	}



	/**
	 * checks whether a structure can be build by a nation at given position
	 **/
	public bool canBuildStructure(string structurePrototypeName,
								  const(Nation) nation,
								  Position position) const {
		// is there a structure already?
		if (!this.isTileEmpty(position)) {
			return false;
		}

		// is it a land tile?
		const(Map) map = this.game.getMap();
		if (!map.isLand(position.i, position.j)) {
			return false;
		}

		// neighbouring structure?
		Tuple!(int, int) neighbourLocations[];
		neighbourLocations ~= Tuple!(int, int)(0, -1); // top
		neighbourLocations ~= Tuple!(int, int)(1, 0); // right
		neighbourLocations ~= Tuple!(int, int)(0, 1); // bottom
		neighbourLocations ~= Tuple!(int, int)(-1, 0); // left
		bool foundNeighbour = false;
		foreach(Tuple!(int, int) location; neighbourLocations) {
			if (this.getStructure(position.i + location[0],
								  position.j + location[1]) !is null) {
				if (this.getStructure(position.i + location[0],
								  position.j + location[1]).getNation() ==
							nation) {
					foundNeighbour = true;
					break;
				}
			}
		}
		if (!foundNeighbour) {
			return false;
		}

		// enough resources
		if (!nation.getResources().getResourceAmount("structureToken") >= 1.0) {
			return false;
		}

		return true;
	}


	public void addStructure(Structure structure) {
		const(Position) position = structure.getPosition();
		this.structures[[position.i, position.j]] = structure;
	}

	/**
	 * add structure for a given nation to the game
	 *
	 * @param force: if force is true don't check for build requirements
	 **/
	public bool addStructure(string structurePrototypeName,
							 const(Nation) nationIn,
							 Position position,
							 bool force=false) {
		if (!force && !this.canBuildStructure(structurePrototypeName,
											  nationIn, position)) {
			return false;
		}

		// get a non-const nation reference
		Nation nation = this.game.getNation(nationIn);


		const(StructurePrototype) prototype =
				this.getStructurePrototypeByName(structurePrototypeName);
		if (prototype is null) {
			debug(1) {
				writefln("Game::addStructure StructurePrototype %s not found",
						 structurePrototypeName);
			}
			return false;
		}

		Structure newStructure = new Structure();
		newStructure.setPrototype(prototype);
		newStructure.setPosition(position);
		newStructure.setNation(nation);
		newStructure.setCreatingNation(nation);

		newStructure.runInitScript();

		// consume resources
		nation.getResources().addResource("structureToken", -1.0);

		this.structures[[position.i, position.j]] = newStructure;
		debug(1) {
			writefln("Game::addStructure Add structure %s at position (%d, %d) for nation %s",
					 prototype.getName(), position.i, position.j,
					 nation.getName());
		}
		return true;
	}


	/**
	 * run the produce script on all structures
	 **/
	public void runProduceScripts() {
		foreach (Structure structure; this.structures) {
			structure.runProduceScript();
		}
	}
}
