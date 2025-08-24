package;

import player.LogoState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import debug.FPSCounter;
import utils.SettingsData;

class Main extends Sprite {
    private var flixelGame:FlxGame;
    private var fpsCounter:FPSCounter;

    public function new() {
        super();
        
        // Initialize settings before creating the game
        SettingsData.init();
        
        flixelGame = new FlxGame(1920, 1080, LogoState, 120);
        FlxG.autoPause = false;
        
        // Apply settings
        SettingsData.instance.apply();
        
        addChild(flixelGame);
        FlxG.drawFramerate = 120;

        FlxG.updateFramerate = SettingsData.instance.frameRateLimit;

        // Create FPS counter if enabled
        if (SettingsData.instance.showFPS) {
            fpsCounter = new FPSCounter(10, 10);
            addChild(fpsCounter);
        }
    }
}