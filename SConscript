srcFiles = Split("""
    src/client.d
    src/fontmanager.d
    src/game.d
    src/ui/inputbox.d
    src/main.d
    src/map.d
    src/maprenderer.d
    src/observable.d
    src/observer.d
    src/player.d
    src/position.d
    src/rect.d
    src/renderer.d
    src/renderhelper.d
    src/utils.d
    src/structuremanager.d
    src/textinput.d
    src/texturemanager.d
    src/script/expressions.d
    src/script/script.d
    src/script/scriptcontext.d
    src/script/token.d
    src/ui/button.d
    src/ui/image.d
    src/ui/label.d
    src/ui/labelbutton.d
    src/ui/mainmenu.d
    src/ui/ui.d
    src/ui/widget.d
    src/world/character.d
    src/world/dynasty.d
    src/world/language.d
    src/world/nation.d
    src/world/nationprototype.d
    src/world/resourcemanager.d
    src/world/scenario.d
    src/world/settlementcreator.d
    src/world/structure.d
    src/world/structureprototype.d
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
