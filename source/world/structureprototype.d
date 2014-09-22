module world.structureprototype;

import script.script;
import script.scriptcontext;

class StructurePrototype {
	private static int lastId = 0;
	private int id;
	private string name;
	private string popupText;
	private string tileImage;
	private string tileImageName;
	private string iconImage;
	private string iconImageName;
	private bool nameable;

	private string constructableScriptString;
	private string progressScriptString;

	private Script initScript;
	private Script produceScript;
	private Script consumeScript;

	public this(string[string] data) {
		StructurePrototype.lastId++;
		this(StructurePrototype.lastId, data);
	}

	public this(int id, string[string] data) {
		this.id = id;
		if (id > StructurePrototype.lastId) {
			StructurePrototype.lastId = id;
		}
		this.name = data["name"];
		this.popupText = data["popupText"];
		this.tileImage = data["tileImage"];
		this.tileImageName = data["tileImageName"];
		this.iconImage = data["iconImage"];
		this.iconImageName = data["iconImageName"];
		this.constructableScriptString = data["constructableScript"];
		this.progressScriptString = data["progressScript"];
		this.nameable = false;

		this.initScript = new Script(data["initScript"]);
		this.produceScript = new Script(data["produceScript"]);
		this.consumeScript = new Script(data["consumeScript"]);
	}

	public const(int) getId() const {
		return this.id;
	}

	public const(string) getName() const {
		return this.name;
	}

	public const(string) getPopupText() const {
		return this.popupText;
	}

	public const(string) getTileImage() const {
		return this.tileImage;
	}

	public const(string) getIconImage() const {
		return this.iconImage;
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

	public void runInitScript(ScriptContext context) {
		this.initScript.execute(context);
	}

	public void runProduceScript(ScriptContext context) {
		this.produceScript.execute(context);
	}

	public void runConsumeScript(ScriptContext context) {
		this.consumeScript.execute(context);
	}
}
