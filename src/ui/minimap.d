module ui.minimap;

import client;
import color;
import map;
import position;
import rect;
import serverstub;
import utils;
import ui.maprenderer;
import ui.renderer;
import ui.renderhelper;
import world.structure;

import derelict.sdl2.sdl;

import std.conv;
import std.math;

class MiniMap : Renderer {
	private ServerStub serverStub;
	private MapRenderer mapRenderer;
	private const(Map) map;
	private int tileWidth;
	private int tileHeight;
	private int offsetX;
	private int textureWidth;
	private int textureHeight;

	public this(Client client, RenderHelper renderer,
				MapRenderer mapRenderer) {
		super(client, renderer);
		this.serverStub = this.client.getServerStub();
		this.map = this.serverStub.getMap();
		this.mapRenderer = mapRenderer;

		this.tileWidth = 2;
		this.tileHeight = 2;
		this.offsetX = cast(int)(this.map.getWidth() * tileWidth * 0.5);

		int maxEdgeLength = max(this.map.getWidth(), this.map.getHeight());
		this.textureWidth = this.tileWidth * maxEdgeLength;
		this.textureHeight = this.tileHeight * maxEdgeLength;

		this.generateTerrainMap();
		this.updateMap();
	}


	/**
	 * get the coordinate for a tile (screen region as reference system)
	 **/
	private Position getRelCoordinateForTile(const(Position) tile) const {
		int offsetY = 0;
		Position position = new Position();

		position.i = cast(int)(round(
				this.offsetX + tile.i * 0.5 * this.tileWidth
							 - tile.j * 0.5 * this.tileWidth));
		position.j = cast(int)(round(
				offsetY + tile.j * 0.5 * this.tileHeight
						+ tile.i * 0.5 * this.tileHeight));

		position.i = cast(int)(
			cast(double)position.i *
			cast(double)this.screenRegion.w /
			cast(double)this.textureWidth);
		position.j = cast(int)(
			cast(double)position.j *
			cast(double)this.screenRegion.h /
			cast(double)this.textureHeight);

		return position;
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
	 * get the tile coordinate for a pixel (minimap texture as reference system)
	 **/
	private const(Position) getTileAtPixel(int x, int y) const {
		double nearestJ = (this.tileWidth * y +
						   this.tileHeight * (-x + this.offsetX)) /
						  (this.tileWidth * this.tileHeight);
		double nearestI = (2 * x - 2 * this.offsetX +
						   nearestJ * this.tileWidth) / this.tileWidth;

		Position result = new Position(cast(int)round(nearestI),
									   cast(int)round(nearestJ));
		return result;
	}


	/**
	 * generate a texture of the terrain
	 **/
	private void generateTerrainMap() {
		// create a texture to render map to
		this.renderer.setRenderTargetTexture(
			"minimap_terrain", this.textureWidth, this.textureHeight);

		this.renderer.drawTexture(0, 0, textureWidth, textureHeight,
		                          "minimap_bg");

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
		foreach (const(Structure) structure; this.serverStub.getStructures()) {
			this.drawTileIJ(structure.getPosition().i,
			                structure.getPosition().j,
			                "tile_" ~ structure.getNation().getColor().getHex());
		}

		this.renderer.resetRenderTarget();
	}


	public override void render(int tick=0) {
		this.updateMap();
		this.renderer.drawTexture(this.screenRegion, "minimap");

		// map renderer viewport center marker
		Position viewportCenter =
			this.getRelCoordinateForTile(this.mapRenderer.getTileAtCenter());
		this.renderer.drawLine(this.screenRegion.x + viewportCenter.i - 1,
							   this.screenRegion.y + viewportCenter.j,
							   this.screenRegion.x + viewportCenter.i + 1,
							   this.screenRegion.y + viewportCenter.j,
							   new Color(255, 255, 255));
		this.renderer.drawLine(this.screenRegion.x + viewportCenter.i,
							   this.screenRegion.y + viewportCenter.j - 1,
							   this.screenRegion.x + viewportCenter.i,
							   this.screenRegion.y + viewportCenter.j + 1,
							   new Color(255, 255, 255));
	}

	public override void handleEvent(SDL_Event event) {
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
				new SDL_Point(event.button.x, event.button.y);
			if (rectContainsPoint(this.screenRegion, mousePosition)) {
				// calculate relative mouse position
				int relPositionX = event.button.x - this.screenRegion.x;
				int relPositionY = event.button.y - this.screenRegion.y;
				relPositionX = cast(int)(
					cast(double)relPositionX *
					cast(double)this.textureWidth /
					cast(double)this.screenRegion.w);
				relPositionY = cast(int)(
					cast(double)relPositionY *
					cast(double)this.textureHeight /
					cast(double)this.screenRegion.h);

				const(Position) mapPosition =
					this.getTileAtPixel(relPositionX, relPositionY);
				this.mapRenderer.panToTile(mapPosition);
			}
		}
	}
}
