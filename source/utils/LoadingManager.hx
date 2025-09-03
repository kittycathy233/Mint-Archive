package utils;

import flixel.FlxG;
import openfl.utils.AssetType;

/**
 * 统一的加载管理器
 * 协调多线程加载和对象池初始化
 */
class LoadingManager
{
    public static var instance:LoadingManager;
    
    private var isInitialized:Bool = false;
    private var loadingComplete:Bool = false;
    private var onCompleteCallback:Void->Void;
    
    public function new()
    {
        
    }
    
    public static function init():Void
    {
        if (instance == null)
        {
            instance = new LoadingManager();
            trace("LoadingManager: Initialized");
        }
    }
    
    /**
     * 开始初始化所有系统
     */
    public function startInitialization(onComplete:Void->Void = null):Void
    {
        if (isInitialized)
        {
            if (onComplete != null) onComplete();
            return;
        }
        
        this.onCompleteCallback = onComplete;
        
        trace("LoadingManager: Starting initialization...");
        
        // 1. 初始化对象池系统
        initializeObjectPools();
        
        // 2. 初始化资源加载器
        AssetLoader.init();
        
        // 3. 预加载关键资源
        preloadCriticalAssets();
        
        // 4. 开始异步加载
        AssetLoader.instance.startLoading(onLoadingComplete, onLoadingProgress);
    }
    
    /**
     * 初始化对象池
     */
    private function initializeObjectPools():Void
    {
        trace("LoadingManager: Initializing object pools...");
        
        // 初始化拖尾粒子池
        TrailParticlePool.init();
        
        // 可以在这里添加更多对象池
        // SpritePool.init();
        // SoundPool.init();
        
        trace("LoadingManager: Object pools initialized");
    }
    
    /**
     * 预加载关键资源
     */
    private function preloadCriticalAssets():Void
    {
        trace("LoadingManager: Adding critical assets to load queue...");
        
        var loader = AssetLoader.instance;
        
        // 高优先级：UI和核心游戏资源
        loader.addImages([
            "assets/images/game/icon.png"
        ], 100);
        
        // 中优先级：游戏内容资源
        loader.addImages([
            "assets/images/bg/menuBG.png",
            "assets/images/bg/menuDesat.png"
        ], 50);
        
        // 音频资源
        loader.addSounds([
            "assets/sounds/bells-logo.ogg",
            "assets/sounds/bells-logo.mp3"
        ], 75);
        
        // 低优先级：可选资源
        // loader.addImages(["assets/images/optional/..."], 10);
        
        trace("LoadingManager: Added assets to load queue");
    }
    
    /**
     * 加载进度回调
     */
    private function onLoadingProgress(progress:Float):Void
    {
        trace("LoadingManager: Loading progress: " + Std.int(progress * 100) + "%");
        
        // 可以在这里更新加载界面
        // if (loadingUI != null) loadingUI.updateProgress(progress);
    }
    
    /**
     * 加载完成回调
     */
    private function onLoadingComplete():Void
    {
        trace("LoadingManager: All assets loaded successfully");
        
        loadingComplete = true;
        isInitialized = true;
        
        // 输出对象池状态
        logObjectPoolStats();
        
        if (onCompleteCallback != null)
        {
            onCompleteCallback();
        }
    }
    
    /**
     * 输出对象池统计信息
     */
    private function logObjectPoolStats():Void
    {
        if (TrailParticlePool.instance != null)
        {
            var stats = TrailParticlePool.instance.getPoolStats();
            trace("LoadingManager: TrailParticlePool - Available: " + stats.available + 
                  "/" + stats.maxSize + " (Utilization: " + 
                  Std.int(stats.utilizationRate * 100) + "%)");
        }
    }
    
    /**
     * 检查是否已完成初始化
     */
    public function isReady():Bool
    {
        return isInitialized && loadingComplete;
    }
    
    /**
     * 获取资源
     */
    public function getAsset(path:String):Dynamic
    {
        if (AssetLoader.instance != null)
        {
            return AssetLoader.instance.getAsset(path);
        }
        return null;
    }
    
    /**
     * 清理所有系统
     */
    public function cleanup():Void
    {
        trace("LoadingManager: Cleaning up...");
        
        if (AssetLoader.instance != null)
        {
            AssetLoader.instance.clear();
        }
        
        if (TrailParticlePool.instance != null)
        {
            TrailParticlePool.instance.clear();
        }
        
        isInitialized = false;
        loadingComplete = false;
        
        trace("LoadingManager: Cleanup complete");
    }
}