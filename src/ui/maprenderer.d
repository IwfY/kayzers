module ui.maprenderer;

import client;
import color;
import map;
import messagebroker;
import observer;
import position;
import rect;
import ui.cloudrenderer;
import ui.maplayer;
import ui.maplayers;
import ui.renderer;
import ui.renderhelper;
import world.nation;
import world.structure;
import world.structureprototype;
import utils;

import derelict.sdl2.sdl;

import std.math;
import std.stdio;
import std.typecons;

static enum Border {BORDER_TOP, BORDER_RIGHT, BORDER_BOTTOM, BORDER_LEFT};

class MapRenderer : Renderer, Observer {
	private Rebindable!(const(Map)) map;
	private Rect tileDimensions;
	private MapLayer[int] mapLayers;
	private CloudRenderer cloudRenderer;

	// offset is added to the tile position when drawing
	private SDL_Point *offset;
	private int zoom;
	private Position selectedPosition;	// in tile coordinates (i, j)
	private Position mousePosition;
	private SDL_Point *mouseCoordinate;
	private SDL_Point *mousePressedCoordinate;
	private bool mousePressed;
	private MessageBroker messageBroker;


	public this(Client client, RenderHelper renderer,
				MessageBroker messageBroker) {
		super(client, renderer);
		this.messageBroker = messageBroker;

		this.map = this.client.getMap();
		this.selectedPosition = new Position();
		this.offset = new SDL_Point(0, 0);
		this.mouseCoordinate = new SDL_Point(0, 0);
		this.mousePosition = new Position(0, 0);
		this.tileDimensions = new Rect();
		this.tileDimensions.w = 120;
		this.tileDimensions.h = 70;
		this.zoom = 2;
		this.mousePressed = false;
		this.mousePressedCoordinate = new SDL_Point(0, 0);
		this.mapLayers[0] = new TileMapLayer(this.map,
											 this.map.getWidth(),
											 this.map.getHeight());
		this.mapLayers[1] = new StructureMapLayer(
				this.client,
				this.map.getWidth(), this.map.getHeight());
		this.mapLayers[2] = new MarkerMapLayer(
				this.selectedPosition, this.mousePosition,
				this.map.getWidth(), this.map.getHeight());
		this.cloudRenderer = new CloudRenderer(
				this.client, this.renderer, this, this.map);

		this.messageBroker.register(this, "nationChanged");
	}


	public ~this() {
		this.messageBroker.unregister(this, "nationChanged");
		delete this.cloudRenderer;
	}


	public override void notify(string message) {
		// active nation changed
		if (message == "nationChanged") {
			// pan to new nation's seat
			const(Nation) currentNation = this.client.getCurrentNation();
			this.panToTile(currentNation.getSeat().getPosition());
		}
	}


	/**
	 * pan the map center to the given tile coordinate
	 **/
	public void panToTile(int i, int j) {
		int x1, y1, x2, y2, iCenter, jCenter;
		this.offset.x = 0;
		this.offset.y = 0;
		this.getTopLeftTileCoordinate(i, j, x1, y1);
		this.offset.x = -x1;
		this.offset.y = -y1;
		this.getTileAtPixel(new SDL_Point(this.screenRegion.w / 2,
										  this.screenRegion.h / 2),
							iCenter, jCenter);
		this.offset.x = 0;
		this.offset.y = 0;
		this.getTopLeftTileCoordinate(iCenter, jCenter, x2, y2);
		this.offset.x = -x1 + (x2 - x1) * this.zoom;
		this.offset.y = -y1 + (y2 - y1) * this.zoom;
	}
	public void panToTile(const(Position) position) {
		this.panToTile(position.i, position.j);
	}


	/**
	 * draw tile at given screen coordinate
	 * takes zoom level into account for tile dimension
	 **/
	private void drawTile(int x, int y, string textureName) {
		SDL_Rect *position = new SDL_Rect();
		position.x = x;
		position.y = y;

		position.w = cast(int)(
			ceil(cast(double)this.tileDimensions.w / cast(double)this.zoom));
		position.h = cast(int)(
			ceil(cast(double)this.tileDimensions.h / cast(double)this.zoom));

		this.renderer.drawTexture(position, textureName);
	}




	private void drawTileIJ(int i, int j, string textureName) {
		SDL_Rect *position = new SDL_Rect();
		this.getTopLeftTileCoordinate(i, j, position.x, position.y);

		position.w = cast(int)(round(
			ceil(cast(double)this.tileDimensions.w / cast(double)this.zoom)));
		position.h = cast(int)(round(
			ceil(cast(double)this.tileDimensions.h / cast(double)this.zoom)));

		this.renderer.drawTexture(position, textureName);
	}


