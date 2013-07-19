srcFiles = Split("""
    src/main.d
    src/renderer.d
""")

dFlags = ['-L-L/usr/lib/dmd',
		  '-L-ldl',
		  '-L-lDerelictSDL2',
		  '-L-lDerelictSDL2',
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
env.Append(DFLAGS   = ['-debug'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kayzers', source = srcFiles)

Default(default)
