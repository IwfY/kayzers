module ui.mainmenu;

import client;
import ui.button;
import ui.label;
import ui.labelbutton;
import ui.renderhelper;
import ui.renderstate;
import ui.widget;
import ui.widgetrenderer;

import derelict.sdl2.sdl;

class MainMenu : WidgetRenderer {
	private Label head;
	private LabelButton exitButton;
	private LabelButton newGameButton;
	private LabelButton settingsButton;
	private RenderState renderState;

	public this(Client client, RenderHelper renderer, RenderState renderState) {
		super(client, renderer, "mainmenu_bg");
		this.renderState = renderState;
	}

	protected override void initWidgets() {
		this.newGameButton =
				new LabelButton(this.renderer,
								"newGame",
								"mainmenu_button",
								"mainmenu_button_hover",
								new SDL_Rect(0, 0, 200, 50),
								&this.mainMenuCallbackHandler,
								"New Game",
								"std");
		this.allWidgets ~= this.newGameButton;
		this.settingsButton =
				new LabelButton(this.renderer,
								"settings",
								"mainmenu_button",
								"mainmenu_button_hover",
								new SDL_Rect(0, 0, 200, 50),
								&this.mainMenuCallbackHandler,
								"DEBUG",
								"std");
		this.allWidgets ~= this.settingsButton;
		this.exitButton =
				new LabelButton(this.renderer,
								"exit",
								"mainmenu_button",
								"mainmenu_button_hover",
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
							  "menuHead",
							  new SDL_Color(162, 59, 0));
		this.allWidgets ~= this.head;
	}

	protected override void updateWidgets() {
		this.newGameButton.setXY(0, 200);
		this.newGameButton.centerHorizontally();
		this.settingsButton.setXY(0, 400);
		this.settingsButton.centerHorizontally();
		this.exitButton.setXY(0, 500);
		this.exitButton.centerHorizontally();
		this.head.setXY(0, 10);
		this.head.centerHorizontally();
	}

	public void mainMenuCallbackHandler(string message) {
		if (message == "exit") {
			this.client.stop();
		} else if (message == "newGame") {
			this.renderState.setState(Modus.SCENARIO_LIST);
		} else if (message == "settings") {
			//this.renderer.setState(RendererState.INPUT_POPUP);
		}
	}
}
