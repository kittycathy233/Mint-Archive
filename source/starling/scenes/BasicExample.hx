package starling.scenes;

import starling.scenes.SceneManager;
import openfl.utils.Assets;
import spine.SkeletonData;
import spine.animation.AnimationStateData;
import spine.atlas.TextureAtlas;
import spine.starling.SkeletonSprite;
import spine.starling.StarlingTextureLoader;
import starling.core.Starling;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class BasicExample extends BaseStarlingState {
    var loadBinary = true;

    public override function load():Void {
        super.load();
        
        // 设置背景色
        background.color = 0x0F0F23;
        
        // 这里可以添加具体的 Spine 动画加载逻辑
        // 目前先创建一个简单的示例
        
        addText("Starling Spine Example");
        addText("Click anywhere to return to menu", 10, 50);
        addText("Mouse trail effect is active", 10, 80);
        addText("F1: Toggle Mouse Trail, F2-F7: Change Colors", 10, 110);

        addEventListener(TouchEvent.TOUCH, onTouch);
        
        trace("BasicExample: Loaded with mouse trail support");
    }

    public function onTouch(e:TouchEvent) {
        var touch = e.getTouch(this);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            trace("BasicExample: Touch detected, returning to main menu");
            SceneManager.getInstance().switchScene(new StarlingMainMenuState());
        }
    }
    
    public override function dispose():Void {
        removeEventListener(TouchEvent.TOUCH, onTouch);
        super.dispose();
    }
}