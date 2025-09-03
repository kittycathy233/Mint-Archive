package;

import player.LogoState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import debug.FPSCounter;
import utils.SettingsData;
import utils.LoadingManager;
import utils.AssetLoader;
import utils.TrailParticlePool;

class Main extends Sprite {
    private var flixelGame:FlxGame;
    private var fpsCounter:FPSCounter;

    public function new() {
        super();
        
        trace("Main: Starting application initialization...");
        
        // Initialize core systems first
        SettingsData.init();
        LoadingManager.init();
        
        // Start multi-threaded loading and object pool initialization
        LoadingManager.instance.startInitialization(onSystemsReady);
        
        // Create the game immediately (loading will happen in background)
        flixelGame = new FlxGame(1920, 1080, LogoState, 60);
        FlxG.autoPause = false;
        
        // Apply settings
        SettingsData.instance.apply();
        
        addChild(flixelGame);

        // Create FPS counter if enabled
        if (SettingsData.instance.showFPS) {
            fpsCounter = new FPSCounter(10, 10);
            addChild(fpsCounter);
        }
        
        trace("Main: Application initialized, background loading started");
    }
    
    /**
     * 当所有系统准备就绪时调用
     */
    private function onSystemsReady():Void
    {
        trace("Main: All systems ready - multi-threaded loading complete");
        
        // 可以在这里执行需要等待加载完成的操作
        // 例如：预缓存某些数据、初始化高级功能等
        
        // 输出性能统计
        if (TrailParticlePool.instance != null)
        {
            var stats = TrailParticlePool.instance.getPoolStats();
            trace("Main: TrailParticlePool ready - " + stats.available + " particles available");
        }
    }
}