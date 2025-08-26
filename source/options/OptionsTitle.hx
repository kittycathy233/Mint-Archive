package options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Assets;

class OptionsTitle
{
    public var titleText:FlxText;
    public var titleTrailGroup:FlxTypedGroup<FlxText>;
    
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
        titleText = new FlxText(0, titleY, FlxG.width, "SETTINGS", 32);
        titleText.setFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        titleText.borderSize = 4;
        parent.add(titleText);

        titleTrailGroup = new FlxTypedGroup<FlxText>();
        parent.add(titleTrailGroup);
    }
    
    public function update(elapsed:Float):Void
    {
        titleTime += elapsed;
        titleText.y = titleY + Math.sin(titleTime * titleSpeed) * titleAmplitude;
        
        updateTitleTrails(elapsed);
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