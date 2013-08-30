module world.structureprototype;

import script.script;
import script.scriptcontext;

class StructurePrototype {
	private string name;
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

	public this() {

	}

	public this(string[string] data) {
		this.name = data["name"];
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

	public const(string) getName() const {
		return this.name;
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
