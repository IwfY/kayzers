module ui.scenariolistrenderer;

import client;
import ui.label;
import ui.labelbutton;
import ui.renderer;
import ui.renderhelper;
import ui.renderstate;
import ui.widget;
import world.scenario;

import derelict.sdl2.sdl;

import std.string;

class ScenarioListRenderer : Renderer {
	private RenderState renderState;

	private Label head;
	private Label head2;
	private LabelButton backButton;
	private Widget[] allWidgets;
	private Widget[] scenarioButtons;
	private Widget mouseOverWidget;	// reference to widget under mouse

	public this(Client client, RenderHelper renderer, RenderState renderState) {
		super(client, renderer);
		this.mouseOverWidget = null;
		this.renderState = renderState;

		this.initWidgets();
	}

	public void initWidgets() {
		this.head = new Label(this.renderer,
							  "head",
							  "null",
							  new SDL_Rect(0, 0, 0, 0),
							  "Kayzers",
							  "menuHead",
							  new SDL_Color(162, 59, 0));
		this.allWidgets ~= this.head;

		this.head2 = new Label(this.renderer,
							  "head",
							  "null",
							  new SDL_Rect(0, 0, 0, 0),
							  "Scenarios",
							  "menuHead2");
		this.allWidgets ~= this.head2;

		this.backButton =
				new LabelButton(this.renderer,
								"",
								"mainmenu_button",
								"mainmenu_button_hover",
								new SDL_Rect(0, 0, 200, 50),
								&this.backButtonCallbackHandler,
								"Back",
								"std");
		this.allWidgets ~= this.backButton;

		// scenario buttons
		foreach (const(Scenario) scenario; this.client.getScenarios()) {
			LabelButton scenarioButton =
					new LabelButton(this.renderer,
									scenario.getName(),
									"mainmenu_button",
									"mainmenu_button_hover",
									new SDL_Rect(0, 0, 500, 60),
									&this.scenarioButtonCallbackHandler,
									format("%s\n%s",
										scenario.getName(),
										scenario.getDescription()),
									"std");
			this.allWidgets ~= scenarioButton;
			this.scenarioButtons ~= scenarioButton;
		}
	}


	public void scenarioButtonCallbackHandler(string message) {
		this.client.startGame(message);
		this.renderState.setState(Modus.IN_GAME);
	}

	public void backButtonCallbackHandler(string message) {
		this.renderState.setState(Modus.MAIN_MENU);
	}

	private void updateWidgets() {
		this.head.setXY(0, 10);
		this.head.centerHorizontally();
		this.head2.setXY(0, 110);
		this.head2.centerHorizontally();
		this.backButton.setXY(
			this.screenRegion.x + this.screenRegion.w - 300,
			this.screenRegion.y + this.screenRegion.h - 100);

		int scenarioButtonY = 200;
		foreach (Widget widget; this.scenarioButtons) {
			widget.setXY(0, scenarioButtonY);
			widget.centerHorizontally();
			scenarioButtonY += 70;
		}
	}

	public override void render(int tick=0) {
		this.updateWidgets();
		this.renderer.drawTexture(this.screenRegion, "mainmenu_bg");
		foreach (Widget widget; this.allWidgets) {
			widget.render();
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
