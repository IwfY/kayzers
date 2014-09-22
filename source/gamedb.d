module gamedb;

import std.conv;
import std.file;
import std.string;

import d2sqlite3;

import game;
import map;
import structuremanager;
import world.character;
import world.charactermanager;
import world.dynasty;
import world.nation;
import world.structure;

class GameDB {
	/**
	 * TODO
	 * prepare a string to avoid sql injections
	 **/
	private static string sqlEscape(string string) {
		return string;
	}

	private static void
			saveCharacters(Database db,
						   const(CharacterManager) characterManager) {
		// create db table
		db.execute(
			"CREATE TABLE character (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                dna TEXT,
                dynastyId INTEGER NOT NULL,
                birth INTEGER NOT NULL, death INTEGER,
                sex INTEGER NOT NULL,
                fatherId INTEGER,
                motherId INTEGER,
                partnerID INTEGER)"
			);

		foreach(const(Dynasty) dynasty; characterManager.getDynasties()) {
			foreach(const(Character) character; dynasty.getMembers()) {
				string sqlCommand = "
					INSERT INTO character
						(id, name, dna, dynastyId, birth, death,
						 sex, fatherId, motherId, partnerId)
					VALUES
						(%d, \"%s\", \"%s\", %d, %d, %d, %d, %s, %s, %s)".format(
						character.getId(),
						GameDB.sqlEscape(character.getName()),
						GameDB.sqlEscape(character.getDna()),
						character.getDynasty().getId(),
						character.getBirth(),
						character.getDeath(),
						to!(int)(character.getSex()),
						((character.getFather() is null) ?
							"NULL" : text(character.getFather().getId())),
						((character.getMother() is null) ?
							"NULL" : text(character.getMother().getId())),
						((character.getPartner() is null) ?
							"NULL" : text(character.getPartner().getId())));
				debug(1) {
					import std.stdio;
					writeln("GameDB::saveCharacters " ~ sqlCommand);
				}
				db.execute(sqlCommand);
			}
		}
	}


	private static void
			saveDynasties(Database db,
						  const(CharacterManager) characterManager) {
		// create db table
		db.execute(
			"CREATE TABLE dynasty (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                languageName TEXT NOT NULL,
                flagImageName TEXT NOT NULL)"
			);

		foreach(const(Dynasty) dynasty; characterManager.getDynasties()) {
			string sqlCommand = "
				INSERT INTO dynasty
					(id, name, languageName, flagImageName)
				VALUES
					(%d, \"%s\", \"%s\", \"%s\")".format(
					dynasty.getId(),
					GameDB.sqlEscape(dynasty.getName()),
					GameDB.sqlEscape(dynasty.getLanguage().getName()),
					GameDB.sqlEscape(dynasty.getFlagImageName()));
			debug(1) {
				import std.stdio;
				writeln("GameDB::saveDynasties " ~ sqlCommand);
			}
			db.execute(sqlCommand);
		}
	}


	private static void saveNations(Database db, const(Nation[]) nations) {
		// create db table
		db.execute(
			"CREATE TABLE nation (
                id INTEGER PRIMARY KEY,
                prototypeName TEXT NOT NULL,
                seatId INTEGER NOT NULL,
                rulerId INTEGER NOT NULL,
                colorR INTEGER NOT NULL,
                colorG INTEGER NOT NULL,
                colorB INTEGER NOT NULL)"
			);

