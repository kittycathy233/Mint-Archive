package objects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;
import openfl.display.GradientType;
import openfl.display.SpreadMethod;
import openfl.display.InterpolationMethod;

/**
 * 多样式自定义音量滑块组件
 * 支持多种视觉风格和交互方式
 */
class CustomVolumeSlider extends FlxGroup
{
    // 滑块样式枚举
    public static inline var STYLE_MODERN:String = "modern";
    public static inline var STYLE_RETRO:String = "retro";
    public static inline var STYLE_NEON:String = "neon";
    public static inline var STYLE_MINIMAL:String = "minimal";
    public static inline var STYLE_GAMING:String = "gaming";
    
    // 基本属性
    public var sliderWidth:Float;
    public var sliderHeight:Float;
    public var x:Float;
    public var y:Float;
    public var style:String;
    
    // 音量值 (0.0 - 1.0)
    private var _volume:Float = 0.5;
    public var volume(get, set):Float;
    
    // 视觉组件
    private var background:FlxSprite;
    private var track:FlxSprite;
    private var fill:FlxSprite;
    private var handle:FlxSprite;
    private var volumeText:FlxText;
    private var glowEffect:FlxSprite;
    
    // 交互状态
    private var isDragging:Bool = false;
    private var isHovered:Bool = false;
    
    // 回调函数
    public var onVolumeChange:Float->Void;
    
    // 样式配置
    private var styleConfig:Dynamic;
    
    public function new(x:Float = 0, y:Float = 0, width:Float = 200, height:Float = 30, style:String = STYLE_MODERN)
    {
        super();
        
        this.x = x;
        this.y = y;
        this.sliderWidth = width;
        this.sliderHeight = height;
        this.style = style;
        
        setupStyleConfig();
        createComponents();
        updateVisuals();
    }
    
    private function setupStyleConfig():Void
    {
        switch (style)
        {
            case STYLE_MODERN:
                styleConfig = {
                    bgColor: 0xFF2C2C2C,
                    trackColor: 0xFF404040,
                    fillColor: 0xFF0078D4,
                    fillColorEnd: 0xFF106EBE,
                    handleColor: 0xFFFFFFFF,
                    textColor: 0xFFFFFFFF,
                    glowColor: 0xFF0078D4,
                    handleSize: 20,
                    trackHeight: 6,
                    useGlow: true,
                    useGradient: true
                };
                
            case STYLE_RETRO:
                styleConfig = {
                    bgColor: 0xFF8B4513,
                    trackColor: 0xFF654321,
                    fillColor: 0xFFFFD700,
                    fillColorEnd: 0xFFFFA500,
                    handleColor: 0xFFFFD700,
                    textColor: 0xFFFFD700,
                    glowColor: 0xFFFFD700,
                    handleSize: 16,
                    trackHeight: 8,
                    useGlow: false,
                    useGradient: true
                };
                
            case STYLE_NEON:
                styleConfig = {
                    bgColor: 0xFF000000,
                    trackColor: 0xFF1A1A1A,
                    fillColor: 0xFF00FFFF,
                    fillColorEnd: 0xFFFF00FF,
                    handleColor: 0xFFFFFFFF,
                    textColor: 0xFF00FFFF,
                    glowColor: 0xFF00FFFF,
                    handleSize: 18,
                    trackHeight: 4,
                    useGlow: true,
                    useGradient: true
                };
                
            case STYLE_MINIMAL:
                styleConfig = {
                    bgColor: 0x00000000,
                    trackColor: 0xFFE0E0E0,
                    fillColor: 0xFF333333,
                    fillColorEnd: 0xFF333333,
                    handleColor: 0xFF333333,
                    textColor: 0xFF333333,
                    glowColor: 0xFF333333,
                    handleSize: 14,
                    trackHeight: 2,
                    useGlow: false,
                    useGradient: false
                };
                
            case STYLE_GAMING:
                styleConfig = {
                    bgColor: 0xFF1E1E1E,
                    trackColor: 0xFF333333,
                    fillColor: 0xFF00FF41,
                    fillColorEnd: 0xFF00CC33,
                    handleColor: 0xFF00FF41,
                    textColor: 0xFF00FF41,
                    glowColor: 0xFF00FF41,
                    handleSize: 22,
                    trackHeight: 8,
                    useGlow: true,
                    useGradient: true
                };
                
            default:
                setupStyleConfig(); // 默认使用现代风格
                return;
        }
    }
    
