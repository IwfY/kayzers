module world.settlementcreator;

import game;
import map;
import position;
import structuremanager;
import world.nation;
import world.structure;

import std.random;

/**
 * factory for start settlement of nation
 **/
class SettlementCreator {

	/**
	 * create a basic settlement randomly on the map
	 **/
	public static bool create(Game game, Nation nation) {
		const(Map) map = game.getMap();
		int tries = 0;
		// stop if you can't find a place after this many tries
		int maxTries = 100;
		bool done = false;
		int i, j;
		while (!done && tries < maxTries) {
			i = uniform(0, map.getWidth());
			j = uniform(0, map.getHeight());

			done = SettlementCreator.create(
					game, nation, new Position(i, j));

			++tries;
		}

		return done;

	}

	/**
	 * create a basic settlement at a specified position on the map
	 **/
	public static bool create(Game game,
							   Nation nation,
							   Position position) {
		const(Map) map = game.getMap();
		StructureManager structureManager = game.getStructureManager();
		nation.getResources().setResource("structureToken", 2);
		Position farmPosition = new Position(position.i + 1, position.j);

		if (structureManager.canBuildStructure("House", nation, position) &&
				structureManager.canBuildStructure(
						"Farm", nation, farmPosition)) {
			structureManager.addStructure("House", nation, position);
			structureManager.addStructure("Farm", nation, farmPosition);
			const(Structure) house = structureManager.getStructure(position);
			nation.setSeat(house);

			debug(1) {
				import std.stdio;
				writefln("SettlementCreator::create new settlement (%d:%d)",
						 position.i, position.j);
			}

			return true;
		}

		return false;
	}
}
