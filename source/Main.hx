package;

import player.LogoState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import debug.FPSCounter;

class Main extends Sprite {
    private var flixelGame:FlxGame;
    private var fpsCounter:FPSCounter;

    public function new() {
        super();
        flixelGame = new FlxGame(1920, 1080, LogoState, 120);
        FlxG.autoPause = false;
        addChild(flixelGame);
        
        fpsCounter = new FPSCounter(10, 10);
        addChild(fpsCounter);
    }
}