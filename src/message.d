module message;

class Message {
	public string text;

	public this(string text) {
		this.text = text;
	}
}

class ObjectMessage(T) : Message {
	public T object;

	public this(string text, T object) {
		super(text);
		this.object = object;
	}
}