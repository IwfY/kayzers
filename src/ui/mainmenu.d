module ui.mainmenu;

import client;
import renderer;
import renderhelper;
import ui.button;
import ui.inputbox;
import ui.label;
import ui.labelbutton;
import ui.widget;

import derelict.sdl2.sdl;

class MainMenu : Renderer {
	private Client client;
	private Label head;
	private LabelButton exitButton;
	private LabelButton newGameButton;
	private LabelButton settingsButton;
	private Widget[] allWidgets;
	private Widget mouseOverWidget;	// reference to widget under mouse

	public this(Client client, RenderHelper renderer) {
		super(renderer);
		this.client = client;
		this.mouseOverWidget = null;

		this.initWidgets();
	}

	private void initWidgets() {
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
							  "mainMenuHead",
							  new SDL_Color(162, 59, 0));
		this.allWidgets ~= this.head;
	}

	private void updateWidgets() {
		this.newGameButton.setXY(0, 200);
		this.newGameButton.centerHorizontally();
		this.settingsButton.setXY(0, 400);
		this.settingsButton.centerHorizontally();
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
		if (message == "exit") {
			this.client.stop();
		} else if (message == "newGame") {
			this.client.startGame("Endless Game");
			this.renderer.setState(RendererState.MAP);
		} else if (message == "settings") {
			this.renderer.setState(RendererState.INPUT_POPUP);
		}
	}

	public override void handleEvent(SDL_Event event) {
		// left mouse down
		if (event.type == SDL_MOUSEBUTTONDOWN &&
				event.button.button == SDL_BUTTON_LEFT) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			foreach (Widget widget; this.allWidgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widget.click();
				}
			}
		}
		// mouse motion --> hover effects
		else if (event.type == SDL_MOUSEMOTION) {
			SDL_Point *mousePosition =
					new SDL_Point(event.button.x, event.button.y);
			bool widgetMouseOver = false; // is there a widget under the mouse?
			foreach (Widget widget; this.allWidgets) {
				if (widget.isPointInBounds(mousePosition)) {
					widgetMouseOver = true;
					if (this.mouseOverWidget is null) {
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					} else if (this.mouseOverWidget != widget) {
						this.mouseOverWidget.mouseLeave();
						this.mouseOverWidget = widget;
						this.mouseOverWidget.mouseEnter();
						break;
					}
				}
			}
			// no widget under mouse but there was one before
			if (!widgetMouseOver && this.mouseOverWidget !is null) {
				this.mouseOverWidget.mouseLeave();
				this.mouseOverWidget = null;
			}
		}
	}
}
