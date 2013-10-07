// compile:
// dmd -I. -I/usr/include/d -c -ofout.o opengl_test.d
// gcc -o out out.o -L/usr/lib/dmd -ldl -lDerelictGL3 -lDerelictSDL2 -lDerelictUtil -lphobos2 -lpthread -lm


import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import std.conv;
import std.math;
import std.stdio;
import std.string;

class Mat4x4 {
	public GLfloat[16] data;

	public this() {
		this.data = [
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0
		];
	}

	public this(GLfloat[16] data) {
		this.data = data.dup;
	}

	public const(GLfloat) get(int i, int j) const {
		return this.data[j * 4 + i];
	}

	public void set(int i, int j, GLfloat value) {
		this.data[j * 4 + i] = value;
	}

	public void print() {
		writefln("%0.2f %0.2f %0.2f %0.2f",
				 this.data[0], this.data[1], this.data[2], this.data[3]);
		writefln("%0.2f %0.2f %0.2f %0.2f",
				 this.data[4], this.data[5], this.data[6], this.data[7]);
		writefln("%0.2f %0.2f %0.2f %0.2f",
				 this.data[8], this.data[9], this.data[10], this.data[11]);
		writefln("%0.2f %0.2f %0.2f %0.2f",
				 this.data[12], this.data[13], this.data[14], this.data[15]);
	}
}

// globals
GLuint vertexShaderId;
GLuint fragmentShaderId;
GLuint programId;
GLuint vaoId;
GLuint vboId;
GLuint colorBufferId;
Mat4x4 viewMatrix;
Mat4x4 viewMatrix2;
uint verticesCount = 8;

//#########################################################################
// Shader Program
//#########################################################################
const(string) vertexShaderString = "
#version 120

attribute vec4 in_color;
varying vec4 ex_color;
uniform mat4 view_matrix;

void main(void) {
    gl_Position = view_matrix * gl_Vertex;
    ex_color = in_color;
}
";

const(string) fragmentShaderString = "
#version 120

varying vec4 ex_color;

void main() {
    gl_FragColor = ex_color;
}
";

void createShaderProgram() {
	// vertex shader
	//*********************************************************************
	const(char*) vertexShaderChars = toStringz(vertexShaderString);

	vertexShaderId = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertexShaderId,
				   1,
				   &vertexShaderChars,
				   null);
	glCompileShader(vertexShaderId);

	// get shader log info
	GLint infoLogLength;
	glGetShaderiv(vertexShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
    GLchar[] strInfoLog = new GLchar[infoLogLength + 1];
    glGetShaderInfoLog(vertexShaderId,
					   infoLogLength,
					   null,
					   strInfoLog.ptr);
	writefln("Vertex Shader Info: \n%s",
			 to!string(strInfoLog));

	// fragment shader
	//*********************************************************************
	const(char*) fragmentShaderChars = toStringz(fragmentShaderString);

	fragmentShaderId = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragmentShaderId,
				   1,
				   &fragmentShaderChars,
				   null);
	glCompileShader(fragmentShaderId);

	// get shader log info
	glGetShaderiv(fragmentShaderId, GL_INFO_LOG_LENGTH, &infoLogLength);
	strInfoLog = new GLchar[infoLogLength + 1];
	glGetShaderInfoLog(fragmentShaderId,
					   infoLogLength,
					   null,
					   strInfoLog.ptr);
	writefln("Fragment Shader Info: \n%s",
			 to!string(strInfoLog));

	// create program
	//*********************************************************************
	programId = glCreateProgram();
	glAttachShader(programId, vertexShaderId);
	glAttachShader(programId, fragmentShaderId);
	glLinkProgram(programId);

	// get program log info
	glGetProgramiv(programId, GL_INFO_LOG_LENGTH, &infoLogLength);
	strInfoLog = new GLchar[infoLogLength + 1];
	glGetProgramInfoLog(programId,
					    infoLogLength,
					    null,
					    strInfoLog.ptr);
	writefln("Program Info: \n%s",
			 to!string(strInfoLog));

	glUseProgram(programId);
}


