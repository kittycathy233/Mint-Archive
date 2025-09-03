package options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Assets;
import utils.SettingsData;

class OptionsTitle
{
    public var titleText:FlxText;
    public var titleTrailGroup:FlxTypedGroup<FlxText>;
    public var shadowText:FlxText;
    
    // 动画变量
    private var titleY:Float = 50;
    private var titleAmplitude:Float = 4;
    private var titleSpeed:Float = 4;
    private var titleTime:Float = 0;
    
    private var parent:OptionsState;
    
    public function new(parent:OptionsState)
    {
        this.parent = parent;
    }
    
    public function create():Void
    {
        // 根据主题模式选择不同的颜色
        var titleColor:FlxColor;
        var borderColor:FlxColor;
        
        if (SettingsData.instance.themeMode == "Light") {
            // 浅色模式下使用深蓝色标题和黑色边框
            titleColor = FlxColor.fromRGB(25, 25, 112); // 深蓝色
            borderColor = FlxColor.BLACK;
        } else {
            // 深色模式下使用浅蓝色标题和深蓝色边框
            titleColor = FlxColor.fromRGB(135, 206, 250); // 浅蓝色
            borderColor = FlxColor.fromRGB(25, 25, 112); // 深蓝色
        }
        
        titleText = new FlxText(0, titleY, FlxG.width, "SETTINGS", 32);
        titleText.setFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 60, 
                           titleColor, CENTER, FlxTextBorderStyle.OUTLINE, borderColor);
        titleText.borderSize = 4;
        
        // 添加阴影效果
        shadowText = new FlxText(titleText.x + 4, titleText.y + 4, FlxG.width, "SETTINGS", 32);
        shadowText.setFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 60, 
                            FlxColor.fromRGB(0, 0, 0, 120), // 半透明黑色
                            CENTER);
        parent.add(shadowText);
        
        parent.add(titleText);

        titleTrailGroup = new FlxTypedGroup<FlxText>();
        parent.add(titleTrailGroup);
    }
    
    public function update(elapsed:Float):Void
    {
        titleTime += elapsed;
        titleText.y = titleY + Math.sin(titleTime * titleSpeed) * titleAmplitude;
        
        // 同步阴影位置
        if (shadowText != null) {
            shadowText.y = titleText.y + 4;
        }
        
        updateTitleTrails(elapsed);
    }
    
    /**
     * 更新标题主题颜色
     */
    public function updateTheme():Void
    {
        // 根据主题模式选择不同的颜色
        var titleColor:FlxColor;
        var borderColor:FlxColor;
        
        if (SettingsData.instance.themeMode == "Light") {
            // 浅色模式下使用深蓝色标题和黑色边框
            titleColor = FlxColor.fromRGB(25, 25, 112); // 深蓝色
            borderColor = FlxColor.BLACK;
        } else {
            // 深色模式下使用浅蓝色标题和深蓝色边框
            titleColor = FlxColor.fromRGB(135, 206, 250); // 浅蓝色
            borderColor = FlxColor.fromRGB(25, 25, 112); // 深蓝色
        }
        
        // 更新标题颜色
        if (titleText != null) {
            titleText.color = titleColor;
            titleText.borderColor = borderColor;
        }
    }
    
    public function createTitleTrail():Void
    {
        var trail:FlxText = new FlxText(titleText.x, titleText.y, FlxG.width, "SETTINGS", 32);
        trail.setFormat(null, 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        trail.borderSize = 4;
        trail.alpha = 0.5;
        titleTrailGroup.add(trail);
    }
    
    private function updateTitleTrails(elapsed:Float):Void
    {
        for (trail in titleTrailGroup.members)
        {
            if (trail != null)
            {
                trail.y += elapsed * 50;
                trail.alpha -= elapsed * 2;
                
                if (trail.alpha <= 0)
                {
                    titleTrailGroup.remove(trail, true);
                    trail.destroy();
                }
            }
        }
    }
}