	private void drawBorder(int i, int j, Border border, const(Color) color) {
		int x, y;
		int tileWidth = cast(int)(round(
				cast(double)this.tileDimensions.w /
				cast(double)this.zoom));
		int tileHeight = cast(int)(round(
				cast(double)this.tileDimensions.h /
				cast(double)this.zoom));

		this.getTopLeftTileCoordinate(i, j, x, y);

		if (border == Border.BORDER_TOP) {
			this.renderer.drawLine(x + cast(int)(0.5 * tileWidth),
									y + 1,
									x + tileWidth - 1,
									y + cast(int)(0.5 * tileHeight),
									color);
		} else if (border == Border.BORDER_RIGHT) {
			this.renderer.drawLine(x + tileWidth - 1,
									y + cast(int)(0.5 * tileHeight),
									x + cast(int)(0.5 * tileWidth),
									y + tileHeight - 1,
									color);
		} else if (border == Border.BORDER_BOTTOM) {
			this.renderer.drawLine(x + cast(int)(0.5 * tileWidth),
									y + tileHeight - 1,
									x + 1,
									y + cast(int)(0.5 * tileHeight),
									color);
		} else if (border == Border.BORDER_LEFT) {
			this.renderer.drawLine(x + 1,
									y + cast(int)(0.5 * tileHeight),
									x + cast(int)(0.5 * tileWidth),
									y + 1,
									color);
		}
	}


	/**
	 * get the number of half tiles that fit horizontally and vertically in the
	 * screen region (takes zoom level into account)
	 *
	 * i.e. if the offset was (0, 0) return the coordinate of the bottom right
	 * corner of the map screen region as (iMax, jMax)
	 **/
	private void getTileResolution(out int iMax, out int jMax) {
		iMax = cast(int)(floor(2 * this.screenRegion.w /
							   (this.tileDimensions.w / this.zoom)));
		jMax = cast(int)(floor(2 * this.screenRegion.h /
							   (this.tileDimensions.h / this.zoom)));
		writefln("getTileResolution %d : %d", iMax, jMax);
	}


	public const(Rect) getTileDimensions() const {
		return this.tileDimensions;
	}


