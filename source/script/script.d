module script.script;

import script.expressions;
import script.scriptcontext;
import script.token;

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.uni;

/**
 * class to manage a the script's code and data
 **/
class Script {
	private Expression[] expressions;
	private Identifier[string] identifiers;
	private ScriptContext context;

	public this(string scriptString) {
		this.parseScript(scriptString);
	}


	private void parseScript(string scriptString) {
		if (scriptString.length == 0) {
			return;
		}

		dchar[] copy = to!(dchar[])(scriptString);
		// remove white spaces
		string stripped = text(array(copy.filter!(x => !x.isWhite)));
		string[] splitted = stripped.split(";");

		foreach (string line; splitted) {
			this.expressions ~= this.parseString(line);
		}
	}


	public Expression parseString(string text) {
		Regex!(char) ifExpression = regex(`^if\((.*?)\)(.+?)$`, "g");
		Regex!(char) assignExpression = regex("^(.*?[^=])=([^=].*?)$", "g");
		Regex!(char) numberExpression = regex(`^(\-?\d+?(\.\d+?)?)$`, "g");
		Regex!(char) binaryExpression =
			regex(`^(.+?)([\+|\-|\*|/|<|>]|==)(.+?)$`, "g");
		Regex!(char) consumeExpression =
			regex(`^consume\(res\.(\w*?),(.+?)\)$`, "g");
		Regex!(char) produceExpression =
			regex(`^produce\(res\.(\w*?),(.+?)\)$`, "g");
		Regex!(char) minExpression =
			regex(`^min\((.*?),(.*?)\)$`, "g");
		Regex!(char) maxExpression =
			regex(`^max\((.*?),(.*?)\)$`, "g");

		// if expression
		auto m = match(text, ifExpression);
		if (m) {
			Expression tmp = new IfExpression(
					this,
					this.parseString(m.captures[1]),
					this.parseString(m.captures[2]));
			return tmp;
		}

		// min and max expression
		m = match(text, minExpression);
		if (m) {
			Expression tmp = new MinExpression(
				this,
				this.parseString(m.captures[1]),
				this.parseString(m.captures[2]));
			return tmp;
		}

		m = match(text, maxExpression);
		if (m) {
			Expression tmp = new MaxExpression(
				this,
				this.parseString(m.captures[1]),
				this.parseString(m.captures[2]));
			return tmp;
		}

		// consume statement
		m = match(text, consumeExpression);
		if (m) {
			debug(script) {
				writefln("Script::parseString new consumeExpression %s, %s",
						 m.captures[1], m.captures[2]);
			}
			Expression tmp = new ConsumeExpression(
					this, m.captures[1],
					this.parseString(m.captures[2]));
			return tmp;
		}

		// produce statement
		m = match(text, produceExpression);
		if (m) {
			debug(script) {
				writefln("Script::parseString new produceExpression %s, %s",
						 m.captures[1], m.captures[2]);
			}
			Expression tmp = new ProduceExpression(
					this, m.captures[1],
					this.parseString(m.captures[2]));
			return tmp;
		}

		// assign statement
		m = match(text, assignExpression);
		if (m) {
			Expression tmp = new AssignExpression(
					this,
					this.getIdentifier(m.captures[1]),
					this.parseString(m.captures[2]));
			return tmp;
		}

		// binary statement
		m = match(text, binaryExpression);
		if (m) {
			Expression tmp = new BinaryExpression(
					this,
					this.parseString(m.captures[1]),
					this.parseString(m.captures[3]),
					this.parseToken(m.captures[2]));
			return tmp;
		}

		// number statement
		m = match(text, numberExpression);
		if (m) {
			Expression tmp = new Number(
					this, m.captures[1]);
			return tmp;
		}

		return this.getIdentifier(text);
	}


	public Identifier parseIdentifier(string text) {
		Regex!(char) identifierExpression = regex(`^([\w]*?)$`, "g");
		Regex!(char) resIdentifierExpression = regex(`^(res\.[\w]*?)$`, "g");
		Regex!(char) globIdentifierExpression = regex(`^(glob\.[\w]*?)$`, "g");

		// resource identifier
		auto m = match(text, resIdentifierExpression);
		if (m) {
			Identifier tmp = new ResourceIdentifier(
					this, m.captures[1]);
			return tmp;
		}

		// nation global resource identifier
		m = match(text, globIdentifierExpression);
		if (m) {
			Identifier tmp = new GlobalResourceIdentifier(
					this, m.captures[1]);
			return tmp;
		}

		// identifier
		m = match(text, identifierExpression);
		if (m) {
			Identifier tmp = new Identifier(
					this, m.captures[1]);
			return tmp;
		}
		return null;
	}



	public Token parseToken(string text) {
		writefln("Scrip::parseToken text %s", text);
		if (text[0] == '+') {
			return new AddToken();
		}

		if (text[0] == '-') {
			return new SubToken();
		}

		if (text[0] == '*') {
			return new MulToken();
		}

		if (text[0] == '/') {
			return new DivToken();
		}

		if (text[0] == '<') {
			return new LTToken();
		}

		if (text[0] == '>') {
			return new GTToken();
		}

		if (text[0] == '=' && text[1] == '=') {
			return new EqualToken();
		}

		return null;
	}


	/**
	 * get the identifier - create one if it doesn't exists yet
	 **/
	public Identifier getIdentifier(string name) {
		Identifier tmp = this.identifiers.get(name, null);
		if (tmp is null) {
			tmp = this.parseIdentifier(name);
			if (tmp !is null) {
				this.identifiers[name] = tmp;
			}
		}
		return tmp;
	}

	public ScriptContext getContext() {
		return this.context;
	}

	public void execute(ScriptContext context) {
		this.context = context;

		// empty identifiers array
		this.identifiers = null;

		foreach (Expression expression; this.expressions) {
			expression.execute();
		}
		this.context = null;
	}
}
