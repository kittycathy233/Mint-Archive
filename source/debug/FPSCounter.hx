package debug;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.system.System;
import openfl.Lib;

class FPSCounter extends Sprite {
    private var text:TextField;
    private var times:Array<Float>;
    private var memPeak:Float = 0;

    public function new(x:Float = 10, y:Float = 10) {
        super();
        
        text = new TextField();
        text.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF, true);
        text.autoSize = LEFT;
        text.selectable = false;
        text.mouseEnabled = false;
        text.x = x;
        text.y = y;
        addChild(text);
        
        times = [];
        addEventListener(Event.ENTER_FRAME, update);
    }

    private function update(_:Event):Void {
        var now:Float = Lib.getTimer();
        times.push(now);
        
        while (times[0] < now - 1000)
            times.shift();
            
        var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
        if (mem > memPeak) memPeak = mem;
        
        if (visible) {
            text.text = "FPS: " + times.length
                + "\nMEM: " + mem + " MB"
                + "\nMEM peak: " + memPeak + " MB";
        }
    }
}
