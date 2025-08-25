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
import flixel.tweens.FlxTween;

class LogoState extends FlxState
{
    var logo:FlxSprite;
    var hasFinished:Bool = false;
    
    override public function create():Void
    {
        FlxG.drawFramerate = 60;

        SettingsData.init();
        SettingsData.instance.load();
        super.create();
		
		#if NO_LOGO
        hasFinished = true;
		finishLogo();
		#else
		TransitionManager.switchState(MainMenuState, TransitionType.FADE);
		return;
		logo = new FlxSprite(0, 0);
		logo.loadGraphic("assets/images/game/icon.png");
		logo.alpha = 0;
		logo.screenCenter();
		add(logo);

		#if (desktop || mobile)
		FlxG.sound.play("assets/sounds/bells-logo.ogg", 1, false, null, true, onSoundComplete);
		#else
		FlxG.sound.play("assets/sounds/bells-logo.mp3", 1, false, null, true, onSoundComplete);
		#end

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
