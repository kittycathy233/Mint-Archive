package debug;

import flixel.FlxG;
import flixel.FlxState;
import debug.TransitionSubState.TransitionType;

class TransitionManager {
    public static function switchState(nextState:Class<FlxState>, type:TransitionType = FADE):Void {
        var curState = FlxG.state;
        
        // 创建转场入场效果
        var transIn = new TransitionSubState(type, false, function() {
            FlxG.switchState(Type.createInstance(nextState, []));
            // 切换后创建转场出场效果
            var transOut = new TransitionSubState(type, true);
            FlxG.state.openSubState(transOut);
        });
        
        curState.openSubState(transIn);
    }
}
