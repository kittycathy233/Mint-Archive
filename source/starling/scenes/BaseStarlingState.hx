package starling.scenes;

import starling.display.Sprite;
import starling.core.Starling;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.mouse.MouseTrail;
import starling.scenes.SceneManager.Scene;
import openfl.ui.Keyboard;

/**
 * Starling 基础状态类，为所有 Starling 状态提供通用功能
 * 包括鼠标拖尾效果和状态管理
 */
class BaseStarlingState extends Scene {
    private var mouseTrail:starling.mouse.MouseTrail;
    private var mouseTrailEnabled:Bool = true;
    
    public function new() {
        super();
    }
    
    public override function load():Void {
        // 创建鼠标拖尾效果
        if (mouseTrailEnabled) {
            mouseTrail = new starling.mouse.MouseTrail();
            addChild(mouseTrail);
        }
        
        // 添加键盘事件监听
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }
    
    private function onAddedToStage(event:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        
        // 添加键盘事件监听
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }
    
    private function onKeyDown(event:KeyboardEvent):Void {
        // 全局快捷键控制鼠标拖尾
        if (event.keyCode == Keyboard.F1) {
            toggleMouseTrail();
        }
        
        // 颜色切换快捷键
        if (mouseTrail != null && mouseTrail.visible) {
            switch (event.keyCode) {
                case Keyboard.F2:
                    mouseTrail.setTrailColor(0x3366FF); // 蓝色
                case Keyboard.F3:
                    mouseTrail.setTrailColor(0xFF3366); // 红色
                case Keyboard.F4:
                    mouseTrail.setTrailColor(0x33FF66); // 绿色
                case Keyboard.F5:
                    mouseTrail.setTrailColor(0xFFFF33); // 黄色
                case Keyboard.F6:
                    mouseTrail.setTrailColor(0xFF33FF); // 紫色
                case Keyboard.F7:
                    mouseTrail.setTrailColor(0xFFFFFF); // 白色
            }
        }
    }
    
    /**
     * 切换鼠标拖尾效果的显示状态
     */
    public function toggleMouseTrail():Void {
        if (mouseTrail != null) {
            mouseTrail.setEnabled(!mouseTrail.visible);
            trace('Starling Mouse trail toggled: ' + mouseTrail.visible);
        }
    }
    
    /**
     * 设置是否启用鼠标拖尾效果
     */
    public function setMouseTrailEnabled(enabled:Bool):Void {
        mouseTrailEnabled = enabled;
        
        if (mouseTrail != null) {
            mouseTrail.setEnabled(enabled);
        }
    }
    
    /**
     * 获取鼠标拖尾对象，用于自定义设置
     */
    public function getMouseTrail():starling.mouse.MouseTrail {
        return mouseTrail;
    }
    
    public override function dispose():Void {
        if (stage != null) {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
        
        if (mouseTrail != null) {
            mouseTrail.dispose();
            mouseTrail = null;
        }
        
        super.dispose();
    }
}