	/**
	 * get the tile coordinate for a given screen position
	 *
	 * TODO: distance function could be weighted depending on tile
	 * 		 dimension
	 **/
	public void getTileAtPixel(SDL_Point *position, out int i, out int j) {
		double tileWidth =
				cast(double)this.tileDimensions.w /
				cast(double)this.zoom;
		double tileHeight =
				cast(double)this.tileDimensions.h /
				cast(double)this.zoom;

		double offsetX =
				(cast(double)this.offset.x /
				cast(double)this.zoom) + 0.5 * tileWidth;
		double offsetY =
				(cast(double)this.offset.y /
				cast(double)this.zoom) + 0.5 * tileHeight;

		double nearestJ = (tileWidth * (position.y - offsetY) +
						   tileHeight * (-position.x + offsetX)) /
						  (tileWidth * tileHeight);
		double nearestI = (2 * position.x - 2 * offsetX +
						   nearestJ * tileWidth) / tileWidth;

		int x, y;
		double distance, minDistance;
		// check for distances to 4 surounding tiles
		this.getTopLeftTileCoordinate(
			cast(int)floor(nearestI), cast(int)floor(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		minDistance = getDistance(position.x, position.y, x, y);
		i = cast(int)floor(nearestI);
		j = cast(int)floor(nearestJ);

		this.getTopLeftTileCoordinate(
			cast(int)floor(nearestI), cast(int)ceil(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)floor(nearestI);
			j = cast(int)ceil(nearestJ);
		}

		this.getTopLeftTileCoordinate(
			cast(int)ceil(nearestI), cast(int)floor(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)ceil(nearestI);
			j = cast(int)floor(nearestJ);
		}

		this.getTopLeftTileCoordinate(
			cast(int)ceil(nearestI), cast(int)ceil(nearestJ), x, y);
		x += 0.5 * tileWidth;
		y += 0.5 * tileHeight;
		distance = getDistance(position.x, position.y, x, y);
		if (distance < minDistance) {
			minDistance = distance;
			i = cast(int)ceil(nearestI);
			j = cast(int)ceil(nearestJ);
		}

		debug(2) {
			writefln("MapRenderer::getTileAtPixel i: %d, j: %d", i, j);
		}
	}


	/**
	 * get the top left coordinate of a tile drawn in column i, row j
	 **/
	private void getTopLeftTileCoordinate(int i, int j,
										  out int x, out int y) {
		double tileWidth =
				cast(double)this.tileDimensions.w /
				cast(double)this.zoom;
		double tileHeight =
				cast(double)this.tileDimensions.h /
				cast(double)this.zoom;

		double offsetX =
				cast(double)this.offset.x /
				cast(double)this.zoom;
		double offsetY =
				cast(double)this.offset.y /
				cast(double)this.zoom;

		x = cast(int)(round(
				offsetX + i * 0.5 * tileWidth - j * 0.5 * tileWidth));
		y = cast(int)(round(
				offsetY + j * 0.5 * tileHeight + i * 0.5 * tileHeight));

		debug(3) {
			writefln("MapRenderer::getTopLeftTileCoordinate i: %d, j: %d --> x: %d, y:%d",
					 i, j, x, y);
		}
	}


	/**
	 * get the coordinate of a tile drawn in column i, row j
	 **/
	public void getFractionalTileCoordinate(double i, double j,
											 out int x, out int y) {
		int xTopLeft, yTopLeft;
		this.getTopLeftTileCoordinate(cast(int)(floor(i)), cast(int)(floor(j)),
		                              xTopLeft, yTopLeft);
		double iFraction = i - cast(int)(floor(i));
		double jFraction = j - cast(int)(floor(j));

		double tileWidth =
			cast(double)this.tileDimensions.w /
				cast(double)this.zoom;
		double tileHeight =
			cast(double)this.tileDimensions.h /
				cast(double)this.zoom;
		
		x = cast(int)(round(
			xTopLeft + iFraction * 0.5 * tileWidth - jFraction * 0.5 * tileWidth));
		y = cast(int)(round(
			yTopLeft + jFraction * 0.5 * tileHeight + iFraction * 0.5 * tileHeight));
		
		debug(3) {
			writefln("MapRenderer::getFractionalTileCoordinate " ~
			         "i: %f, j: %f --> x: %d, y:%d",
			         i, j, x, y);
		}
	}


	/**
	 * center preserving zoom
	 *
	 * @param zoom ... zoom level
	 * 				   	1 ... close
	 * 					4 ... far
	 **/
	public void setZoom(int zoom)
		in {
			assert(zoom >= 1 && zoom <= 12,
				   "MapRenderer::setZoom Invalid zoom level");
		}
		body {
			int centerIOld, centerJOld;
			this.getTileAtPixel(
					new SDL_Point(this.screenRegion.w / 2,
								  this.screenRegion.h / 2),
					centerIOld, centerJOld);
			this.zoom = zoom;
			this.panToTile(centerIOld, centerJOld);
		}


	public void setOffset(int x, int y) {
		this.offset.x = x;
		this.offset.y = y;
	}


	public void moveOffset(int x, int y) {
		this.offset.x += x * zoom;
		this.offset.y += y * zoom;
	}


	public SDL_Point *getOffset() {
		return this.offset;
	}


	public const(int) getZoom() const {
		return this.zoom;
	}


	public const(Position) getSelectedPosition() const {
		return this.selectedPosition;
	}


	public override void setScreenRegion(int x, int y, int w, int h) {
		super.setScreenRegion(x, y, w, h);
		this.cloudRenderer.setScreenRegion(x, y, w, h);
	}


	public override void handleEvent(SDL_Event event) {
		// key down
		if (event.type == SDL_KEYDOWN) {
			if (event.key.keysym.sym == SDLK_1) {
				this.setZoom(1);
			} else if (event.key.keysym.sym == SDLK_2) {
				this.setZoom(2);
			} else if (event.key.keysym.sym == SDLK_3) {
				this.setZoom(3);
			} else if (event.key.keysym.sym == SDLK_4) {
				this.setZoom(4);
			} else if (event.key.keysym.sym == SDLK_5) {
				this.setZoom(12);
			} else if (event.key.keysym.sym == SDLK_KP_5) {
				this.panToTile(
						cast(int)(this.map.getWidth() / 2),
						cast(int)(this.map.getHeight() / 2));
			}
			// selected region WASD
			else if (event.key.keysym.sym == SDLK_w) {
				this.selectedPosition.j -= 1;
			} else if (event.key.keysym.sym == SDLK_d) {
				this.selectedPosition.i += 1;
			} else if (event.key.keysym.sym == SDLK_s) {
				this.selectedPosition.j += 1;
			} else if (event.key.keysym.sym == SDLK_a) {
				this.selectedPosition.i -= 1;
			}
			// map offset - array keys
			else if (event.key.keysym.sym == SDLK_UP) {
				this.offset.y += 3 * this.tileDimensions.h * this.zoom;
			} else if (event.key.keysym.sym == SDLK_RIGHT) {
				this.offset.x -= 2 * this.tileDimensions.w * this.zoom;
			} else if (event.key.keysym.sym == SDLK_DOWN) {
				this.offset.y -= 3 * this.tileDimensions.h * this.zoom;
			} else if (event.key.keysym.sym == SDLK_LEFT) {
				this.offset.x += 2 * this.tileDimensions.w * this.zoom;
			}
		}

		// right mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_RIGHT) {
			if (rectContainsPoint(this.screenRegion, this.mouseCoordinate)) {
				// start panning
				this.mousePressed = true;
			}
			this.mousePressedCoordinate.x = event.button.x;
			this.mousePressedCoordinate.y = event.button.y;
		}
		// right mouse up
		else if (event.type == SDL_MOUSEBUTTONUP &&
				event.button.button == SDL_BUTTON_RIGHT) {
			this.mousePressed = false;
		}
		// left mouse down
		else if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			this.mouseCoordinate.x = event.button.x;
			this.mouseCoordinate.y = event.button.y;
			if (rectContainsPoint(this.screenRegion, this.mouseCoordinate)) {
				// select tile
				this.getTileAtPixel(this.mouseCoordinate,
									this.selectedPosition.i,
									this.selectedPosition.j);
			}
		}
		// mouse motion
		else if (event.type == SDL_MOUSEMOTION) {
			this.mouseCoordinate.x = event.motion.x;
			this.mouseCoordinate.y = event.motion.y;
			if (this.mousePressed) {
				this.moveOffset(
						event.motion.x - this.mousePressedCoordinate.x,
						event.motion.y - this.mousePressedCoordinate.y);
				this.mousePressedCoordinate.x = event.motion.x;
				this.mousePressedCoordinate.y = event.motion.y;
			}
		}
	}


