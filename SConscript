srcFiles = Split("""
    src/client.d
    src/color.d
    src/constants.d
    src/game.d
    src/list.d
    src/main.d
    src/map.d
    src/message.d
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
    src/ui/characterinforenderer.d
    src/ui/characternamerenderer.d
    src/ui/characterproposalrenderer.d
    src/ui/cloudrenderer.d
    src/ui/fontmanager.d
    src/ui/ingamerenderer.d
    src/ui/mainmenu.d
    src/ui/maplayer.d
    src/ui/maplayers.d
    src/ui/maprenderer.d
    src/ui/minimap.d
    src/ui/notificationrenderer.d
    src/ui/renderer.d
    src/ui/renderdispatcher.d
    src/ui/renderhelper.d
    src/ui/rendererfactory.d
    src/ui/renderstate.d
    src/ui/resourceloader.d
    src/ui/scenariolistrenderer.d
    src/ui/structurenamerenderer.d
    src/ui/texture.d
    src/ui/texturemanager.d
    src/ui/ui.d
    src/ui/widgetrenderer.d
    src/ui/widgets/button.d
    src/ui/widgets/characterdetails.d
    src/ui/widgets/characterinfo.d
    src/ui/widgets/clickwidgetdecorator.d
    src/ui/widgets/containerwidget.d
    src/ui/widgets/hbox.d
    src/ui/widgets/hoverwidget.d
    src/ui/widgets/image.d
    src/ui/widgets/inputbox.d
    src/ui/widgets/iwidget.d
    src/ui/widgets/label.d
    src/ui/widgets/labelbutton.d
    src/ui/widgets/line.d
    src/ui/widgets/popupwidgetdecorator.d
    src/ui/widgets/positionbox.d
    src/ui/widgets/roundborderimage.d
    src/ui/widgets/vbox.d
    src/ui/widgets/widget.d
    src/ui/widgets/widgetdecorator.d
    src/world/character.d
    src/world/charactermanager.d
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

dFlags = ['-L-ldl',
		  '-L-lDerelictSDL2'
		  '-L-lDerelictUtil']

libs = ['dl',
		'DerelictSDL2',
		'DerelictUtil',
		'phobos2']

libPath = ['libs/derelict']
#libPath = ['/usr/lib/dmd']

dPath = ['includes',
		 'src']


# build environment

env = Environment()
env.Append(DPATH   = dPath)
env.Append(DFLAGS  = ['-debug=1', '-unittest'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kayzers', source = srcFiles)

Default(default)
