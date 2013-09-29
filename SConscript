srcFiles = Split("""
    src/client.d
    src/color.d
    src/constants.d
    src/game.d
    src/list.d
    src/main.d
    src/map.d
    src/messagebroker.d
    src/observable.d
    src/observer.d
    src/player.d
    src/position.d
    src/rect.d
    src/utils.d
    src/structuremanager.d
    src/textinput.d
    src/script/expressions.d
    src/script/script.d
    src/script/scriptcontext.d
    src/script/token.d
    src/ui/button.d
    src/ui/cloudrenderer.d
    src/ui/fontmanager.d
    src/ui/hoverwidget.d
    src/ui/image.d
    src/ui/ingamerenderer.d
    src/ui/inputbox.d
    src/ui/label.d
    src/ui/labelbutton.d
    src/ui/mainmenu.d
    src/ui/maplayer.d
    src/ui/maplayers.d
    src/ui/maprenderer.d
    src/ui/minimap.d
    src/ui/popupbutton.d
    src/ui/renderer.d
    src/ui/renderdispatcher.d
    src/ui/renderhelper.d
    src/ui/rendererfactory.d
    src/ui/renderstate.d
    src/ui/resourceloader.d
    src/ui/textinputrenderer.d
    src/ui/texture.d
    src/ui/texturemanager.d
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
env.Append(DFLAGS  = ['-debug=1', '-unittest'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kayzers', source = srcFiles)

Default(default)
