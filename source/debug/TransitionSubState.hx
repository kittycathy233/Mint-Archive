package debug;

import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

enum TransitionType {
    FADE;
    SLIDE_LEFT;
    SLIDE_RIGHT;
    CIRCLE_CLOSE;
}

class TransitionSubState extends FlxSubState {
    var onFinish:Void->Void;
    var overlay:FlxSprite;
    var isOut:Bool;
    var duration:Float;
    
    public function new(type:TransitionType, out:Bool, duration:Float = 0.5, ?onFinishCallback:Void->Void) {
        super();
        this.onFinish = onFinishCallback;
        this.isOut = out;
        this.duration = duration;
        
        overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(overlay);
        
        switch(type) {
            case FADE:
                setupFade();
            case SLIDE_LEFT:
                setupSlideLeft();
            case SLIDE_RIGHT:
                setupSlideRight();
            case CIRCLE_CLOSE:
                setupCircleTransition();
        }
    }
    
    private function setupFade():Void {
        overlay.alpha = isOut ? 1 : 0;
        FlxTween.tween(overlay, {alpha: isOut ? 0 : 1}, duration, {
            onComplete: finishTransition
        });
    }
    
    private function setupSlideLeft():Void {
        overlay.x = isOut ? 0 : FlxG.width;
        FlxTween.tween(overlay, {x: isOut ? -FlxG.width : 0}, duration, {
            ease: FlxEase.quartInOut,
            onComplete: finishTransition
        });
    }
    
    private function setupSlideRight():Void {
        overlay.x = isOut ? 0 : -FlxG.width;
        FlxTween.tween(overlay, {x: isOut ? FlxG.width : 0}, duration, {
            ease: FlxEase.quartInOut,
            onComplete: finishTransition
        });
    }
    
    private function setupCircleTransition():Void {
        var scale = isOut ? 1 : 0;
        overlay.scale.set(scale, scale);
        overlay.updateHitbox();
        overlay.screenCenter();
        FlxTween.tween(overlay.scale, {x: isOut ? 0 : 1, y: isOut ? 0 : 1}, duration, {
            ease: FlxEase.quartInOut,
            onComplete: finishTransition
        });
    }
    
    private function finishTransition(_):Void {
        if (onFinish != null) onFinish();
        if (isOut) close();
    }
}