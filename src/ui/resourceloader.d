module ui.resourceloader;

import client;
import constants;
import ui.renderhelper;
import world.nation;
import world.nationprototype;
import world.structureprototype;

import std.array;
import std.file;
import std.stdio;
import std.string;

class ResourceLoader {
	public static void loadTexturesAndFonts(RenderHelper renderer) {
		// load resources from definition files
		foreach (string filename;
				 dirEntries("resources/definitions",
							"*.txt",
							SpanMode.depth)) {
			ResourceLoader.loadResourcesFromDefinitionFile(renderer, filename);
		}

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

		renderer.registerTextureFromNinePatch("inputbox_9patch",
											  "button_100_28",
											  100, 28);
		renderer.registerTextureFromNinePatch("inputbox_9patch",
		                                      "button_30_30",
		                                      30, 30);
		renderer.registerTextureFromNinePatch("inputbox_9patch",
											  "inputbox_260_30",
											  260, 30);
		renderer.registerTextureFromNinePatch("inputbox_9patch",
											  "inputbox_230_30",
											  230, 30);


		//TODO make portable
		renderer.registerFont(STD_FONT, "/usr/share/fonts/TTF/DejaVuSans.ttf");
		renderer.registerFont("menuHead",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  80);
		renderer.registerFont("menuHead2",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  50);
		renderer.registerFont("notificationLarge",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  30);
		renderer.registerFont("std_20",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  20);
		renderer.registerFont("maprenderer_structure_name",
							  "/usr/share/fonts/TTF/DejaVuSans.ttf",
							  9);
	}


	/**
	 * parse the definition file and load resources
	 **/
	private static void loadResourcesFromDefinitionFile(
			RenderHelper renderer, const(string) filename) {
		File file = File(filename, "r");

		string line;
		while ((line = file.readln()) !is null) {
			string[] fields = line.strip().split(" ");
			if (fields.length == 0) {
				continue;
			}
			// static texture
			if (fields[0] == "st") {
				assert(fields.length == 3);

				string[dchar] translateTable = ['"': ""];
				string textureName = fields[1];
				textureName = textureName.translate(translateTable);

				string texturePath = fields[2];
				texturePath = texturePath.translate(translateTable);

				renderer.registerTexture(textureName, texturePath);
			}
		}
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
