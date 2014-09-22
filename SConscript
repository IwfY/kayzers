srcFiles = Split("""
    source/client.d
    source/color.d
    source/constants.d
    source/game.d
    source/gamedb.d
    source/list.d
    source/main.d
    source/map.d
    source/message.d
    source/messagebroker.d
    source/observable.d
    source/observer.d
    source/player.d
    source/position.d
    source/rect.d
    source/serverstub.d
    source/utils.d
    source/structuremanager.d
    source/textinput.d
    source/script/expressions.d
    source/script/script.d
    source/script/scriptcontext.d
    source/script/token.d
    source/ui/characterinforenderer.d
    source/ui/characternamerenderer.d
    source/ui/characterproposalrenderer.d
    source/ui/cloudrenderer.d
    source/ui/fontmanager.d
    source/ui/ingamerenderer.d
    source/ui/mainmenu.d
    source/ui/maplayer.d
    source/ui/maplayers.d
    source/ui/maprenderer.d
    source/ui/minimap.d
    source/ui/notificationrenderer.d
    source/ui/proposalreplyrenderer.d
    source/ui/renderer.d
    source/ui/renderdispatcher.d
    source/ui/renderhelper.d
    source/ui/rendererfactory.d
    source/ui/renderstate.d
    source/ui/resourceloader.d
    source/ui/scenariolistrenderer.d
    source/ui/structurenamerenderer.d
    source/ui/texture.d
    source/ui/texturemanager.d
    source/ui/ui.d
    source/ui/widgetrenderer.d
    source/ui/widgets/button.d
    source/ui/widgets/characterdetails.d
    source/ui/widgets/characterinfo.d
    source/ui/widgets/clickwidgetdecorator.d
    source/ui/widgets/containerwidget.d
    source/ui/widgets/hbox.d
    source/ui/widgets/hoverwidget.d
    source/ui/widgets/image.d
    source/ui/widgets/inputbox.d
    source/ui/widgets/iwidget.d
    source/ui/widgets/label.d
    source/ui/widgets/labelbutton.d
    source/ui/widgets/line.d
    source/ui/widgets/popupwidgetdecorator.d
    source/ui/widgets/positionbox.d
    source/ui/widgets/roundborderimage.d
    source/ui/widgets/vbox.d
    source/ui/widgets/vboxpaged.d
    source/ui/widgets/widget.d
    source/ui/widgets/widgetdecorator.d
    source/world/character.d
    source/world/charactermanager.d
    source/world/dynasty.d
    source/world/language.d
    source/world/nation.d
    source/world/nationprototype.d
    source/world/resourcemanager.d
    source/world/scenario.d
    source/world/settlementcreator.d
    source/world/structure.d
    source/world/structureprototype.d
    includes/d2sqlite/d2sqlite3.d
""")

#dFlags = ['-L-ldl',
#		  '-L-lDerelictSDL2',
#		  '-L-lDerelictUtil',
#		  '-L-lsqlite3']

libs = ['dl',
		'DerelictSDL2',
		'DerelictUtil',
		'sqlite3',
		'phobos2']

libPath = ['libs/derelict']
#libPath = ['/usr/lib/dmd']

dPath = ['includes',
		 'src']


# build environment

env = Environment()
env.Append(DPATH   = dPath)
# add '-g' to allow debugging with gdb
env.Append(DFLAGS  = ['-debug=1', '-unittest'])
env.Append(LIBPATH = libPath)
env.Append(LIBS = libs)
default = env.Program(target = 'kayzers', source = srcFiles)

Default(default)
