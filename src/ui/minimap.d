module ui.minimap;

import client;
import map;
import rect;
import utils;
import ui.renderhelper;
import ui.widget;
import world.structure;

import derelict.sdl2.sdl;

import std.conv;
import std.math;

class MiniMap : Widget {
	private const(Client) client;
	private const(Map) map;
	private int tileWidth;
	private int tileHeight;
	private int offsetX;
	private int textureWidth;
	private int textureHeight;

	public this(RenderHelper renderer,
				string name,
				string textureName,
				const(SDL_Rect *)bounds,
				const(Client) client) {
		super(renderer, name, textureName, bounds);

		this.client = client;
		this.map = this.client.getMap();

		this.tileWidth = 2;
		this.tileHeight = 2;
		this.offsetX = cast(int)(this.map.getWidth() * tileWidth * 0.5);

		int maxEdgeLength = max(this.map.getWidth(), this.map.getHeight());
		this.textureWidth = this.tileWidth * maxEdgeLength;
		this.textureHeight = this.tileHeight * maxEdgeLength;

		this.generateTerrainMap();
		this.updateMap();
	}


	private void drawTileIJ(int i, int j, string textureName) {
		int offsetY = 0;
		SDL_Rect *position = new SDL_Rect();

		position.x = cast(int)(round(
				this.offsetX + i * 0.5 * this.tileWidth
							 - j * 0.5 * this.tileWidth));
		position.y = cast(int)(round(
				offsetY + j * 0.5 * this.tileHeight
						+ i * 0.5 * this.tileHeight));

		position.w = this.tileWidth;
		position.h = this.tileHeight;

		this.renderer.drawTexture(position, textureName);
	}


	/**
	 * generate a texture of the terrain
	 **/
	private void generateTerrainMap() {
		// create a texture to render map to
		this.renderer.setRenderTargetTexture(
			"minimap_terrain", this.textureWidth, this.textureHeight);

		this.renderer.drawTexture(0, 0, textureWidth, textureHeight,
		                          this.textureName);

		// render tiles
		for (uint i = 0; i < this.map.getWidth(); ++i) {
			for (uint j = 0; j < this.map.getHeight(); ++j) {
				byte tile = this.map.getTile(i, j);
				string textureName = "tile_" ~ text(tile);
				this.drawTileIJ(i, j, textureName);
			}
		}

		this.renderer.resetRenderTarget();
	}


	/**
	 * generate texture with structures
	 **/
	private void updateMap() {
		// create a texture to render map to
		this.renderer.setRenderTargetTexture(
				"minimap", this.textureWidth, this.textureHeight);

		// render terrain
		this.renderer.drawTexture(0, 0, "minimap_terrain");

		// render structures
		foreach (const(Structure) structure; this.client.getStructures()) {
			this.drawTileIJ(structure.getPosition().i,
			                structure.getPosition().j,
			                "tile_" ~ structure.getNation().getColor().getHex());
		}

		this.renderer.resetRenderTarget();
	}


	public override void draw() {
		this.updateMap();
		this.renderer.drawTexture(this.bounds, "minimap");
	}
}
