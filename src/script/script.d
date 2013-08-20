module script.script;

import std.algorithm;
import std.array;
import std.conv;
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
	
	public this(Script script, string name) {
		super(script);
		this.name = name;
	}
	
	public void assign(double value) {
		assert(false, "Identifier::assign todo");
	}
	
	public double getValue() {
		assert(false, "Identifier::assign todo");
		return 0.0;
	}
	
	public override double execute() {
		return this.getValue();
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
		dchar[] stripped = array(copy.filter!(x => !x.isWhite));
		//dchar[] striped = remove!isWhite(copy);
	}
	
	public void parseString(string text) {
		
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
