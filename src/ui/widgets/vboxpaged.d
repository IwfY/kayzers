module ui.widgets.vboxpaged;

import constants;
import utils;
import ui.renderhelper;
import ui.widgets.hbox;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.labelbutton;
import ui.widgets.vbox;
import ui.widgets.widget;

import derelict.sdl2.sdl;

import std.algorithm;

/**
 * widget container that arranges its children vertically
 * offers navigatable pages when too many elements are added
 **/
class VBoxPaged : Widget {
	private int margin;	// vertical gap between child widgets
	protected IWidget[] vboxChildren; // widgets that are to be added to vboxes
	protected VBox[] vboxes;
	private uint activeVBox;
	private Label pageNumberLabel;
	private HBox navigation;
	protected bool dirty;

	public this(RenderHelper renderer,
	            const(SDL_Rect *)bounds = new SDL_Rect()) {
		super(renderer, bounds);

		this.margin = 5;
		this.dirty = true;

		this.initChildren();
	}

	private void initChildren() {
		VBox vbox = new VBox(this.renderer);
		this.vboxes ~= vbox;
		this.activeVBox = 0;

		this.navigation = new HBox(this.renderer);

		LabelButton leftButton = new LabelButton(
			this.renderer, "-", NULL_TEXTURE, NULL_TEXTURE,
			new SDL_Rect(0, 0, 30, 30),
			&(this.callback),
			"<");
		this.navigation.addChild(leftButton);

		this.pageNumberLabel = new Label(this.renderer, "");
		this.navigation.addChild(this.pageNumberLabel);

		LabelButton rightButton = new LabelButton(
			this.renderer, "+", NULL_TEXTURE, NULL_TEXTURE,
			new SDL_Rect(0, 0, 30, 30),
			&(this.callback),
			">");
		this.navigation.addChild(rightButton);

	}

	private void callback(string message) {
		//TODO
	}

	public const(int) getMargin() const {
		return this.margin;
	}
	public void setMargin(int margin) {
		this.margin = margin;
		this.updateChildren();
	}

	public void addChild(IWidget child) {
		this.vboxChildren ~= child;
		this.dirty = true;
	}

	public override void setXY(int x, int y) {
		super.setXY(x, y);
		this.dirty = true;
	}

	public override void setBounds(int x, int y, int w, int h) {
		super.setBounds(x, y, w, h);
		this.dirty = true;
	}

	public override void setHidden(const(bool) hidden) {
		super.setHidden(hidden);
	}

	protected void updateChildren() {
		// calculate space for vboxes
		int vboxHeight = this.h() - this.navigation.h() - this.margin;

		// fill vboxes
		//TODO

		// place vboxes
		foreach(VBox vbox; this.vboxes) {
			vbox.setXY(this.x(), this.y());
		}
		// place navigation
		this.navigation.setXY(this.x(), this.y() + vboxHeight + this.margin);
		this.navigation.centerHorizontally(this.x(), this.w());
	}

	protected override void draw() {
		if (this.dirty) {
			this.updateChildren();
			this.dirty = false;
		}

		this.vboxes[this.activeVBox].render();
		this.navigation.render();

	}

	public override void handleEvent(SDL_Event event) {
		this.vboxes[this.activeVBox].handleEvent(event);
		this.navigation.handleEvent(event);
	}
}
