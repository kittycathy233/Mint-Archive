package debug;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxAssets.FlxShader;

class MouseTrail extends FlxSpriteGroup
{
    private var trailPoints:Array<{x:Float, y:Float, time:Float, sprite:FlxSprite}>;
    private var maxTrailLength:Int;
    private var pointSprites:Array<FlxSprite>;
    private var lineSprites:Array<FlxSprite>;
    private var lastMousePos:FlxPoint;
    private var glowShader:GlowShader;
    
    // 配置参数
    public var pointSize:Int = 15;
    public var pointColor:FlxColor = FlxColor.WHITE;
    public var lineColor:FlxColor = FlxColor.fromRGB(255, 255, 255, 100);
    public var lineThickness:Int = 3;
    public var glowIntensity:Float = 2.0;
    public var glowColor:FlxColor = FlxColor.fromRGB(150, 200, 255, 200);
    public var spawnInterval:Float = 0.05; // 生成新点的间隔（秒）
    private var spawnTimer:Float = 0;
    
    public function new(maxLength:Int = 20)
    {
        super();
        
        maxTrailLength = maxLength;
        trailPoints = [];
        pointSprites = [];
        lineSprites = [];
        lastMousePos = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
        
        // 创建发光Shader
        glowShader = new GlowShader();
        glowShader.glowColor.value = [glowColor.redFloat, glowColor.greenFloat, glowColor.blueFloat];
        glowShader.intensity.value = [glowIntensity];
        
        // 确保拖尾效果在UI之上
        scrollFactor.set(0, 0);
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        spawnTimer += elapsed;
        
        // 检查鼠标是否移动并且达到生成间隔
        if ((FlxG.mouse.x != lastMousePos.x || FlxG.mouse.y != lastMousePos.y) && spawnTimer >= spawnInterval)
        {
            spawnTimer = 0;
            
            // 更新当前位置
            lastMousePos.set(FlxG.mouse.x, FlxG.mouse.y);
            
            // 添加新点
            addTrailPoint(FlxG.mouse.x, FlxG.mouse.y);
            
            // 更新连线
            updateLines();
        }
        
        // 更新点透明度
        updatePoints(elapsed);
    }
    
    private function addTrailPoint(x:Float, y:Float):Void
    {
        // 创建新点精灵
        var pointSprite = new FlxSprite(x - pointSize/2, y - pointSize/2);
        pointSprite.makeGraphic(pointSize, pointSize, pointColor);
        pointSprite.shader = glowShader;
        pointSprite.alpha = 0.8;
        add(pointSprite);
        
        // 添加到点列表
        var newPoint = {
            x: x,
            y: y,
            time: 0.0,
            sprite: pointSprite
        };
        
        trailPoints.unshift(newPoint);
        pointSprites.push(pointSprite);
        
        // 如果超过最大长度，移除最旧的点
        if (trailPoints.length > maxTrailLength)
        {
            var oldestPoint = trailPoints.pop();
            remove(oldestPoint.sprite);
            oldestPoint.sprite.destroy();
        }
    }
    
    private function updateLines():Void
    {
        // 清除所有旧连线
        for (line in lineSprites)
        {
            remove(line);
            line.destroy();
        }
        lineSprites = [];
        
        // 创建新连线（连接相邻的点）
        for (i in 0...trailPoints.length - 1)
        {
            var point1 = trailPoints[i];
            var point2 = trailPoints[i + 1];
            
            // 计算两点之间的距离和角度
            var dx = point2.x - point1.x;
            var dy = point2.y - point1.y;
            var distance = Math.sqrt(dx * dx + dy * dy);
            var angle = Math.atan2(dy, dx) * 180 / Math.PI;
            
            // 确保距离至少为1像素，避免创建0宽度的图形
            var lineWidth = Std.int(Math.max(1, distance));
            
            // 创建连线精灵
            var line = new FlxSprite(point1.x, point1.y - lineThickness/2);
            line.makeGraphic(lineWidth, lineThickness, lineColor);
            line.angle = angle;
            line.shader = glowShader;
            
            // 根据距离和点的新旧程度设置透明度
            var alpha = 0.7 * (1 - i / trailPoints.length);
            line.alpha = alpha;
            
            add(line);
            lineSprites.push(line);
        }
    }
    
    private function updatePoints(elapsed:Float):Void
    {
        // 更新所有点的时间并设置透明度
        for (i in 0...trailPoints.length)
        {
            var point = trailPoints[i];
            point.time += elapsed;
            
            // 根据时间设置透明度（越旧的点越透明）
            var alpha = 0.8 * (1 - point.time / (maxTrailLength * spawnInterval));
            point.sprite.alpha = alpha;
            
            // 根据点的新旧程度调整大小
            var scale = 1.0 - 0.5 * (i / trailPoints.length);
            point.sprite.scale.set(scale, scale);
            point.sprite.updateHitbox();
        }
    }
    
    override public function destroy():Void
    {
        super.destroy();
        lastMousePos.put();
        
        for (point in trailPoints)
        {
            if (point.sprite != null)
                point.sprite.destroy();
        }
        
        for (line in lineSprites)
        {
            line.destroy();
        }
        
        trailPoints = null;
        pointSprites = null;
        lineSprites = null;
    }
}

// 发光Shader类
class GlowShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header
        
        uniform vec3 glowColor;
        uniform float intensity;
        
        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            vec3 glow = glowColor * intensity * color.a;
            gl_FragColor = vec4(color.rgb + glow, color.a);
        }
    ')
    
    public function new()
    {
        super();
        glowColor.value = [1.0, 1.0, 1.0];
        intensity.value = [1.0];
    }
}