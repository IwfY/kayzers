srcFiles = Split("""
    src/main.d
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

dPath = ['/usr/include/d']


# build environment

env = Environment()
env.Append(DPATH   = dPath)
env.Append(DFLAGS   = ['-debug'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kaizers', source = srcFiles)

Default(default)
