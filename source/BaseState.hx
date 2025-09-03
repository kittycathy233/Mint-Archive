package;

import flixel.FlxState;
import flixel.FlxG;
import MouseTrail;

/**
 * 基础状态类，为所有游戏状态提供通用功能
 * 包括鼠标拖尾效果
 */
class BaseState extends FlxState
{
    private var mouseTrail:MouseTrail;
    private var mouseTrailEnabled:Bool = true;
    
    override public function create():Void
    {
        super.create();
        
        // 创建鼠标拖尾效果
        if (mouseTrailEnabled)
        {
            mouseTrail = new MouseTrail();
            add(mouseTrail);
            
            // 确保鼠标拖尾在最顶层显示
            mouseTrail.cameras = [FlxG.camera];
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 全局快捷键控制鼠标拖尾
        if (FlxG.keys.justPressed.F1)
        {
            toggleMouseTrail();
        }
        
        // 颜色切换快捷键
        if (mouseTrail != null && mouseTrail.visible)
        {
            if (FlxG.keys.justPressed.F2)
            {
                mouseTrail.setTrailColor(0xFF3366FF); // 蓝色
            }
            else if (FlxG.keys.justPressed.F3)
            {
                mouseTrail.setTrailColor(0xFFFF3366); // 红色
            }
            else if (FlxG.keys.justPressed.F4)
            {
                mouseTrail.setTrailColor(0xFF33FF66); // 绿色
            }
            else if (FlxG.keys.justPressed.F5)
            {
                mouseTrail.setTrailColor(0xFFFFFF33); // 黄色
            }
            else if (FlxG.keys.justPressed.F6)
            {
                mouseTrail.setTrailColor(0xFFFF33FF); // 紫色
            }
            else if (FlxG.keys.justPressed.F7)
            {
                mouseTrail.setTrailColor(0xFFFFFFFF); // 白色
            }
        }
    }
    
    /**
     * 切换鼠标拖尾效果的显示状态
     */
    public function toggleMouseTrail():Void
    {
        if (mouseTrail != null)
        {
            mouseTrail.setEnabled(!mouseTrail.visible);
            trace('Mouse trail toggled: ' + mouseTrail.visible);
        }
    }
    
    /**
     * 设置是否启用鼠标拖尾效果
     */
    public function setMouseTrailEnabled(enabled:Bool):Void
    {
        mouseTrailEnabled = enabled;
        
        if (mouseTrail != null)
        {
            mouseTrail.setEnabled(enabled);
        }
    }
    
    /**
     * 获取鼠标拖尾对象，用于自定义设置
     */
    public function getMouseTrail():MouseTrail
    {
        return mouseTrail;
    }
    
    override public function destroy():Void
    {
        if (mouseTrail != null)
        {
            mouseTrail.destroy();
            mouseTrail = null;
        }
        
        super.destroy();
    }
}