	public override void render() {
		if (this.renderer !is null && this.map !is null) {
			// mouse marker
			this.getTileAtPixel(this.mouseCoordinate,
								this.mousePosition.i, this.mousePosition.j);

			// get tiles section to draw per frame
			int iMin, iMax, jMin, jMax, devNull, windowWidth, windowHeight;
			this.getTileAtPixel(
					new SDL_Point(this.screenRegion.x, this.screenRegion.y),
					iMin, devNull);
			this.getTileAtPixel(
					new SDL_Point(this.screenRegion.w, this.screenRegion.h),
					iMax, devNull);
			this.getTileAtPixel(
					new SDL_Point(this.screenRegion.w, this.screenRegion.y),
					devNull, jMin);
			this.getTileAtPixel(
					new SDL_Point(this.screenRegion.x, this.screenRegion.h),
					devNull, jMax);
			iMin -= 1;
			jMin -= 1;
			iMax += 1;
			jMax += 1;
			iMin = min!int(max!int(iMin, 0), this.map.getWidth() - 1);
			jMin = min!int(max!int(jMin, 0), this.map.getHeight() - 1);
			iMax = max!int(min!int(iMax, this.map.getWidth() - 1), 0);
			jMax = max!int(min!int(jMax, this.map.getHeight() - 1), 0);


			// render tiles
			int[] mapLayerKeys = this.mapLayers.keys.sort;
			foreach (int key; mapLayerKeys) {
				for (uint i = iMin; i <= iMax; ++i) {
					for (uint j = jMin; j <= jMax; ++j) {
						string textureName =
								this.mapLayers[key].getTextureName(i, j);
						this.drawTileIJ(i, j, textureName);
					}
				}
			}

			// draw structures
			foreach (const(Structure) structure; this.client.getStructures()) {
				const(StructurePrototype) prototype = structure.getPrototype();
				const(Position) position = structure.getPosition();
				const(Nation) nation = structure.getNation();
				const(Color) color = nation.getColor();
				int x, y;
				this.getTopLeftTileCoordinate(position.i, position.j, x, y);

				// top neighbor border
				Rebindable!(const(Structure)) neighbor =
						this.client.getStructure(position.i, position.j - 1);
				if (neighbor is null ||
						neighbor.getNation() != structure.getNation()) {
					this.drawBorder(position.i, position.j,
									Border.BORDER_TOP,
									color);
				}
				// right neighbor border
				neighbor =
						this.client.getStructure(position.i + 1, position.j);
				if (neighbor is null ||
						neighbor.getNation() != structure.getNation()) {
					this.drawBorder(position.i, position.j,
									Border.BORDER_RIGHT,
									color);
				}
				// bottom neighbor border
				neighbor =
						this.client.getStructure(position.i, position.j + 1);
				if (neighbor is null ||
						neighbor.getNation() != structure.getNation()) {
					this.drawBorder(position.i, position.j,
									Border.BORDER_BOTTOM,
									color);
				}
				// left neighbor border
				neighbor =
						this.client.getStructure(position.i - 1, position.j);
				if (neighbor is null ||
						neighbor.getNation() != structure.getNation()) {
					this.drawBorder(position.i, position.j,
									Border.BORDER_LEFT,
									color);
				}
			}

			//clouds
			this.cloudRenderer.render();



			// draw mouse tile coordinate on screen
			debug(1) {
				import std.conv;
				this.renderer.drawText(
						0, 0,
						text(this.mousePosition.i) ~ ":" ~
							text(this.mousePosition.j));
			}
		}
	}
}
