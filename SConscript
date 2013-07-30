srcFiles = Split("""
    src/main.d
    src/texturemanager.d
    src/game.d
    src/client.d
    src/renderer.d
    src/map.d
    src/utils.d
""")

dFlags = ['-L-L/usr/lib/dmd',
		  '-L-ldl',
		  '-L-lDerelictSDL2'
		  '-L-lDerelictUtil']

libs = ['dl',
		'DerelictSDL2',
		'DerelictUtil',
		'phobos2']

libPath = ['/usr/lib/dmd']

dPath = ['/usr/include/d',
		 'src']


# build environment

env = Environment()
env.Append(DPATH   = dPath)
env.Append(DFLAGS  = ['-debug=1'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kayzers', source = srcFiles)

Default(default)