void destroyShaderProgram() {
	glUseProgram(0);

	glDetachShader(programId, vertexShaderId);
    glDetachShader(programId, fragmentShaderId);

    glDeleteShader(fragmentShaderId);
    glDeleteShader(vertexShaderId);

    glDeleteProgram(programId);
}


//#########################################################################
// Vertex Buffer Arrays
//#########################################################################
void createVAO() {
	// define data
	verticesCount = 6;

	// vertices
	GLfloat[] vertexData;
	vertexData = [
		0.1, 0, 0.1, 1.0,
		0.2, 0, 0.2, 1.0,
		0.2, 0, 0.1, 1.0,

		0.1, 0, 0.1, 1.0,
		0.1, 0, 0.2, 1.0,
		0.2, 0, 0.2, 1.0
	];

	// colors
	GLfloat[] colorData;
	colorData = [
		1.0, 0.0, 0.0, 1.0,		// red
		0.0, 1.0, 0.0, 1.0,     // green
		0.0, 0.0, 1.0, 1.0,     // blue

		1.0, 0.0, 0.0, 1.0,		// red
		0.0, 0.0, 1.0, 1.0,     // green
		0.0, 1.0, 0.0, 1.0
	];

	// bind vertex data
	// create vertex array object
	glGenBuffers(1, &vaoId);
	glBindBuffer(GL_ARRAY_BUFFER, vaoId);

	glBufferData(
		GL_ARRAY_BUFFER,
		GLfloat.sizeof * verticesCount * 4,
		vertexData.ptr,
		GL_STATIC_DRAW);
	glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, null);
	glEnableVertexAttribArray(0);


	// bind color data
	GLint colorAttributeLocation =
		glGetAttribLocation(programId, toStringz("in_color"));
	glGenBuffers(1, &colorBufferId);
	glBindBuffer(GL_ARRAY_BUFFER, colorBufferId);

	glBufferData(
		GL_ARRAY_BUFFER,
		GLfloat.sizeof * verticesCount * 4,
		colorData.ptr,
		GL_STATIC_DRAW);
	glVertexAttribPointer(
		colorAttributeLocation,
		4, GL_FLOAT, GL_FALSE, 0, null);
	glEnableVertexAttribArray(colorAttributeLocation);
}

void destroyVAO() {
	GLint colorAttributeLocation =
		glGetAttribLocation(programId, toStringz("in_color"));
	glDisableVertexAttribArray(colorAttributeLocation);
	glDisableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glDeleteBuffers(1, &colorBufferId);
	glDeleteBuffers(1, &vboId);

	glBindVertexArray(0);
	glDeleteVertexArrays(1, &vaoId);
}


void resize(uint width, uint height) {
	glViewport(0, 0, width, height);
}

/**
 * transpose a 4x4 matrix
 **/
void getTransposedMatrix(const(Mat4x4) matrix, Mat4x4 transposedMatrix) {
	for (int i = 0; i < 16; ++i) {
		transposedMatrix.data[i] = matrix.data[(i * 4) % 16 + i / 4];
	}
}


void multiplyMatrices(const(Mat4x4) m1, const(Mat4x4) m2,
						Mat4x4 o) {
	for (int i = 0; i < 4; ++i) {
		for(int j = 0; j < 4; ++j) {
			o.set(i, j, 0);
			for(int k = 0; k < 4; ++k) {
				o.set(i, j, o.get(i, j) + m1.get(i, k) * m2.get(k, j));
			}
		}
	}
}


void getRotationXMatrix(double rotX, Mat4x4 rotationMatrix) {
	GLfloat[16] rotMatrixData = [
		1, 0, 0, 0,
		0, cos(rotX), -sin(rotX), 0,
		0, sin(rotX), cos(rotX), 0,
		0, 0, 0, 1
	];

	rotationMatrix.data = rotMatrixData.dup;
}

