// compile:
// dmd -I. -I/usr/include/d -c -ofout.o opengl_shader_triangle.d
// gcc -o out out.o -L/usr/lib/dmd -ldl -lDerelictGL3 -lDerelictSDL2 -lDerelictUtil -lphobos2 -lpthread -lm


import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import std.conv;
import std.stdio;
import std.string;

// globals
GLuint vertexShaderId;
GLuint fragmentShaderId;
GLuint programId;
GLuint vaoId;
GLuint vboId;
GLuint colorBufferId;

//#########################################################################
// Shader Program
//#########################################################################
const(string) vertexShaderString = "
#version 120

attribute vec4 in_color;
varying vec4 ex_color;

void main(void) {
    gl_Position = gl_Vertex;
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
	uint verticesCount = 3;

	// vertices
	GLfloat[] vertexData;
	vertexData = [
		-0.8, -0.8, 0.0, 1.0,
		0.8, -0.8, 0.0, 1.0,
		0.0,  0.8, 0.0, 1.0
	];

	// colors
	GLfloat[] colorData;
	colorData = [
		1.0, 0.0, 0.0, 1.0,		// red
		0.0, 1.0, 0.0, 1.0,     // green
		0.0, 0.0, 1.0, 1.0      // blue
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

void main() {
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

	glClearColor (0.0, 0.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glDrawArrays(GL_TRIANGLES, 0, 3);
	SDL_GL_SwapWindow(mainwindow);

	SDL_Delay(5000);

	destroyVAO();
	destroyShaderProgram();

	// clean up
	SDL_GL_DeleteContext(maincontext);
	SDL_DestroyWindow(mainwindow);
	SDL_Quit();

	DerelictGL3.unload();
	DerelictSDL2.unload();
}
