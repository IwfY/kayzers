module game;

import map;
import client;

import std.stdio;

public class Game {
	private Map map;
	private Client[] clients;

	public this() {
		
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
}