		db.execute(
			"CREATE TABLE nationResources (
                nationId INTEGER NOT NULL,
                resourceName TEXT NOT NULL,
                amount FLOAT NOT NULL)"
			);

		foreach(const(Nation) nation; nations) {
			// nation
			string sqlCommand = "
				INSERT INTO nation
					(id, prototypeName, seatId, rulerId, colorR, colorG, colorB)
				VALUES
					(%d, \"%s\", %d, %d, %d, %d, %d)".format(
					nation.getId(),
					GameDB.sqlEscape(nation.getPrototype().getName()),
					nation.getSeat().getId(),
					nation.getRuler().getId(),
					nation.getColor().r,
					nation.getColor().g,
					nation.getColor().b);
			debug(1) {
				import std.stdio;
				writeln("GameDB::saveNations " ~ sqlCommand);
			}
			db.execute(sqlCommand);

			// nation resources
			foreach(string key, const(double) value;
					nation.getResources().getResources()) {
				sqlCommand = "
					INSERT INTO nationResources
						(nationId, resourceName, amount)
					VALUES
						(%d, \"%s\", %f)".format(
						nation.getId(),
						GameDB.sqlEscape(key),
						value);
				debug(1) {
					import std.stdio;
					writeln("GameDB::saveNations " ~ sqlCommand);
				}
				db.execute(sqlCommand);
			}
		}
	}


	private static void
			saveStructures(Database db,
						   const(StructureManager) structureManager) {
		db.execute(
			"CREATE TABLE structure (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                prototypeName TEXT NOT NULL,
                nationId INTEGER NOT NULL,
                positionI INTEGER NOT NULL,
                positionJ INTEGER NOT NULL)"
			);

		db.execute(
			"CREATE TABLE structureResources (
                structureId INTEGER NOT NULL,
                resourceName TEXT NOT NULL,
                amount FLOAT NOT NULL)"
			);

		foreach(const(Structure) structure; structureManager.getStructures()) {
			string sqlCommand = "
				INSERT INTO structure
					(id, name, prototypeName, nationId, positionI, positionJ)
				VALUES
					(%d, \"%s\", \"%s\", %d, %d, %d)".format(
					structure.getId(),
					GameDB.sqlEscape(structure.getName()),
					GameDB.sqlEscape(structure.getPrototype().getName()),
					structure.getNation().getId(),
					structure.getPosition().i,
					structure.getPosition().j);
			debug(1) {
				import std.stdio;
				writeln("GameDB::saveStructures " ~ sqlCommand);
			}
			db.execute(sqlCommand);

			// structure resources
			foreach(string key, const(double) value;
					structure.getResources().getResources()) {
				sqlCommand = "
					INSERT INTO structureResources
						(structureId, resourceName, amount)
					VALUES
						(%d, \"%s\", %f)".format(
						structure.getId(),
						GameDB.sqlEscape(key),
						value);
				debug(1) {
					import std.stdio;
					writeln("GameDB::saveStructures " ~ sqlCommand);
				}
				db.execute(sqlCommand);
			}
		}
	}


	private static void saveMap(Database db, const(Map) map) {
		db.execute(
			"CREATE TABLE map (
                width INTEGER NOT NULL,
                height INTEGER NOT NULL,
                data TEXT NOT NULL)"
			);

		string mapData;
		for (int i = 0; i < map.getWidth(); ++i) {
			for (int j = 0; j < map.getHeight(); ++j) {
				mapData ~= text(map.getTile(i, j));
			}
		}

		string sqlCommand = "
			INSERT INTO map
				(width, height, data)
			VALUES
				(%d, %d, \"%s\")".format(
				map.getWidth(),
				map.getHeight(),
				mapData);
		debug(1) {
			import std.stdio;
			writeln("GameDB::saveMap " ~ sqlCommand);
		}
		db.execute(sqlCommand);
	}


	private static void saveMetaData(Database db, const(Game) game) {
		db.execute(
			"CREATE TABLE meta (
				name TEXT NOT NULL,
				currentNationId INTEGER NOT NULL,
				currentYear INTEGER NOT NULL)"
		);

		string sqlCommand = "
			INSERT INTO meta
				(name, currentNationId, currentYear)
			VALUES
				(\"%s\", %d, %d)".format(
				game.getName(),
				game.getCurrentNation().getId(),
				game.getCurrentYear());
		debug(1) {
			import std.stdio;
			writeln("GameDB::saveMetaData " ~ sqlCommand);
		}
		db.execute(sqlCommand);
	}


	public static bool saveToFile(Game game, string filename) {
		// remove old file
		if (isFile(filename)) {
			remove(filename);
		}
		Database db = Database(filename);

		GameDB.saveDynasties(db, game.getCharacterManager());
		GameDB.saveCharacters(db, game.getCharacterManager());
		GameDB.saveNations(db, game.getNations());
		GameDB.saveStructures(db, game.getStructureManager());
		GameDB.saveMap(db, game.getMap());
		GameDB.saveMetaData(db, game);

		return true;
	}
}

