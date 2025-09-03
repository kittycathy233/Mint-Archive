package utils;

import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.media.Sound;
import haxe.Timer;
import flixel.FlxG;

/**
 * 多线程资源加载器
 * 异步加载游戏资源，提升启动性能
 */
class AssetLoader
{
    public static var instance:AssetLoader;
    
    private var loadQueue:Array<AssetLoadItem>;
    private var loadedAssets:Map<String, Dynamic>;
    private var isLoading:Bool = false;
    private var onCompleteCallback:Void->Void;
    private var onProgressCallback:Float->Void;
    private var totalItems:Int = 0;
    private var loadedItems:Int = 0;
    
    public function new()
    {
        loadQueue = [];
        loadedAssets = new Map<String, Dynamic>();
    }
    
    public static function init():Void
    {
        if (instance == null)
        {
            instance = new AssetLoader();
        }
    }
    
    /**
     * 添加资源到加载队列
     */
    public function addToQueue(path:String, type:AssetType, priority:Int = 0):Void
    {
        var item = new AssetLoadItem(path, type, priority);
        loadQueue.push(item);
        
        // 按优先级排序（高优先级先加载）
        loadQueue.sort(function(a, b) return b.priority - a.priority);
    }
    
    /**
     * 批量添加图片资源
     */
    public function addImages(paths:Array<String>, priority:Int = 0):Void
    {
        for (path in paths)
        {
            addToQueue(path, AssetType.IMAGE, priority);
        }
    }
    
    /**
     * 批量添加音频资源
     */
    public function addSounds(paths:Array<String>, priority:Int = 0):Void
    {
        for (path in paths)
        {
            addToQueue(path, AssetType.SOUND, priority);
        }
    }
    
    /**
     * 开始异步加载
     */
    public function startLoading(onComplete:Void->Void = null, onProgress:Float->Void = null):Void
    {
        if (isLoading)
        {
            trace("AssetLoader: Already loading, ignoring request");
            return;
        }
        
        this.onCompleteCallback = onComplete;
        this.onProgressCallback = onProgress;
        this.totalItems = loadQueue.length;
        this.loadedItems = 0;
        this.isLoading = true;
        
        trace("AssetLoader: Starting to load " + totalItems + " assets");
        
        if (totalItems == 0)
        {
            finishLoading();
            return;
        }
        
        // 开始异步加载
        loadNextItem();
    }
    
    /**
     * 加载下一个资源项
     */
    private function loadNextItem():Void
    {
        if (loadQueue.length == 0)
        {
            finishLoading();
            return;
        }
        
        var item = loadQueue.shift();
        
        // 使用Timer来模拟异步加载，避免阻塞主线程
        Timer.delay(function() {
            loadAssetAsync(item);
        }, 1);
    }
    
    /**
     * 异步加载单个资源
     */
    private function loadAssetAsync(item:AssetLoadItem):Void
    {
        try
        {
            var asset:Dynamic = null;
            
            switch (item.type)
            {
                case AssetType.IMAGE:
                    if (Assets.exists(item.path, AssetType.IMAGE))
                    {
                        asset = Assets.getBitmapData(item.path);
                    }
                    
                case AssetType.SOUND:
                    if (Assets.exists(item.path, AssetType.SOUND))
                    {
                        asset = Assets.getSound(item.path);
                    }
                    
                case AssetType.TEXT:
                    if (Assets.exists(item.path, AssetType.TEXT))
                    {
                        asset = Assets.getText(item.path);
                    }
                    
                default:
                    trace("AssetLoader: Unsupported asset type for " + item.path);
            }
            
            if (asset != null)
            {
                loadedAssets.set(item.path, asset);
                trace("AssetLoader: Loaded " + item.path);
            }
            else
            {
                trace("AssetLoader: Failed to load " + item.path);
            }
        }
        catch (e:Dynamic)
        {
            trace("AssetLoader: Error loading " + item.path + ": " + e);
        }
        
        loadedItems++;
        
        // 更新进度
        if (onProgressCallback != null)
        {
            var progress = loadedItems / totalItems;
            onProgressCallback(progress);
        }
        
        // 继续加载下一个
        Timer.delay(loadNextItem, 1);
    }
    
    /**
     * 完成加载
     */
    private function finishLoading():Void
    {
        isLoading = false;
        trace("AssetLoader: Finished loading " + loadedItems + "/" + totalItems + " assets");
        
        if (onCompleteCallback != null)
        {
            onCompleteCallback();
        }
    }
    
    /**
     * 获取已加载的资源
     */
    public function getAsset(path:String):Dynamic
    {
        return loadedAssets.get(path);
    }
    
    /**
     * 检查资源是否已加载
     */
    public function isAssetLoaded(path:String):Bool
    {
        return loadedAssets.exists(path);
    }
    
    /**
     * 获取加载进度
     */
    public function getProgress():Float
    {
        if (totalItems == 0) return 1.0;
        return loadedItems / totalItems;
    }
    
    /**
     * 清理已加载的资源
     */
    public function clear():Void
    {
        for (asset in loadedAssets)
        {
            if (Std.is(asset, BitmapData))
            {
                cast(asset, BitmapData).dispose();
            }
        }
        loadedAssets.clear();
        loadQueue = [];
        trace("AssetLoader: Cleared all assets");
    }
}

/**
 * 资源加载项
 */
class AssetLoadItem
{
    public var path:String;
    public var type:AssetType;
    public var priority:Int;
    
    public function new(path:String, type:AssetType, priority:Int = 0)
    {
        this.path = path;
        this.type = type;
        this.priority = priority;
    }
}