module ui.characterproposalrenderer;

import derelict.sdl2.sdl;

import client;
import ui.renderer;
import ui.renderhelper;
import ui.widgetrenderer;
import world.character;

class CharacterProposalRenderer : WidgetRenderer {
	private const(Character) character;
	private bool active;

	public this(Client client, RenderHelper renderer, const(Character) character) {
		this.character = character;
		super(client, renderer, "grey_a127");
		this.active = true;

	}


	protected override void initWidgets() {
		foreach (const(Character) characterCursor;
		         this.client.getMarryableCharacters(this.character.getId())) {
			import std.stdio; writeln(characterCursor.getFullName());
		}
	}

	protected override void updateWidgets() {
	}

	public override void render(int tick=0) {
		if (this.active) {
			super.render(tick);
		}
	}


	public bool isActive() {
		return this.active;
	}

	public override void handleEvent(SDL_Event event) {
		if (this.active) {

			// widgets
			super.handleEvent(event);
		}
	}
}

