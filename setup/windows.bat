@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.

haxelib install openfl 9.4.1
haxelib install flixel 6.1.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-ui 2.6.4
haxelib install starling 2.7.1
haxelib install hxcpp 4.3.2
haxelib install hxvlc 2.2.2
haxelib install lime 8.1.3
haxelib install hscript 2.6.0
haxelib install json2object 3.11.0
haxelib install hxjsonast 1.1.0

haxelib git spine-haxe https://github.com/EsotericSoftware/spine-runtimes/ cd726af62b8cbf12ba47c6c0f68d8e04451cf162 spine-haxe
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio
echo Finished!
pause