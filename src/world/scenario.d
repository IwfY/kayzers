module world.scenario;

import map;
import world.nationprototype;

import std.conv;
import std.file;
import std.json;
import std.stdio;

class ScenarioLoader {
	public static Scenario loadScenario(string filename) {
		File file = File(filename, "r");
		string all = file.readln('\0');

		JSONValue json = parseJSON!string(all);
		if (json["_fileType"].str != "scenario") {		// file type check
			return null;
		}

		string[] nationNames;
		foreach(JSONValue name; json["nations"].array) {
			nationNames ~= name.str;
		}

		string name = json["name"].str;
		string mapName = json["map"].str;
		int startYear = to!int(json["startYear"].integer);

		Scenario scenario = new Scenario();
		scenario.setName(name);
		scenario.setStartYear(startYear);
		scenario.setNationNames(nationNames);
		scenario.setMapName(mapName);

		return scenario;
	}

	public static Scenario[string] loadScenarios(string directory) {
		Scenario[string] outScenarios;

		foreach (string filename;
				 dirEntries(directory, "*.json", SpanMode.depth)) {
			Scenario newScenario = ScenarioLoader.loadScenario(filename);
			if (newScenario !is null) {
				outScenarios[newScenario.getName()] = newScenario;
			}
		}

		return outScenarios;
	}
}


class Scenario {
	private string name;
	private string mapName;
	private int startYear;
	private string[] nationNames;


	public this() {

	}

	public string getName() {
        return this.name;
	}
	public void setName(string name) {
			this.name = name;
	}

	public const(int) getStartYear() const {
		return this.startYear;
	}
	public void setStartYear(int startYear) {
		this.startYear = startYear;
	}

	public const(string) getMapName() const {
		return this.mapName;
	}
	public void setMapName(string mapName) {
		this.mapName = mapName;
	}

	public const(string[]) getNationNames() const {
		return this.nationNames;
	}
	public void setNationNames(string[] nationNames) {
		this.nationNames = nationNames;
	}
}
