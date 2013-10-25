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
				[
					"resources/img/water_n01.png",
					"resources/img/water_n02.png",
					"resources/img/water_n03.png",
					"resources/img/water_n04.png",
					"resources/img/water_n05.png",
					"resources/img/water_n06.png",
					"resources/img/water_n07.png",
					"resources/img/water_n08.png",
					"resources/img/water_n09.png",
					"resources/img/water_n10.png",
					"resources/img/water_n11.png"
				],
				[12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]);
		renderer.registerTexture(
				"tile_1_2",
				[
					"resources/img/water_n01.png",
					"resources/img/water_n02.png",
					"resources/img/water_n03.png",
					"resources/img/water_n04.png",
					"resources/img/water_n05.png",
					"resources/img/water_n06.png",
					"resources/img/water_n07.png",
					"resources/img/water_n08.png",
					"resources/img/water_n09.png",
					"resources/img/water_n10.png",
					"resources/img/water_n11.png"
				],
				[12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]);

		// tile template used to generate colored tile textures
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
		renderer.registerTexture("button_rename",
		                         "resources/img/ui/button_rename.png");
		renderer.registerTexture("mainmenu_bg",
								 "resources/img/ui/mainmenu_bg.png");
		renderer.registerTexture("mainmenu_button",
								 "resources/img/ui/mainmenu_button.png");
		renderer.registerTexture("mainmenu_button_hover",
				"resources/img/ui/mainmenu_button_hover.png");
		renderer.registerTexture("border_round_30",
								 "resources/img/ui/border_round_30.png");

		renderer.registerTexture("portrait_male",
								 "resources/img/portraits/male.png");
		renderer.registerTexture("portrait_female",
								 "resources/img/portraits/female.png");

		renderer.registerTexture("black",
								 "resources/img/black.png");
		renderer.registerTexture("white",
								 "resources/img/white.png");
		renderer.registerTexture("grey_a127", "resources/img/grey_a127.png");
		renderer.registerTexture("white_a10pc", "resources/img/white_a10pc.png");

		renderer.registerTexture(NULL_TEXTURE,
								 "resources/img/ui/null.png");
		// nine patch textures
		renderer.registerTexture("button_9patch",
		                         "resources/img/ui/button_9patch.png");
		renderer.registerTexture("button_thin_9patch",
		                         "resources/img/ui/button_thin_9patch.png");
		renderer.registerTexture("inputbox_9patch",
		                         "resources/img/ui/inputbox_9patch.png");

		renderer.registerTextureFromNinePatch("button_9patch", "bg_300_140",
											  300, 140);
		renderer.registerTextureFromNinePatch("button_thin_9patch",
											  "button_100_28",
											  100, 28);
		renderer.registerTextureFromNinePatch("inputbox_9patch",
											  "inputbox_260_30",
											  260, 30);

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
		renderer.registerFont("notificationLarge",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  30);
		renderer.registerFont("maprenderer_structure_name",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  9);
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

			// make grey scale icon, prefixed with '_grey'
			renderer.registerGreyScaledTexture(
				structurePrototype.getIconImageName(),
				structurePrototype.getIconImageName() ~ "_grey");

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

		foreach (const(Nation) nation; client.getNations()) {
			// create nation colored tiles
			bool success = renderer.registerColoredTexture(
				"tile_template", "tile_" ~ nation.getColor().getHex(),
				nation.getColor());
			assert (success,
			        format("ResourceLoader::loadGameTextures " ~
					       "couldn't create texture %s.'",
					       "tile_" ~ nation.getColor().getHex()));
			// create nation colores rectangle texture
			success = renderer.registerColoredTexture(
				"white", nation.getColor().getHex(),
				nation.getColor());
			assert (success,
			        format("ResourceLoader::loadGameTextures " ~
					       "couldn't create texture %s.'",
					       nation.getColor().getHex()));
		}
	}
}
