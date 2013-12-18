module gamedb;

import std.conv;
import std.file;
import std.string;

import d2sqlite.d2sqlite3;

import game;
import world.character;
import world.charactermanager;
import world.dynasty;

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
                dynastyId INTEGER,
                birth INTEGER NOT NULL, death INTEGER,
                sex INTEGER,
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
				debug(2) {
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
                languageName TEXT,
                flagImageName TEXT)"
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
			debug(2) {
				import std.stdio;
				writeln("GameDB::saveDynasties " ~ sqlCommand);
			}
			db.execute(sqlCommand);
		}
	}


	public static bool saveToFile(Game game, string filename) {
		// remove old file
		if (isFile(filename)) {
			remove(filename);
		}
		Database db = Database(filename);

		GameDB.saveDynasties(db, game.getCharacterManager());
		GameDB.saveCharacters(db, game.getCharacterManager());

		return true;
	}
}

