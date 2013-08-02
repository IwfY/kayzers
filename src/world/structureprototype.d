module world.structureprototype;

class StructurePrototype {
	private string name;
	private string tileImage;
	private string tileImageName;
	private string iconImage;
	private string iconImageName;
	private string produceScript;
	private string consumeScript;
	private string constructableScript;
	private string progressScript;
	
	public this() {
		
	}
	
	public this(string[string] data) {
		this.name = data["name"];
		this.tileImage = data["tileImage"];
		this.tileImageName = data["tileImageName"];
		this.iconImage = data["iconImage"];
		this.iconImageName = data["iconImageName"];
		this.produceScript = data["produceScript"];
		this.consumeScript = data["consumeScript"];
		this.constructableScript = data["constructableScript"];
		this.progressScript = data["progressScript"];	
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
	
	public const(string) getProduceScript() const {
		return this.produceScript;
	}
	
	public const(string) getConsumeScript() const {
		return this.consumeScript;
	}
	
	public const(string) getConstructableScript() const {
		return this.constructableScript;
	}
	
	public const(string) getProgressScript() const {
		return this.progressScript;
	}
	
	public const(string) getTileImageName() const {
		return this.tileImageName;
	}
	public const(string) getIconImageName() const {
		return this.iconImageName;
	}
}
