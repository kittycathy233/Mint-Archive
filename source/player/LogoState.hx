package player;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import debug.TransitionManager;
import debug.TransitionSubState.TransitionType;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import utils.SettingsData;
import utils.LoadingManager;
import utils.AssetLoader;

class LogoState extends FlxState
{
    var logo:FlxSprite;
    var hasFinished:Bool = false;
    
    override public function create():Void
    {
        FlxG.drawFramerate = 60;

        // 确保设置和加载管理器已初始化
        SettingsData.init();
        SettingsData.instance.load();
        
        // 检查加载管理器状态
        if (LoadingManager.instance == null)
        {
            LoadingManager.init();
        }
        
        super.create();
        
        trace("LogoState: Checking loading status...");
        
        // 检查是否已经完成后台加载
        if (LoadingManager.instance.isReady())
        {
            trace("LogoState: Background loading already complete");
            createLogoWithLoadedAssets();
        }
        else
        {
            trace("LogoState: Waiting for background loading...");
            // 等待加载完成，然后创建logo
            waitForLoadingComplete();
        }
    }
    
    /**
     * 等待后台加载完成
     */
    private function waitForLoadingComplete():Void
    {
        // 使用定时器检查加载状态
        var checkTimer = new FlxTimer();
        checkTimer.start(0.1, function(timer:FlxTimer) {
            if (LoadingManager.instance.isReady())
            {
                trace("LogoState: Background loading completed, creating logo");
                timer.cancel();
                createLogoWithLoadedAssets();
            }
        }, 0); // 0 = 无限循环直到取消
    }
    
    /**
     * 使用已加载的资源创建Logo
     */
    private function createLogoWithLoadedAssets():Void
    {
		#if NO_LOGO
        hasFinished = true;
		finishLogo();
		#else
		TransitionManager.switchState(MainMenuState, TransitionType.FADE);
		return;
		
		// 尝试从加载管理器获取预加载的图标
		var iconAsset = LoadingManager.instance.getAsset("assets/images/game/icon.png");
		
		logo = new FlxSprite(0, 0);
		if (iconAsset != null)
		{
		    trace("LogoState: Using pre-loaded icon asset");
		    logo.loadGraphic(iconAsset);
		}
		else
		{
		    trace("LogoState: Loading icon asset directly");
		    logo.loadGraphic("assets/images/game/icon.png");
		}
		
		logo.alpha = 0;
		logo.screenCenter();
		add(logo);

		// 尝试使用预加载的音频
		var soundPath:String;
		#if (desktop || mobile)
		soundPath = "assets/sounds/bells-logo.ogg";
		#else
		soundPath = "assets/sounds/bells-logo.mp3";
		#end
		
		var soundAsset = LoadingManager.instance.getAsset(soundPath);
		if (soundAsset != null)
		{
		    trace("LogoState: Using pre-loaded sound asset");
		    FlxG.sound.play(soundAsset, 1, false, null, true, onSoundComplete);
		}
		else
		{
		    trace("LogoState: Loading sound asset directly");
		    FlxG.sound.play(soundPath, 1, false, null, true, onSoundComplete);
		}

		// Logo淡入动画
		FlxTween.tween(logo, {alpha: 1}, 1, {
			ease: FlxEase.quadIn,
			onComplete: function(_) {
				// 等待2秒后淡出
				new FlxTimer().start(1.5, function(_) {
					FlxTween.tween(logo, {alpha: 0}, 1, {
						ease: FlxEase.quadOut,
						onComplete: function(_) {
							if (hasFinished)
								finishLogo();
						}
					});
				});
			}
		});
		#end
    }
    
    private function onSoundComplete():Void
    {
        hasFinished = true;
        if (logo.alpha == 0) finishLogo();
    }
    
    private function finishLogo():Void
    {
        TransitionManager.switchState(MainMenuState, TransitionType.FADE);
    }
}