    private function createComponents():Void
    {
        // 创建背景
        background = new FlxSprite(x, y);
        add(background);
        
        // 创建轨道
        track = new FlxSprite(x, y + (sliderHeight - styleConfig.trackHeight) / 2);
        add(track);
        
        // 创建填充
        fill = new FlxSprite(x, y + (sliderHeight - styleConfig.trackHeight) / 2);
        add(fill);
        
        // 创建发光效果
        if (styleConfig.useGlow)
        {
            glowEffect = new FlxSprite();
            glowEffect.alpha = 0.6;
            add(glowEffect);
        }
        
        // 创建滑块手柄
        handle = new FlxSprite();
        add(handle);
        
        // 创建音量文本
        volumeText = new FlxText(x, y - 25, sliderWidth, "50%", 14);
        volumeText.setFormat(null, 14, styleConfig.textColor, CENTER);
        add(volumeText);
    }
    
    private function createRoundedRect(width:Float, height:Float, color:FlxColor, radius:Float = 0):BitmapData
    {
        var bmd = new BitmapData(Std.int(width), Std.int(height), true, 0x00000000);
        var shape = new Shape();
        
        shape.graphics.beginFill(color);
        if (radius > 0)
        {
            shape.graphics.drawRoundRect(0, 0, width, height, radius, radius);
        }
        else
        {
            shape.graphics.drawRect(0, 0, width, height);
        }
        shape.graphics.endFill();
        
        bmd.draw(shape);
        return bmd;
    }
    
    private function createGradientRect(width:Float, height:Float, startColor:FlxColor, endColor:FlxColor, radius:Float = 0):BitmapData
    {
        var bmd = new BitmapData(Std.int(width), Std.int(height), true, 0x00000000);
        var shape = new Shape();
        
        var matrix = new Matrix();
        matrix.createGradientBox(width, height, 0, 0, 0);
        
        shape.graphics.beginGradientFill(
            GradientType.LINEAR,
            [startColor, endColor],
            [1.0, 1.0],
            [0, 255],
            matrix,
            SpreadMethod.PAD,
            InterpolationMethod.RGB
        );
        
        if (radius > 0)
        {
            shape.graphics.drawRoundRect(0, 0, width, height, radius, radius);
        }
        else
        {
            shape.graphics.drawRect(0, 0, width, height);
        }
        shape.graphics.endFill();
        
        bmd.draw(shape);
        return bmd;
    }
    
    private function createCircle(radius:Float, color:FlxColor):BitmapData
    {
        var size = Std.int(radius * 2);
        var bmd = new BitmapData(size, size, true, 0x00000000);
        var shape = new Shape();
        
        shape.graphics.beginFill(color);
        shape.graphics.drawCircle(radius, radius, radius);
        shape.graphics.endFill();
        
        bmd.draw(shape);
        return bmd;
    }
    
