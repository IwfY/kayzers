module world.structureprototype;

class StructurePrototype {
	private string name;
	private string tileImage;
	private string tileImageName;
	private string iconImage;
	private string iconImageName;
	private bool nameable;

	private string initScriptString;
	private string produceScriptString;
	private string consumeScriptString;
	private string constructableScriptString;
	private string progressScriptString;

	public this() {

	}

	public this(string[string] data) {
		this.name = data["name"];
		this.tileImage = data["tileImage"];
		this.tileImageName = data["tileImageName"];
		this.iconImage = data["iconImage"];
		this.iconImageName = data["iconImageName"];
		this.initScriptString = data["initScript"];
		this.produceScriptString = data["produceScript"];
		this.consumeScriptString = data["consumeScript"];
		this.constructableScriptString = data["constructableScript"];
		this.progressScriptString = data["progressScript"];
		this.nameable = false;
	}

	public const(string) getName() const {
		return this.name;
	}

	public const(string) getTileImage() const {
		return this.tileImage;
	}

	public const(string) getIconImage() const {
		return this.iconImage;
	}

	public const(string) getInitScriptString() const {
		return this.initScriptString;
	}

	public const(string) getProduceScriptString() const {
		return this.produceScriptString;
	}

	public const(string) getConsumeScriptString() const {
		return this.consumeScriptString;
	}

	public const(string) getConstructableScriptString() const {
		return this.constructableScriptString;
	}

	public const(string) getProgressScriptString() const {
		return this.progressScriptString;
	}

	public const(string) getTileImageName() const {
		return this.tileImageName;
	}
	public const(string) getIconImageName() const {
		return this.iconImageName;
	}

	public const(bool) isNameable() const {
		return this.nameable;
	}
	public void setNameable(bool nameable) {
		this.nameable = nameable;
	}
}
