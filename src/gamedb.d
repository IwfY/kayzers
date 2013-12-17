module gamedb;

import d2sqlite.d2sqlite3;

class GameDB {
	private Database database;

	public this() {
		//this.database = Database("test.sqlite");
		this.database = Database(":memory:");

		this.createTables();
	}

	private void createTables() {
		this.database.execute(
			"CREATE TABLE character (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                dynastyId INTEGER,
                birth INTEGER NOT NULL, death INTEGER)"
			);
	}
}

