package debug;

import flixel.FlxG;
import flixel.FlxState;
import debug.TransitionSubState.TransitionType;

class TransitionManager {
    public static function switchState(nextState:Class<FlxState>, type:TransitionType = FADE, duration:Float = 0.5):Void {
        var curState = FlxG.state;
        FlxG.updateFramerate = SettingsData.instance.frameRateLimit;

        // 创建转场入场效果
        var transIn = new TransitionSubState(type, false, duration, function() {
            FlxG.switchState(Type.createInstance(nextState, []));
            // 切换后创建转场出场效果
            var transOut = new TransitionSubState(type, true, duration);
            FlxG.state.openSubState(transOut);
        });
        
        curState.openSubState(transIn);
    }
}