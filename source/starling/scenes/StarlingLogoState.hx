package starling.scenes;

import starling.display.Image;
import starling.textures.Texture;
import starling.core.Starling;
import starling.animation.Tween;
import starling.animation.Transitions;
import starling.events.Event;
import starling.scenes.SceneManager.Scene;
import openfl.utils.Assets;
import utils.SettingsData;
import utils.LoadingManager;
import utils.TrailParticlePool;

class StarlingLogoState extends BaseStarlingState {
    private var logo:Image;
    private var hasFinished:Bool = false;
    private var logoTween:Tween;
    
    public override function load():Void {
        super.load();
        
        trace("StarlingLogoState: Starting Starling logo initialization...");
        
        // 确保设置和加载管理器已初始化
        SettingsData.init();
        SettingsData.instance.load();
        
        // 检查加载管理器状态
        if (LoadingManager.instance == null) {
            LoadingManager.init();
        }
        
        trace("StarlingLogoState: Checking loading status...");
        
        // 检查是否已经完成后台加载
        if (LoadingManager.instance.isReady()) {
            trace("StarlingLogoState: Background loading already complete");
            createLogoWithLoadedAssets();
        } else {
            trace("StarlingLogoState: Waiting for background loading...");
            // 等待加载完成，然后创建logo
            waitForLoadingComplete();
        }
    }
    
    /**
     * 等待后台加载完成
     */
    private function waitForLoadingComplete():Void {
        // 使用 Starling 的 juggler 来检查加载状态
        checkLoadingStatus();
    }
    
    private function checkLoadingStatus():Void {
        if (LoadingManager.instance.isReady()) {
            trace("StarlingLogoState: Background loading completed, creating logo");
            createLogoWithLoadedAssets();
        } else {
            Starling.current.juggler.delayCall(checkLoadingStatus, 0.1); // 继续检查
        }
    }
    
    /**
     * 使用已加载的资源创建Logo
     */
    private function createLogoWithLoadedAssets():Void {
        #if NO_LOGO
        hasFinished = true;
        finishLogo();
        #else
        // 直接跳转到主菜单
        SceneManager.getInstance().switchScene(new StarlingMainMenuState());
        return;
        
        // 以下是logo显示逻辑（如果需要的话）
        try {
            var iconTexture = Texture.fromBitmapData(Assets.getBitmapData("assets/images/game/icon.png"));
            logo = new Image(iconTexture);
            logo.alpha = 0;
            
            // 居中显示
            logo.x = (Starling.current.stage.stageWidth - logo.width) / 2;
            logo.y = (Starling.current.stage.stageHeight - logo.height) / 2;
            
            addChild(logo);
            
            // Logo淡入动画
            logoTween = new Tween(logo, 1.0, Transitions.EASE_IN);
            logoTween.animate("alpha", 1.0);
            logoTween.onComplete = function() {
                // 等待1.5秒后淡出
                Starling.current.juggler.delayCall(function() {
                    var fadeOutTween = new Tween(logo, 1.0, Transitions.EASE_OUT);
                    fadeOutTween.animate("alpha", 0.0);
                    fadeOutTween.onComplete = function() {
                        if (hasFinished) finishLogo();
                    };
                    Starling.current.juggler.add(fadeOutTween);
                }, 1.5);
            };
            
            Starling.current.juggler.add(logoTween);
            
            // 播放音效（如果需要）
            // 这里可以添加音效播放逻辑
            
        } catch (e:Dynamic) {
            trace("StarlingLogoState: Error loading logo: " + e);
            finishLogo();
        }
        #end
    }
    
    private function finishLogo():Void {
        SceneManager.getInstance().switchScene(new StarlingMainMenuState());
    }
    
    /**
     * 当所有系统准备就绪时调用
     */
    private function onSystemsReady():Void {
        trace("StarlingLogoState: All systems ready - multi-threaded loading complete");
        
        // 输出性能统计
        if (TrailParticlePool.instance != null) {
            var stats = TrailParticlePool.instance.getPoolStats();
            trace("StarlingLogoState: TrailParticlePool ready - " + stats.available + " particles available");
        }
    }
    
    public override function dispose():Void {
        if (logoTween != null) {
            Starling.current.juggler.remove(logoTween);
            logoTween = null;
        }
        
        if (logo != null) {
            logo.dispose();
            logo = null;
        }
        
        super.dispose();
    }
}