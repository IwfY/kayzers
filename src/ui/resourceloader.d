module ui.resourceloader;

import client;
import constants;
import ui.renderhelper;
import world.nation;
import world.nationprototype;
import world.structureprototype;

import std.stdio;
import std.string;

class ResourceLoader {
	public static void loadTexturesAndFonts(RenderHelper renderer) {
		//TODO declare general resources in a file

		//renderer.registerTexture("tile_1_2", "resources/img/water.png");
		renderer.registerTexture(
				"tile_1",
				["resources/img/water.png", "resources/img/water_2.png"],
				[30, 30]);
		renderer.registerTexture(
				"tile_1_2",
				["resources/img/water.png", "resources/img/water_2.png"],
				[30, 30]);

		renderer.registerTexture("tile_template",
		                         "resources/img/tile_template.png");

		renderer.registerTexture("tile_0", "resources/img/grass.png");
		renderer.registerTexture("tile_0_2", "resources/img/grass_2.png");
		renderer.registerTexture("tile_2", "resources/img/mountain.png");
		renderer.registerTexture("tile_2_2", "resources/img/mountain.png");
		renderer.registerTexture("tile_3", "resources/img/trees.png");
		renderer.registerTexture("tile_3_2", "resources/img/trees2.png");

		renderer.registerTexture("cloud", "resources/img/cloud.png");
		renderer.registerTexture("cloud2", "resources/img/cloud2.png");

		renderer.registerTexture("mouseTile",
								 "resources/img/grid_border.png");
		renderer.registerTexture("selectedTile",
								 "resources/img/grid_cursor.png");
		renderer.registerTexture("border_top",
								 "resources/img/grid_border_top.png");
		renderer.registerTexture("border_right",
								 "resources/img/grid_border_right.png");
		renderer.registerTexture("border_bottom",
								 "resources/img/grid_border_bottom.png");
		renderer.registerTexture("border_left",
								 "resources/img/grid_border_left.png");

		renderer.registerTexture("ui_popup_background",
								 "resources/img/ui/mainmenu_button.png");
		renderer.registerTexture("minimap_bg",
								 "resources/img/ui/minimap_bg.png");
		renderer.registerTexture("ui_background",
								 "resources/img/ui/ui_background.png");
		renderer.registerTexture("button_default",
								 "resources/img/ui/button_default.png");
		renderer.registerTexture("mainmenu_bg",
								 "resources/img/ui/mainmenu_bg.png");
		renderer.registerTexture("mainmenu_button",
								 "resources/img/ui/mainmenu_button.png");
		renderer.registerTexture("mainmenu_button_hover",
				"resources/img/ui/mainmenu_button_hover.png");
		renderer.registerTexture("border_round_30",
								 "resources/img/ui/border_round_30.png");
		renderer.registerTexture(NULL_TEXTURE,
								 "resources/img/ui/null.png");
		// icons
		renderer.registerTexture("gold",
								 "resources/img/ui/gold.png");
		renderer.registerTexture("inhabitants",
								 "resources/img/ui/inhabitants.png");

		//TODO make portable
		renderer.registerFont(STD_FONT, "/usr/share/fonts/TTF/DejaVuSans.ttf");
		renderer.registerFont("mainMenuHead",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  80);
	}

	/**
	 * load all textures that are specific to the started game
	 **/
	public static void loadGameTextures(Client client, RenderHelper renderer) {
		// load textures for structures
		foreach (const(StructurePrototype) structurePrototype;
				 client.getStructurePrototypes()) {
			debug(2) {
				writefln("load texture(s) for structure %s",
						 structurePrototype.getName());
			}
			bool success = renderer.registerTexture(
						structurePrototype.getIconImageName(),
						structurePrototype.getIconImage());
			assert (success,
					format("ResourceLoader::loadGameTextures " ~
						   "couldn't load texture %s.'",
						   structurePrototype.getIconImage()));

			success = renderer.registerTexture(
					structurePrototype.getTileImageName(),
					structurePrototype.getTileImage());
			assert (success,
					format("ResourceLoader::loadGameTextures " ~
						   "couldn't load texture %s.'",
						   structurePrototype.getIconImage()));
		}

		// load textures for nations
		foreach (const(NationPrototype) prototype;
				 client.getNationPrototypes()) {
			debug(2) {
				writefln("load texture(s) for nation %s",
						 prototype.getName());
			}
			bool success = renderer.registerTexture(
						prototype.getFlagImageName(),
						prototype.getFlagImage());
			assert (success,
					format("ResourceLoader::loadGameTextures " ~
						   "couldn't load texture %s.'",
						   prototype.getFlagImage()));
		}

		// create nation colored tiles
		foreach (const(Nation) nation;
		         client.getNations()) {
			bool success = renderer.registerColoredTexture(
				"tile_template", "tile_" ~ nation.getColor().getHex(),
				nation.getColor());
			assert (success,
			        format("ResourceLoader::loadGameTextures " ~
					       "couldn't create texture %s.'",
					       "tile_" ~ nation.getColor().getHex()));
		}
	}
}
