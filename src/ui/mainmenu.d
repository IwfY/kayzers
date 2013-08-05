module ui.mainmenu;

import client;
import renderer;
import renderhelper;
import ui.button;

import derelict.sdl2.sdl;

class MainMenu : Renderer {
	private Client client;
	private Button exitButton;
	
	public this(Client client, RenderHelper renderer) {
		super(renderer);
		this.client = client;

		this.initWidgets();
	}

	private void initWidgets() {
		this.exitButton = new Button(this.renderer,
									 "start",
									 "mainmenu_button",
									 new SDL_Rect(0, 0, 10, 20),
									 &this.mainMenuCallbackHandler);
	}

	private void updateWidgets() {
		this.exitButton.setBounds(50, 200, 200, 50);
	}

	public override void render() {
		this.updateWidgets;
		this.renderer.drawTexture(this.screenRegion, "mainmenu_bg");
		this.exitButton.render();
	}

	public void mainMenuCallbackHandler(string message) {

	}
	
	public override void handleEvent(SDL_Event event) {
	}
}
