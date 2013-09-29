module ui.cloudrenderer;

import client;
import map;
import position;
import rect;
import ui.maprenderer;
import ui.renderer;
import ui.renderhelper;

import derelict.sdl2.sdl;

import std.math;
import std.random;

class Cloud {
	public PositionDouble position;
	public double speed;
	public string textureName;

	public this(PositionDouble position, double speed=1.0, string textureName="cloud") {
		this.position = position;
		this.speed = speed;
		this.textureName = textureName;
	}
}


class CloudRenderer : Renderer {
	private MapRenderer mapRenderer;
	private Cloud[] clouds;
	private const(Map) map;
	private double moveDirectionI;
	private double moveDirectionJ;

	public this(Client client, RenderHelper renderer, MapRenderer mapRenderer,
	            const(Map) map) {
		super(client, renderer);
		this.map = map;
		this.mapRenderer = mapRenderer;

		this.moveDirectionI = 0.01;
		this.moveDirectionJ = 0.015;

		for (int i = 0; i < 20; ++i) {
			Cloud newCloud = new Cloud(new PositionDouble(0.0, 0.0));
			this.initCloud(newCloud);
			this.clouds ~= newCloud;
		}

		Random random = Random(unpredictableSeed);
	}

	private void initCloud(Cloud cloud, bool atBorder=false) {
		Random random = Random(unpredictableSeed);

		// new clouds should be created at border
		if (atBorder) {
			if (dice(1, 1)) {	// 50%
				if (this.moveDirectionI >= 0) {
					cloud.position.i = -10;
				} else {
					cloud.position.i = this.map.getWidth();
				}
				cloud.position.j = uniform(0, this.map.getHeight() + 5) - 5;
			} else {
				if (this.moveDirectionJ >= 0) {
					cloud.position.j = -10;
				} else {
					cloud.position.j = this.map.getHeight();
				}
				cloud.position.i = uniform(0, this.map.getWidth() + 5) - 5;
			}
		} else {
			cloud.position.i = uniform(0, this.map.getWidth() + 10, random) - 10;
			cloud.position.j = uniform(0, this.map.getHeight() + 10, random) - 10;
		}

		cloud.speed = 0.7 + uniform(0.0, 0.6, random);

		if (dice(0.25, 0.75)) {	// 75%
			cloud.textureName = "cloud";
		} else {
			cloud.textureName = "cloud2";
		}
	}

	public override void handleEvent(SDL_Event event) {
	}

	public override void render(int tick=0) {
		// change clouds move direction
		if (dice(200, 1)) {	// 0.5%
			this.moveDirectionI += uniform(0.0, 0.01) - 0.005;
			this.moveDirectionJ += uniform(0.0, 0.01) - 0.005;
		}

		double zoom = cast(double)(this.mapRenderer.getZoom());
		if (zoom >= 1.0) {
			foreach (Cloud cloud; this.clouds) {
				cloud.position.i += this.moveDirectionI * cloud.speed;
				cloud.position.j += this.moveDirectionJ * cloud.speed;

				// cloud out of map - reinitialize
				if (cloud.position.i < -10 ||
				    	cloud.position.i > this.map.getWidth() + 5 ||
				    	cloud.position.j < -10 ||
				    	cloud.position.j > this.map.getHeight() + 5) {
					this.initCloud(cloud, true);
				}

				Rect dest = new Rect(0, 0,
				                     cast(int)round(512.0 / zoom),
				                     cast(int)round(512.0 / zoom));
				this.mapRenderer.getFractionalTileCoordinate(cloud.position.i,
				                                             cloud.position.j,
							                                 dest.x, dest.y);
				this.renderer.drawTexture(dest, cloud.textureName);
			}
		}
	}
}

