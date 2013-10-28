module ui.renderstate;

enum Modus {
	MAIN_MENU,
	IN_GAME,
	SCENARIO_LIST
}

class RenderState {
	private Modus state;
	private Modus oldState;

	public this() {
		this.state = Modus.MAIN_MENU;
		this.oldState = Modus.MAIN_MENU;
	}

	public const(Modus) getState() const {
		return this.state;
	}

	public void setState(Modus state) {
		this.oldState = this.state;
		this.state = state;
	}

	public void restoreState() {
		this.state = this.oldState;
	}
}
