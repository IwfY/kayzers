module ui.scenariolistrenderer;

import client;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.renderhelper;
import ui.renderstate;
import ui.widgets.widget;
import ui.widgetrenderer;
import world.scenario;

import derelict.sdl2.sdl;

import std.string;

class ScenarioListRenderer : WidgetRenderer {
	private RenderState renderState;

	private Label head;
	private Label head2;
	private LabelButton backButton;
	private Widget[] scenarioButtons;


	public this(Client client, RenderHelper renderer, RenderState renderState) {
		super(client, renderer, "mainmenu_bg");
		this.renderState = renderState;
	}


	protected override void initWidgets() {
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


	protected override void updateWidgets() {
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
}
