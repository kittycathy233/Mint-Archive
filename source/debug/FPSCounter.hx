package debug;

import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.system.System;
import openfl.Lib;
import openfl.text.Font;
import openfl.Assets;
#if flixel
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
#end

class FPSCounter extends Sprite {
    private var text:TextField;
    private var background:Sprite;
    private var times:Array<Float>;
    private var memPeak:Float = 0;
    private var padding:Float = 5;

    public function new(x:Float = 10, y:Float = 10) {
        super();
        
        // 创建半透明黑色背景
        background = new Sprite();
        addChild(background);
        background.x = x + padding;
        background.y = y + padding;

        // 创建文本显示
        text = new TextField();
        //text.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF, true);
        text.defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 16, 0xFFFFFF, true);
        text.autoSize = LEFT;
        text.selectable = false;
        text.mouseEnabled = false;
        text.x = x + padding;
        text.y = y + padding;
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
            // 获取当前状态和子状态信息
            var stateInfo:String = "";
            var objectCount:Int = 0;
            
            #if flixel
            var currentState:FlxState = FlxG.state;
            var currentSubState:FlxSubState = FlxG.state.subState;
            
            if (currentState != null) {
                stateInfo = "State: " + Type.getClassName(Type.getClass(currentState));
                
                // 计算状态中的对象数量
                objectCount = countObjectsInState(currentState);
                stateInfo += " (Objects: " + objectCount + ")";
            }
            
            if (currentSubState != null) {
                stateInfo += " \nSubState: " + Type.getClassName(Type.getClass(currentSubState));
                
                // 计算子状态中的对象数量
                var subStateObjectCount:Int = countObjectsInState(currentSubState);
                stateInfo += " (Objects: " + subStateObjectCount + ")";
                objectCount += subStateObjectCount;
            }
            
            // 添加窗口大小和游戏渲染大小信息
            stateInfo += " \nWindow Size: " + Lib.current.stage.stageWidth + "x" + Lib.current.stage.stageHeight;
            stateInfo += " \nGame Size: " + FlxG.width + "x" + FlxG.height;
            #else
            stateInfo = "Flixel not available";
            #end
            
            // 更新文本内容
            text.text = "FPS: " + times.length
                + " MEM: " + mem + "MB"
                + " - " + memPeak + "MB\n"
                + stateInfo;
            
            // 更新背景大小
            drawBackground();
        }
    }
    
    #if flixel
    private function countObjectsInState(state:FlxState):Int {
        var count:Int = 0;
        
        // 递归计算FlxGroup中的对象数量
        function countGroupMembers(group:FlxGroup):Int {
            var groupCount:Int = 0;
            for (member in group.members) {
                if (member != null) {
                    groupCount++;
                    // 如果成员本身也是一个组，递归计算
                    if (Std.isOfType(member, FlxGroup)) {
                        groupCount += countGroupMembers(cast member);
                    }
                }
            }
            return groupCount;
        }
        
        // 状态本身是一个FlxGroup，所以我们可以直接计算其成员
        return countGroupMembers(state);
    }
    #end
    
    private function drawBackground():Void {
        var g:Graphics = background.graphics;
        g.clear();
        g.beginFill(0x000000, 0.5); // 半透明黑色背景
        g.drawRect(0, 0, text.width + padding * 2, text.height + padding * 2);
        g.endFill();
    }
}