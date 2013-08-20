module script.script;

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
import std.uni;

interface ScriptContext {};

/**
 * token
 **/
class Token {
	public abstract double execute(Expression e1, Expression e2);
};

class AddToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() + e2.execute();
	}
}

class SubToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() - e2.execute();
	}
}

class MulToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() * e2.execute();
	}
}

class DivToken : Token {
	public override double execute(Expression e1, Expression e2) {
		return e1.execute() / e2.execute();
	}
}

/**
 * expressions
 **/
 
class Expression {
	private Script script;
	
	public this(Script script) {
		this.script = script;
	}
	
	public abstract double execute();
}


class Identifier : Expression {
	private string name;
	private double value;
	
	public this(Script script, string name) {
		super(script);
		this.name = name;
	}
	
	public void assign(double value) {
		this.value = value;
	}
	
	public double getValue() {
		return this.value;
	}
	
	public override double execute() {
		return this.getValue();
	}
}


class ResourceIdentifier : Identifier {
	private string resourceName;

	public this(Script script, string name) {
		super(script, name);
	}

	public override void assign(double value) {
		assert(false, "ResourceIdentifier::assign todo");
	}
	
	public override double getValue() {
		assert(false, "ResourceIdentifier::assign todo");
		return 0.0;
	}
}


class Number : Expression {
	private double value;
	
	public this(Script script, string text) {
		super(script);
		this.value = to!(double)(text);
	}
	
	public override double execute() {
		return this.value;
	}
}


/**
 * expression of the form
 * 		Identifier Token Number
 **/
class BinaryExpression : Expression {
	private Expression e1;
	private Expression e2;
	private Token token;
	
	public this(Script script, Expression e1, Expression e2, Token token) {
		super(script);
		this.e1 = e1;
		this.e2 = e2;
		this.token = token;
		
	}
	
	public override double execute() {
		return this.token.execute(e1, e2);
	}
}

/**
 * expression of the form:
 * 		Identifier = Expression
 **/
class AssignExpression : Expression {
	private Identifier identifier;
	private Expression expression;
	
	public this(Script script, Identifier identifier, Expression expression) {
		super(script);
		this.identifier = identifier;
		this.expression = expression;
	}
	
	public override double execute() {
		this.identifier.assign(this.expression.execute());
		return 0.0;
	}
}


/**
 * class to manage a the script's code and data
 **/
class Script {
	private Expression[] expressions;
	private Identifier[string] identifiers;
	private ScriptContext context;

	public this(ScriptContext context, string scriptString) {
		this.context = context;
		this.parseScript(scriptString);
	}
	
	private void parseScript(string scriptString) {
		dchar[] copy = to!(dchar[])(scriptString);
		// remove white spaces
		string stripped = text(array(copy.filter!(x => !x.isWhite)));
		string[] splitted = stripped.split(";");
		
		foreach (string line; splitted) {
			this.expressions ~= this.parseString(line);
		}
	}
	
	public Expression parseString(string text) {
		auto assignExpression = regex("^(.*?)=(.*?)$", "g");
		auto numberExpression = regex(`^(\d+?\.?\d+?)$`, "g");
		auto binaryExpression = regex(`^(.*?)([\+|-|\*|/])(.*?)$`, "g");

		// assign statement
		auto m = match(text, assignExpression);
		if (m) {
			Expression tmp = new AssignExpression(
					this,
					this.parseIdentifier(m.captures[1]),
					this.parseString(m.captures[2]));
			return tmp;
		}

		// add statement
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

		return this.parseIdentifier(text);
	}


	public Identifier parseIdentifier(string text) {
		auto identifierExpression = regex(`^([\w]*?)$`, "g");
		auto resIdentifierExpression = regex(`^(res\.[\w]*?)$`, "g");
		auto strIdentifierExpression = regex(`^(str\.[\w]*?)$`, "g");

		// resource identifier
		auto m = match(text, resIdentifierExpression);
		if (m) {
			Identifier tmp = new ResourceIdentifier(
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

		return null;
	}


	public Identifier getIdentifier(string name) {
		assert(false, "Script::getIdentifier todo");
		return null;
	}
	
	public ScriptContext getContext() {
		return this.context;
	}
	
	public void execute() {
		//TODO empty identifiers array
		foreach (Expression expression; this.expressions) {
			expression.execute();
		}
	}
}
