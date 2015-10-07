module structuremanager;

import game;
import map;
import position;
import world.nation;
import world.structure;
import world.structureprototype;

import std.file;
import std.json;
import std.random;
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

			JSONValue json = parseJSON(all);
			if (json["_fileType"].str() != "structure") {		// file type check
				continue;
			}

			bool nameable = (json["nameable"].type == JSON_TYPE.TRUE);

			string[string] structureData;
			foreach(string s; json.object.keys) {
				if (json[s].type == JSON_TYPE.STRING) {
					structureData[s] = json[s].str;
				}
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
	public Structure[] getStructures() {
		return this.structures.values;
	}

	public void setStructures(Structure[int[2]] structures) {
		this.structures = structures;
	}

	public Structure getStructure(const(Structure) structure) {
		foreach (Structure structureCursor; this.getStructures()) {
			if (structureCursor == structure) {
				return structureCursor;
			}
		}
		return null;
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
	public bool isTileEmpty(const(Position) position) const {
		return this.isTileEmpty(position.i, position.j);
	}



	/**
	 * checks whether a structure can be build by a nation at given position
	 **/
	public bool canBuildStructure(string structurePrototypeName,
								  const(Nation) nation,
								  const(Position) position) const {
		const(Map) map = this.game.getMap();
		// is tile on map?
		if (!map.isPositionInMap(position.i, position.j)) {
			return false;
		}
		// is there a structure already?
		if (!this.isTileEmpty(position)) {
			return false;
		}

		// is it a land tile?
		if (!map.isBuildable(position.i, position.j)) {
			return false;
		}

		// neighbouring structure?
		Tuple!(int, int)[] neighbourLocations;
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

	/**
	 * add structure for a given nation to the game
	 *
	 * @param force: if force is true don't check for build requirements
	 **/
	public bool addStructure(string structurePrototypeName,
							 const(Nation) nationIn,
							 const(Position) position,
							 bool force=false) {
		if (!force && !this.canBuildStructure(structurePrototypeName,
											  nationIn, position)) {
			return false;
		}

		// get a non-const nation reference
		Nation nation = this.game.getNation(nationIn);

		StructurePrototype prototype =
				this.getStructurePrototypeByName(structurePrototypeName);
		if (prototype is null) {
			debug(1) {
				writefln("Game::addStructure StructurePrototype %s not found",
						 structurePrototypeName);
			}
			return false;
		}

		// convert map tile to land
		this.game.setMapTile(position.i, position.j, Map.LAND);

		// initialize new structure
		Structure newStructure = new Structure();
		newStructure.setPrototype(prototype);
		newStructure.setPosition(new Position(position.i, position.j));
		newStructure.setNation(nation);

		newStructure.runInitScript();

		// consume resources
		nation.getResources().addResource("structureToken", -1.0);

		this.structures[[position.i, position.j]] = newStructure;
		nation.addStructure(newStructure);

		debug(1) {
			writefln("Game::addStructure Add structure %s at position (%d, %d) for nation %s",
					 prototype.getName(), position.i, position.j,
					 nation.getName());
		}
		return true;
	}


	public void setStructureName(const(Structure) structure, string name) {
		Structure structureUnConst = this.getStructure(structure);
		structureUnConst.setName(name);
	}


	/**
	 * check if a structure can be removed from the map
	 **/
	public bool canRemoveStructure(int i, int j) {
		Structure structure = this.getStructure(i, j);
		Nation nation = structure.getNation();
		if (structure is null) {
			return false;
		}

		// nation seats can not be removed
		if (nation.getSeat() == structure) {
			return false;
		}

		return true;
	}


	public bool removeStructure(int i, int j) {
		if (!this.canRemoveStructure(i, j)) {
			return false;
		}
		Structure structure = this.getStructure(i, j);
		this.structures[[i, j]] = null;
		Nation nation = structure.getNation();
		nation.removeStructure(structure);

		return true;
	}


	/**
	 * run the produce script on all structures
	 **/
	public void runProduceScripts() {
		Random random = Random(unpredictableSeed);
		int[2][] keys = this.structures.keys;
		foreach (int[2] key; randomCover(keys, random)) {
			debug(script) {
				writefln("Script::runProduceScripts run produce script for %s",
						 structures[key].getPrototype().getName());
			}
			structures[key].runProduceScript();
		}
	}

	/**
	 * run the consume script on all structures
	 **/
	public void runConsumeScripts() {
		Random random = Random(unpredictableSeed);
		int[2][] keys = this.structures.keys;
		foreach (int[2] key; randomCover(keys, random)) {
			debug(script) {
				writefln("Script::runConsumeScripts run consume script for %s",
						 structures[key].getPrototype().getName());
			}
			structures[key].runConsumeScript();
		}
	}
}
