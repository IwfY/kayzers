module ui.mainmenu;

import client;
import renderer;
import renderhelper;
import ui.button;
import ui.label;
import ui.labelbutton;
import ui.widget;

import derelict.sdl2.sdl;

class MainMenu : Renderer {
	private Client client;
	private Label head;
	private LabelButton exitButton;
	private LabelButton newGameButton;
	private Widget[] allWidgets;
	
	public this(Client client, RenderHelper renderer) {
		super(renderer);
		this.client = client;

		this.initWidgets();
	}

	private void initWidgets() {
		this.newGameButton = 
				new LabelButton(this.renderer,
								"newGame",
								"mainmenu_button",
								new SDL_Rect(0, 0, 200, 50),
								&this.mainMenuCallbackHandler,
								"New Game",
								"std");
		this.allWidgets ~= this.newGameButton;
		this.exitButton =
				new LabelButton(this.renderer,
								"exit",
								"mainmenu_button",
								new SDL_Rect(0, 0, 200, 50),
								&this.mainMenuCallbackHandler,
								"Exit",
								"std");
		this.allWidgets ~= this.exitButton;
		
		this.head = new Label(this.renderer,
							  "head",
							  "null",
							  new SDL_Rect(0, 0, 0, 0),
							  "Kayzers",
							  "mainMenuHead",
							  new SDL_Color(162, 59, 0));
		this.allWidgets ~= this.head;
	}

	private void updateWidgets() {
		this.newGameButton.setXY(0, 200);
		this.newGameButton.centerHorizontally();
		this.exitButton.setXY(0, 500);
		this.exitButton.centerHorizontally();
		this.head.setXY(0, 10);
		this.head.centerHorizontally();
	}

	public override void render() {
		this.updateWidgets;
		this.renderer.drawTexture(this.screenRegion, "mainmenu_bg");
		foreach (Widget widget; this.allWidgets) {
			widget.render();
		}
	}

	public void mainMenuCallbackHandler(string message) {

	}
	
	public override void handleEvent(SDL_Event event) {
	}
}
