package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;
import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;

/**
 * 高度自定义的平行四边形进度条组件
 * 支持渐变色、动画效果、自定义形状等
 */
class CustomProgressBar extends FlxGroup
{
    // 进度条尺寸和位置
    public var barWidth:Float;
    public var barHeight:Float;
    public var x:Float;
    public var y:Float;
    
    // 平行四边形倾斜角度（度数）
    public var skewAngle:Float = 15;
    
    // 进度值 (0.0 - 1.0)
    private var _progress:Float = 0;
    public var progress(get, set):Float;
    
    // 视觉组件
    private var background:FlxSprite;
    private var progressFill:FlxSprite;
    private var progressText:FlxText;
    private var glowEffect:FlxSprite;
    
    // 颜色配置
    public var backgroundColor:FlxColor = 0x80404040; // 深灰50%透明
    public var progressColor:FlxColor = 0xFF87CEEB; // 天蓝色
    public var progressColorEnd:FlxColor = 0xFF4169E1; // 皇家蓝
    public var textColor:FlxColor = FlxColor.WHITE;
    public var glowColor:FlxColor = 0xFF87CEEB;
    
    // 动画配置
    public var animationDuration:Float = 0.5;
    public var useGlowEffect:Bool = true;
    public var useTextDisplay:Bool = true;
    
    // 文本格式
    public var textSize:Int = 16;
    public var textFormat:String = "{progress}%";
    
    private var currentTween:FlxTween;
    
    public function new(x:Float = 0, y:Float = 0, width:Float = 300, height:Float = 20)
    {
        super();
        
        this.x = x;
        this.y = y;
        this.barWidth = width;
        this.barHeight = height;
        
        createComponents();
        updateVisuals();
    }
    
    private function createComponents():Void
    {
        // 创建背景
        background = new FlxSprite(x, y);
        add(background);
        
        // 创建进度填充
        progressFill = new FlxSprite(x, y);
        add(progressFill);
        
        // 创建发光效果
        if (useGlowEffect)
        {
            glowEffect = new FlxSprite(x, y);
            glowEffect.alpha = 0.6;
            add(glowEffect);
        }
        
        // 创建文本
        if (useTextDisplay)
        {
            progressText = new FlxText(x, y, barWidth, "0%", textSize);
            progressText.setFormat(null, textSize, textColor, CENTER);
            progressText.y = y + (barHeight - progressText.height) / 2;
            add(progressText);
        }
    }
    
    private function createParallelogramShape(width:Float, height:Float, color:FlxColor, isGradient:Bool = false):BitmapData
    {
        var bmd = new BitmapData(Std.int(width + Math.abs(height * Math.tan(skewAngle * Math.PI / 180))), Std.int(height), true, 0x00000000);
        var shape = new Shape();
        
        // 计算平行四边形的顶点
        var skewOffset = height * Math.tan(skewAngle * Math.PI / 180);
        
        if (isGradient)
        {
            // 创建渐变填充
            var matrix = new Matrix();
            matrix.createGradientBox(width, height, 0, 0, 0);
            
            shape.graphics.beginGradientFill(
                GradientType.LINEAR,
                [progressColor, progressColorEnd],
                [1.0, 1.0],
                [0, 255],
                matrix,
                SpreadMethod.PAD,
                InterpolationMethod.RGB
            );
        }
        else
        {
            shape.graphics.beginFill(color);
        }
        
        // 绘制平行四边形
        shape.graphics.moveTo(Math.abs(skewOffset), 0);
        shape.graphics.lineTo(width + Math.abs(skewOffset), 0);
        shape.graphics.lineTo(width, height);
        shape.graphics.lineTo(0, height);
        shape.graphics.lineTo(Math.abs(skewOffset), 0);
        shape.graphics.endFill();
        
        bmd.draw(shape);
        return bmd;
    }
    
    private function updateVisuals():Void
    {
        // 更新背景
        var bgBmd = createParallelogramShape(barWidth, barHeight, backgroundColor);
        background.loadGraphic(bgBmd);
        
        // 更新进度填充
        var fillWidth = barWidth * _progress;
        if (fillWidth > 0)
        {
            var fillBmd = createParallelogramShape(fillWidth, barHeight, progressColor, true);
            progressFill.loadGraphic(fillBmd);
            progressFill.visible = true;
        }
        else
        {
            progressFill.visible = false;
        }
        
        // 更新发光效果
        if (useGlowEffect && glowEffect != null && _progress > 0)
        {
            var glowBmd = createParallelogramShape(fillWidth + 4, barHeight + 4, glowColor);
            glowEffect.loadGraphic(glowBmd);
            glowEffect.x = x - 2;
            glowEffect.y = y - 2;
            glowEffect.visible = true;
            
            // 发光脉冲动画
            if (currentTween != null) currentTween.cancel();
            currentTween = FlxTween.tween(glowEffect, {alpha: 0.3}, 1.0, {
                type: FlxTweenType.PINGPONG,
                ease: FlxEase.sineInOut
            });
        }
        else if (glowEffect != null)
        {
            glowEffect.visible = false;
        }
        
        // 更新文本
        if (useTextDisplay && progressText != null)
        {
            var displayText = textFormat.split("{progress}").join(Std.string(Std.int(_progress * 100)));
            progressText.text = displayText;
            progressText.x = x + (barWidth - progressText.width) / 2;
        }
    }
    
    public function setProgress(value:Float, animated:Bool = true):Void
    {
        value = Math.max(0, Math.min(1, value));
        
        if (animated && animationDuration > 0)
        {
            if (currentTween != null) currentTween.cancel();
            currentTween = FlxTween.tween(this, {_progress: value}, animationDuration, {
                ease: FlxEase.quadOut,
                onUpdate: function(tween:FlxTween) {
                    updateVisuals();
                },
                onComplete: function(tween:FlxTween) {
                    currentTween = null;
                }
            });
        }
        else
        {
            _progress = value;
            updateVisuals();
        }
    }
    
    public function setPosition(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
        
        background.x = x;
        background.y = y;
        progressFill.x = x;
        progressFill.y = y;
        
        if (glowEffect != null)
        {
            glowEffect.x = x - 2;
            glowEffect.y = y - 2;
        }
        
        if (progressText != null)
        {
            progressText.x = x + (barWidth - progressText.width) / 2;
            progressText.y = y + (barHeight - progressText.height) / 2;
        }
    }
    
    public function setSize(width:Float, height:Float):Void
    {
        barWidth = width;
        barHeight = height;
        updateVisuals();
        
        if (progressText != null)
        {
            progressText.fieldWidth = barWidth;
            progressText.x = x + (barWidth - progressText.width) / 2;
            progressText.y = y + (barHeight - progressText.height) / 2;
        }
    }
    
    // 设置自定义颜色主题
    public function setColorTheme(bgColor:FlxColor, startColor:FlxColor, endColor:FlxColor, ?txtColor:FlxColor):Void
    {
        backgroundColor = bgColor;
        progressColor = startColor;
        progressColorEnd = endColor;
        if (txtColor != null) textColor = txtColor;
        
        if (progressText != null)
            progressText.color = textColor;
            
        updateVisuals();
    }
    
    // 设置倾斜角度
    public function setSkewAngle(angle:Float):Void
    {
        skewAngle = angle;
        updateVisuals();
    }
    
    private function get_progress():Float
    {
        return _progress;
    }
    
    private function set_progress(value:Float):Float
    {
        setProgress(value, false);
        return _progress;
    }
    
    override public function destroy():Void
    {
        if (currentTween != null)
        {
            currentTween.cancel();
            currentTween = null;
        }
        
        super.destroy();
    }
}