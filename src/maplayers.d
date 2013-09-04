module maplayers;

import constants;
import map;
import maplayer;
import position;
import rect;
import structuremanager;
import world.structure;
import world.structureprototype;

class TileMapLayer : MapLayer {
	private const(Map) map;
	
	public this(const(Map) map, int width, int height) {
		super(width, height);
		this.map = map;
	}

	public override string getTextureName(int i, int j) {
		byte tile = this.map.getTile(i, j);
		string textureName;
		if (tile == Map.LAND) {
			textureName = "grass";
		} else if (tile == Map.WATER) {
			textureName = "water";
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
