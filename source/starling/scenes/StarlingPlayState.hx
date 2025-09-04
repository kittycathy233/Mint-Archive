package starling.scenes;

import starling.text.TextField;
import starling.text.TextFormat;
import starling.core.Starling;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.scenes.SceneManager.Scene;

class StarlingPlayState extends BaseStarlingState {
    
    public override function load():Void {
        super.load();
        
        trace('StarlingPlayState created with mouse trail effect');
        
        // 设置背景色
        background.color = 0x1A1A2E;
        
        // 添加标题
        var titleText = new TextField(400, 60, "Starling Play State", new TextFormat("Verdana", 28, 0xFFFFFF));
        titleText.x = (Starling.current.stage.stageWidth - titleText.width) / 2;
        titleText.y = 50;
        addChild(titleText);
        
        // 添加说明文本
        var infoText = new TextField(600, 200, 
            "Welcome to Starling Play State!\n\n" +
            "This is equivalent to the Flixel PlayState.\n" +
            "Mouse trail effect is active.\n\n" +
            "Controls:\n" +
            "F1: Toggle Mouse Trail\n" +
            "F2-F7: Change Trail Colors\n\n" +
            "Click anywhere to return to menu", 
            new TextFormat("Verdana", 16, 0xCCCCCC));
        infoText.x = (Starling.current.stage.stageWidth - infoText.width) / 2;
        infoText.y = 150;
        addChild(infoText);
        
        // 添加触摸事件监听
        addEventListener(TouchEvent.TOUCH, onTouch);
        
        trace('StarlingPlayState: Setup complete');
    }
    
    private function onTouch(event:TouchEvent):Void {
        var touch = event.getTouch(this);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            trace("StarlingPlayState: Touch detected, returning to menu");
            SceneManager.getInstance().switchScene(new StarlingMainMenuState());
        }
    }
    
    public override function dispose():Void {
        removeEventListener(TouchEvent.TOUCH, onTouch);
        super.dispose();
    }
}