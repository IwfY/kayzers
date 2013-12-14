module ui.widgets.characterinfo;

import std.string;

import client;
import constants;
import ui.renderhelper;
import ui.widgets.clickwidgetdecorator;
import ui.widgets.containerwidget;
import ui.widgets.iwidget;
import ui.widgets.label;
import ui.widgets.popupwidgetdecorator;
import ui.widgets.roundborderimage;
import world.character;
import world.dynasty;
import world.nation;

class CharacterInfo : ContainerWidget {
	private const(Client) client;
	private const(Character) character;
	private string message;
	private void delegate(string) callback;	// callback function pointer

	private IWidget name;
	private IWidget dynasty;
	private RoundBorderImage sex;

	public this(const(Client) client,
	            RenderHelper renderer,
	            const(Character) character,
	            void delegate(string) callback,
	            string message) {
		super(renderer);

		this.callback = callback;
		this.message = message;

		this.client = client;
		this.character = character;

		this.initWidgets();
	}

	private const(string) _(string text) const {
		return this.client.getI18nString(text);
	}

	private void initWidgets() {
		if (this.character !is null) {
			IWidget tmpWidget;

			// name label
			tmpWidget = new Label(
				this.renderer, this.character.getFullName());
			tmpWidget = new ClickWidgetDecorator(
				tmpWidget, this.message, this.callback);

			string popupText = format("%s: %d%s",
				_("Age"),
				this.character.getAge(this.client.getServerStub().getCurrentYear()),
			    (this.character.isDead() ? " ✝" : ""));

			this.name = new PopupWidgetDecorator(
				tmpWidget,
				this.renderer, popupText, "ui_popup_background");
			this.addChild(this.name);

			// dynasty flag
			tmpWidget = new RoundBorderImage(
				this.renderer,
				this.character.getDynasty().getFlagImageName());
			this.dynasty = new PopupWidgetDecorator(
				tmpWidget, this.renderer, this.character.getDynasty().getName(),
				"ui_popup_background");
			this.dynasty.setZIndex(2);
			this.addChild(this.dynasty);

			// sex portrait
			this.sex = new RoundBorderImage(
				this.renderer, NULL_TEXTURE);
			if (this.character.getSex() == Sex.MALE) {
				this.sex.setTextureName("portrait_male");
			} else {
				this.sex.setTextureName("portrait_female");
			}
			this.addChild(this.sex);
		} else {	// null character
			this.name = new Label(
				this.renderer, _("unknown"));
			this.addChild(this.name);

			this.dynasty = new RoundBorderImage(
				this.renderer, NULL_TEXTURE);
			this.addChild(this.dynasty);

			this.sex = new RoundBorderImage(
				this.renderer, NULL_TEXTURE);
			this.addChild(this.sex);
		}
	}

	protected override void updateChildren() {
		this.dynasty.setXY(this.x(), this.y());
		this.sex.setXY(this.x() + 40, this.y());
		this.name.setXY(this.x() + 80, this.y() + 7);

		this.bounds.w = this.name.x() - this.x() + this.name.w();
		this.bounds.h = 30;
	}

}