void getRotationZMatrix(double rotZ, Mat4x4 rotationMatrix) {
	GLfloat[16] rotMatrixData = [
		cos(rotZ), -sin(rotZ), 0, 0,
		sin(rotZ), cos(rotZ), 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	];

	rotationMatrix.data = rotMatrixData.dup;
}


void getRotationYMatrix(double rotY, Mat4x4 rotationMatrix) {
	GLfloat[16] rotMatrixData = [
		cos(rotY), 0, sin(rotY), 0,
		0, 1, 0, 0,
		-sin(rotY), 0, cos(rotY), 0,
		0, 0, 0, 1
	];

	rotationMatrix.data = rotMatrixData.dup;
}

void main() {
	GLfloat[16] viewMatrixData = [
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	];
	viewMatrix = new Mat4x4(viewMatrixData);

	DerelictSDL2.load();
	DerelictGL3.load();		// load OpenGL 1.1 functions

	SDL_Window *mainwindow;
	SDL_GLContext maincontext;

	// set up
	SDL_Init(SDL_INIT_VIDEO);

	mainwindow = SDL_CreateWindow("ogl_test",
								  SDL_WINDOWPOS_CENTERED,
								  SDL_WINDOWPOS_CENTERED,
								  512, 512,
								  SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);

	maincontext = SDL_GL_CreateContext(mainwindow);

	// load OpenGL functions for highest supported version
	DerelictGL3.reload();

	// print context information
	int glMajor, glMinor;
	glGetIntegerv(GL_MAJOR_VERSION, &glMajor);
	glGetIntegerv(GL_MINOR_VERSION, &glMinor);
	writefln("GL_VERSION: %d.%d", glMajor, glMinor);
	writefln("GL_VERSION: %s", to!string(glGetString(GL_VERSION)));
	writefln("GL_SHADING_LANGUAGE_VERSION: %s",
			 to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));

	createShaderProgram();
	createVAO();

	resize(512, 512);

	// draw
	glClearColor (0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// shader uniforms - view matrix
	GLint viewMatrixUniformLocation =
		glGetUniformLocation(programId,
							 toStringz("view_matrix"));

	Mat4x4 rotXMatrix = new Mat4x4();
	Mat4x4 rotYMatrix = new Mat4x4();
	Mat4x4 rotMatrix = new Mat4x4();
	getRotationXMatrix(PI * 30/180, rotXMatrix);
	getRotationYMatrix(PI * 45/180, rotYMatrix);
	multiplyMatrices(rotYMatrix, rotXMatrix, rotMatrix);
	rotMatrix.print();
	Mat4x4 transposedViewMatrix = new Mat4x4();

	// transpose matrix as opengl expects a column first format
	getTransposedMatrix(viewMatrix, transposedViewMatrix);
	glUniformMatrix4fv(viewMatrixUniformLocation,
                       1, GL_FALSE, transposedViewMatrix.data.ptr);

	glDrawArrays(GL_TRIANGLES, 0, verticesCount);
	SDL_GL_SwapWindow(mainwindow);

	SDL_Delay(1500);
	//glClearColor (0.0, 0.0, 0.0, 1.0);
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	getTransposedMatrix(rotMatrix, transposedViewMatrix);
	glUniformMatrix4fv(viewMatrixUniformLocation,
                       1, GL_FALSE, transposedViewMatrix.data.ptr);

	glDrawArrays(GL_TRIANGLES, 0, verticesCount);
	SDL_GL_SwapWindow(mainwindow);

	SDL_Delay(10000);

	destroyVAO();
	destroyShaderProgram();

	// clean up
	SDL_GL_DeleteContext(maincontext);
	SDL_DestroyWindow(mainwindow);
	SDL_Quit();

	DerelictGL3.unload();
	DerelictSDL2.unload();
}