    private function updateVisuals():Void
    {
        var trackRadius = styleConfig.trackHeight / 2;
        var handleRadius = styleConfig.handleSize / 2;
        
        // 更新背景
        if (styleConfig.bgColor != 0x00000000)
        {
            var bgBmd = createRoundedRect(sliderWidth, sliderHeight, styleConfig.bgColor, 4);
            background.loadGraphic(bgBmd);
        }
        else
        {
            background.visible = false;
        }
        
        // 更新轨道
        var trackBmd = createRoundedRect(sliderWidth, styleConfig.trackHeight, styleConfig.trackColor, trackRadius);
        track.loadGraphic(trackBmd);
        
        // 更新填充
        var fillWidth = sliderWidth * _volume;
        if (fillWidth > 0)
        {
            var fillBmd:BitmapData;
            if (styleConfig.useGradient)
            {
                fillBmd = createGradientRect(fillWidth, styleConfig.trackHeight, styleConfig.fillColor, styleConfig.fillColorEnd, trackRadius);
            }
            else
            {
                fillBmd = createRoundedRect(fillWidth, styleConfig.trackHeight, styleConfig.fillColor, trackRadius);
            }
            fill.loadGraphic(fillBmd);
            fill.visible = true;
        }
        else
        {
            fill.visible = false;
        }
        
        // 更新发光效果
        if (styleConfig.useGlow && glowEffect != null && _volume > 0)
        {
            var glowBmd = createRoundedRect(fillWidth + 4, styleConfig.trackHeight + 4, styleConfig.glowColor, trackRadius + 2);
            glowEffect.loadGraphic(glowBmd);
            glowEffect.x = fill.x - 2;
            glowEffect.y = fill.y - 2;
            glowEffect.visible = true;
        }
        else if (glowEffect != null)
        {
            glowEffect.visible = false;
        }
        
        // 更新手柄
        var handleBmd = createCircle(handleRadius, styleConfig.handleColor);
        handle.loadGraphic(handleBmd);
        handle.x = x + (sliderWidth * _volume) - handleRadius;
        handle.y = y + (sliderHeight - styleConfig.handleSize) / 2;
        
        // 更新文本
        volumeText.text = Std.int(_volume * 100) + "%";
        volumeText.color = styleConfig.textColor;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        #if desktop
        var mouseX = FlxG.mouse.x;
        var mouseY = FlxG.mouse.y;
        
        // 检查鼠标是否在滑块区域内
        var inBounds = mouseX >= x && mouseX <= x + sliderWidth && 
                      mouseY >= y && mouseY <= y + sliderHeight;
        
        // 更新悬停状态
        if (inBounds && !isHovered)
        {
            isHovered = true;
            onHoverEnter();
        }
        else if (!inBounds && isHovered)
        {
            isHovered = false;
            onHoverExit();
        }
        
        // 处理拖拽
        if (FlxG.mouse.justPressed && inBounds)
        {
            isDragging = true;
            updateVolumeFromMouse(mouseX);
        }
        
        if (isDragging)
        {
            if (FlxG.mouse.pressed)
            {
                updateVolumeFromMouse(mouseX);
            }
            else
            {
                isDragging = false;
            }
        }
        #end
    }
    
    private function updateVolumeFromMouse(mouseX:Float):Void
    {
        var relativeX = mouseX - x;
        var newVolume = FlxMath.bound(relativeX / sliderWidth, 0, 1);
        setVolume(newVolume);
    }
    
    private function onHoverEnter():Void
    {
        if (styleConfig.useGlow && glowEffect != null)
        {
            FlxTween.tween(glowEffect, {alpha: 0.8}, 0.2, {ease: FlxEase.quadOut});
        }
        FlxTween.tween(handle, {"scale.x": 1.1, "scale.y": 1.1}, 0.2, {ease: FlxEase.quadOut});
    }
    
    private function onHoverExit():Void
    {
        if (styleConfig.useGlow && glowEffect != null)
        {
            FlxTween.tween(glowEffect, {alpha: 0.6}, 0.2, {ease: FlxEase.quadOut});
        }
        FlxTween.tween(handle, {"scale.x": 1.0, "scale.y": 1.0}, 0.2, {ease: FlxEase.quadOut});
    }
    
    public function setVolume(value:Float, triggerCallback:Bool = true):Void
    {
        _volume = FlxMath.bound(value, 0, 1);
        updateVisuals();
        
        if (triggerCallback && onVolumeChange != null)
        {
            onVolumeChange(_volume);
        }
    }
    
    public function setPosition(newX:Float, newY:Float):Void
    {
        x = newX;
        y = newY;
        
        background.x = x;
        background.y = y;
        track.x = x;
        track.y = y + (sliderHeight - styleConfig.trackHeight) / 2;
        fill.x = x;
        fill.y = y + (sliderHeight - styleConfig.trackHeight) / 2;
        
        volumeText.x = x;
        volumeText.y = y - 25;
        volumeText.fieldWidth = sliderWidth;
        
        updateVisuals();
    }
    
    public function setStyle(newStyle:String):Void
    {
        style = newStyle;
        setupStyleConfig();
        updateVisuals();
    }
    
    private function get_volume():Float
    {
        return _volume;
    }
    
    private function set_volume(value:Float):Float
    {
        setVolume(value, false);
        return _volume;
    }
}