module maplayers;

import constants;
import map;
import maplayer;
import position;
import rect;
import structuremanager;
import utils;
import world.structure;
import world.structureprototype;

import std.conv;

class TileMapLayer : MapLayer {
	private const(Map) map;

	// map that defines when to use an alternative tile texture
	private byte[] tileAlterationMap;

	public this(const(Map) map, int width, int height) {
		super(width, height);
		this.map = map;
		this.tileAlterationMap.length = this.width * this.height;
		this.buildTileAlterationMap();
	}

	private void buildTileAlterationMap() {
		for (int i = 0; i < this.width; ++i) {
			for (int j = 0; j < this.height; ++j) {
				this.tileAlterationMap[i * this.width + j] =
						cast(byte)(hash(i, j, 0.8));
			}
		}
	}

	public override string getTextureName(int i, int j) {
		byte tile = this.map.getTile(i, j);
		string textureName = "tile_" ~ text(tile);

		if (this.tileAlterationMap[i * this.width + j] != 0) {
			textureName ~= "_2";
		}

		return textureName;
	}
}


class StructureMapLayer : MapLayer {
	private const(StructureManager) structureManager;

	public this(const(StructureManager) structureManager,
				int width, int height) {
		super(width, height);
		this.structureManager = structureManager;
	}

	public override string getTextureName(int i, int j) {
		const(Structure) structure = this.structureManager.getStructure(i, j);
		if (structure !is null) {
			const(StructurePrototype) prototype = structure.getPrototype();
			if (prototype !is null) {
				return prototype.getTileImageName();
			}
		}

		return NULL_TEXTURE;
	}
}


class MarkerMapLayer : MapLayer {
	private const(Rect) selectedRegion;
	private const(Position) mousePosition;

	public this(const(Rect) selectedRegion,	const(Position) mousePosition,
				int width, int height) {
		super(width, height);
		this.selectedRegion = selectedRegion;
		this.mousePosition = mousePosition;
	}

	public override string getTextureName(int i, int j) {
		if ((i == this.mousePosition.i) && (j == this.mousePosition.j)) {
			return "mouseTile";
		}
		if ((i == this.selectedRegion.x) && (j == this.selectedRegion.y)) {
			return "selectedTile";
		}
		return NULL_TEXTURE;
	}
}
