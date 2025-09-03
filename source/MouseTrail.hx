package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Graphics;
import openfl.geom.Matrix;
import openfl.filters.GlowFilter;
import openfl.filters.BlurFilter;
import utils.SettingsData;
import utils.TrailParticlePool;

/**
 * 无限粒子鼠标拖尾效果类
 * 粒子无限生成，自动内存管理，动态连接线
 */
class MouseTrail extends FlxGroup
{
    // 粒子列表（动态数组）
    private var trailParticles:Array<TrailParticle>;
    
    // 连接线精灵
    private var connectionLines:FlxSprite;
    
    // 鼠标位置历史记录
    private var mouseHistory:Array<{x:Float, y:Float}>;
    
    // 更新计时器
    private var updateTimer:Float = 0;
    private static inline var UPDATE_INTERVAL:Float = 0.0167; // 60fps更新频率 (1/60)
    
    // 粒子基础颜色 - 从设置中获取
    private var baseColor:FlxColor;
    private var currentColorName:String = "";
    
    // 粒子生成参数
    private var maxParticleSize:Int = 24;
    private var minParticleSize:Int = 4;
    private var particleLifespan:Float = 0.3; // 粒子生存时间（秒）
    private var maxParticleCount:Int = 35; // 最大粒子数量限制
    
    public function new()
    {
        super();
        
        trailParticles = [];
        mouseHistory = [];
        
        // 初始化颜色
        currentColorName = SettingsData.instance.mouseTrailColor;
        updateColors();
        
        // 创建连接线精灵
        connectionLines = new FlxSprite();
        connectionLines.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
        add(connectionLines);
        
        // 初始化鼠标历史位置
        for (i in 0...3)
        {
            mouseHistory.push({x: FlxG.mouse.x, y: FlxG.mouse.y});
        }
    }
    
    /**
     * 更新颜色配置
     */
    public function updateColors():Void {
        var colorName = SettingsData.instance.mouseTrailColor;
        var colorScheme = getColorScheme(colorName);
        baseColor = colorScheme;
        trace("MouseTrail: Base color updated to " + colorName + " (" + baseColor + ")");
    }
    
    /**
     * 根据颜色名称获取颜色
     */
    private function getColorScheme(colorName:String):FlxColor {
        switch (colorName.toLowerCase()) {
            case "blue":
                return FlxColor.fromRGB(100, 149, 237);
            case "red":
                return FlxColor.fromRGB(220, 20, 60);
            case "green":
                return FlxColor.fromRGB(50, 205, 50);
            case "purple":
                return FlxColor.fromRGB(138, 43, 226);
            case "orange":
                return FlxColor.fromRGB(255, 165, 0);
            case "cyan":
                return FlxColor.fromRGB(0, 255, 255);
            case "yellow":
                return FlxColor.fromRGB(255, 255, 0);
            case "white":
                return FlxColor.fromRGB(255, 255, 255);
            default:
                trace("MouseTrail: Unknown color " + colorName + ", using blue");
                return FlxColor.fromRGB(100, 149, 237);
        }
    }
    
    /**
     * 创建新的拖尾粒子（使用对象池）
     */
    private function createNewParticle(x:Float, y:Float, age:Float = 0.0):TrailParticle
    {
        var particle:TrailParticle;
        
        // 尝试从对象池获取粒子
        if (TrailParticlePool.instance != null)
        {
            particle = TrailParticlePool.instance.getParticle();
        }
        else
        {
            // 如果对象池未初始化，则直接创建
            particle = new TrailParticle();
        }
        
        // 设置粒子属性
        particle.x = x;
        particle.y = y;
        particle.age = age;
        particle.maxAge = particleLifespan;
        particle.size = maxParticleSize;
        particle.initialSize = maxParticleSize; // 记录初始大小
        particle.isDead = false;
        
        // 创建带发光效果的圆形
        createGlowParticleGraphic(particle, maxParticleSize);
        
        particle.visible = true;
        particle.blend = ADD; // 加法混合模式增强发光效果
        
        return particle;
    }
    
    /**
     * 为粒子创建发光图形
     */
    private function createGlowParticleGraphic(particle:TrailParticle, size:Int):Void
    {
        var bmd = new BitmapData(size + 20, size + 20, true, FlxColor.TRANSPARENT);
        var shape = new Shape();
        var g = shape.graphics;
        
        // 绘制发光圆形
        var centerX = (size + 20) / 2;
        var centerY = (size + 20) / 2;
        var radius = size / 2;
        
        // 外层发光
        var glowMatrix = new Matrix();
        glowMatrix.createGradientBox(size + 20, size + 20, 0, 0, 0);
        g.beginGradientFill(
            "radial",
            [baseColor.rgb, baseColor.rgb, FlxColor.TRANSPARENT],
            [0.3, 0.1, 0.0],
            [0, 128, 255],
            glowMatrix
        );
        g.drawCircle(centerX, centerY, radius + 10);
        g.endFill();
        
        // 内层亮核
        var coreMatrix = new Matrix();
        coreMatrix.createGradientBox(size, size, 0, 10, 10);
        g.beginGradientFill(
            "radial",
            [FlxColor.WHITE, baseColor.rgb],
            [0.8, 0.4],
            [0, 255],
            coreMatrix
        );
        g.drawCircle(centerX, centerY, radius);
        g.endFill();
        
        bmd.draw(shape);
        
        particle.loadGraphic(bmd);
        particle.size = size;
    }
    
    /**
     * 绘制连接线（三角形形状）
     */
    private function drawConnectionLines():Void
    {
        // 清空之前的连接线
        connectionLines.pixels.fillRect(connectionLines.pixels.rect, FlxColor.TRANSPARENT);
        
        // 绘制三角形连接线
        for (i in 0...(trailParticles.length - 1))
        {
            var p1 = trailParticles[i];
            var p2 = trailParticles[i + 1];
            
            if (p1 == null || p2 == null || !p1.visible || !p2.visible) continue;
            
            var x1 = p1.x + p1.width / 2;
            var y1 = p1.y + p1.height / 2;
            var x2 = p2.x + p2.width / 2;
            var y2 = p2.y + p2.height / 2;
            
            // 绘制三角形发光连接线，使用初始大小而不是当前大小
            drawTriangleGlowLine(x1, y1, x2, y2, p1.initialSize, p2.initialSize, Math.min(p1.alpha, p2.alpha));
        }
    }
    
    /**
     * 绘制三角形发光连接线
     * 顶点为后者粒子位置，底边宽度根据两粒子之间的距离自动调整
     */
    private function drawTriangleGlowLine(x1:Float, y1:Float, x2:Float, y2:Float, 
                                         size1:Int, size2:Int, alpha:Float):Void
    {
        var shape = new Shape();
        var g = shape.graphics;
        
        // 计算线条方向和垂直方向
        var dx = x2 - x1;
        var dy = y2 - y1;
        var length = Math.sqrt(dx * dx + dy * dy);
        
        if (length < 1) return; // 避免除零错误
        
        // 标准化方向向量
        var dirX = dx / length;
        var dirY = dy / length;
        
        // 垂直方向向量
        var perpX = -dirY;
        var perpY = dirX;
        
        // 根据两粒子之间的距离自动调整底边宽度
        // 距离越远，底边越宽；距离越近，底边越窄
        var distanceFactor = Math.min(length / 50, 2.0); // 限制最大倍数为2.0
        var baseHalfWidth = Math.max(2, (size1 / 8) * distanceFactor);
        
        // 三角形的三个顶点
        var apex = {x: x2, y: y2}; // 顶点：后者粒子位置
        var base1 = {x: x1 + perpX * baseHalfWidth, y: y1 + perpY * baseHalfWidth}; // 底边点1
        var base2 = {x: x1 - perpX * baseHalfWidth, y: y1 - perpY * baseHalfWidth}; // 底边点2
        
        // 绘制多层发光效果的三角形
        drawTriangleGlowLayer(g, apex, base1, base2, alpha, 3.0, FlxColor.WHITE, 0.15); // 最外层白色光晕
        drawTriangleGlowLayer(g, apex, base1, base2, alpha, 2.0, baseColor.rgb, 0.3); // 中层彩色光晕
        drawTriangleGlowLayer(g, apex, base1, base2, alpha, 1.0, FlxColor.WHITE, 0.6); // 内层白色核心
        
        connectionLines.pixels.draw(shape);
    }
    
    /**
     * 绘制单层三角形发光效果
     */
    private function drawTriangleGlowLayer(g:Graphics, apex:{x:Float, y:Float}, base1:{x:Float, y:Float}, base2:{x:Float, y:Float},
                                          alpha:Float, glowScale:Float, color:Int, glowAlpha:Float):Void
    {
        // 计算扩展后的三角形顶点（用于发光效果）
        var centerX = (apex.x + base1.x + base2.x) / 3;
        var centerY = (apex.y + base1.y + base2.y) / 3;
        
        // 从中心向外扩展各顶点
        var expandedApex = {
            x: centerX + (apex.x - centerX) * glowScale,
            y: centerY + (apex.y - centerY) * glowScale
        };
        var expandedBase1 = {
            x: centerX + (base1.x - centerX) * glowScale,
            y: centerY + (base1.y - centerY) * glowScale
        };
        var expandedBase2 = {
            x: centerX + (base2.x - centerX) * glowScale,
            y: centerY + (base2.y - centerY) * glowScale
        };
        
        // 绘制三角形
        g.beginFill(color, alpha * glowAlpha);
        g.moveTo(expandedApex.x, expandedApex.y);
        g.lineTo(expandedBase1.x, expandedBase1.y);
        g.lineTo(expandedBase2.x, expandedBase2.y);
        g.lineTo(expandedApex.x, expandedApex.y);
        g.endFill();
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 检查是否启用鼠标拖尾
        var enabled = SettingsData.instance.mouseTrailEnabled;
        
        if (!enabled) {
            visible = false;
            return;
        } else {
            visible = true;
            // 只在颜色改变时更新
            var newColorName = SettingsData.instance.mouseTrailColor;
            if (newColorName != currentColorName) {
                trace("MouseTrail: Color changed from " + currentColorName + " to " + newColorName);
                currentColorName = newColorName;
                updateColors();
            }
        }
        
        updateTimer += elapsed;
        
        // 60FPS更新频率
        if (updateTimer >= UPDATE_INTERVAL)
        {
            updateTimer = 0;
            
            // 更新鼠标历史位置
            updateMouseHistory();
            
            // 生成新粒子（限制数量）
            generateParticle();
            
            // 更新所有粒子
            updateParticles(UPDATE_INTERVAL);
            
            // 绘制连接线
            drawConnectionLines();
            
            // 清理过期粒子
            cleanupParticles();
            
            // 限制粒子数量
            limitParticleCount();
        }
    }
    
    /**
     * 更新鼠标历史位置
     */
    private function updateMouseHistory():Void
    {
        // 添加当前鼠标位置到历史记录开头
        mouseHistory.unshift({x: FlxG.mouse.x, y: FlxG.mouse.y});
        
        // 保持历史记录长度为3
        if (mouseHistory.length > 3)
        {
            mouseHistory.pop();
        }
    }
    
    /**
     * 生成新粒子
     */
    private function generateParticle():Void
    {
        // 检查鼠标是否移动
        if (mouseHistory.length >= 2)
        {
            var current = mouseHistory[0];
            var previous = mouseHistory[1];
            var distance = Math.sqrt(Math.pow(current.x - previous.x, 2) + Math.pow(current.y - previous.y, 2));
            
            // 只有当鼠标移动距离超过阈值时才生成粒子
            if (distance > 2)
            {
                var particle = createNewParticle(current.x, current.y);
                trailParticles.unshift(particle); // 添加到数组开头
                add(particle);
            }
        }
    }
    
    /**
     * 更新所有粒子
     */
    private function updateParticles(elapsed:Float):Void
    {
        for (particle in trailParticles)
        {
            if (particle == null) continue;
            
            // 更新粒子年龄
            particle.age += elapsed;
            
            // 计算生命周期进度 (0.0 到 1.0)
            var lifeProgress = particle.age / particle.maxAge;
            
            // 更新透明度 (从1.0渐变到0.0)
            particle.alpha = 1.0 - lifeProgress;
            
            // 更新大小 (从最大尺寸渐变到最小尺寸)
            var newSize = Std.int(maxParticleSize - (maxParticleSize - minParticleSize) * lifeProgress);
            if (newSize != particle.size && newSize >= minParticleSize)
            {
                particle.size = newSize;
                createGlowParticleGraphic(particle, newSize);
                // 重新居中粒子
                particle.x = particle.x + (particle.width - (newSize + 20)) / 2;
                particle.y = particle.y + (particle.height - (newSize + 20)) / 2;
            }
            
            // 标记完全透明的粒子为不可见
            if (particle.alpha <= 0.01)
            {
                particle.visible = false;
                particle.isDead = true;
            }
        }
    }
    
    /**
     * 清理过期粒子（使用对象池回收）
     */
    private function cleanupParticles():Void
    {
        var i = trailParticles.length - 1;
        while (i >= 0)
        {
            var particle = trailParticles[i];
            if (particle != null && particle.isDead)
            {
                // 从组中移除
                remove(particle);
                
                // 回收到对象池而不是销毁
                if (TrailParticlePool.instance != null)
                {
                    TrailParticlePool.instance.returnParticle(particle);
                }
                else
                {
                    // 如果对象池不可用，则销毁
                    particle.destroy();
                }
                
                // 从数组中移除
                trailParticles.splice(i, 1);
            }
            i--;
        }
    }
    
    /**
     * 限制粒子数量（使用对象池回收）
     */
    private function limitParticleCount():Void
    {
        while (trailParticles.length > maxParticleCount)
        {
            // 移除最老的粒子（数组末尾）
            var oldestParticle = trailParticles.pop();
            if (oldestParticle != null)
            {
                remove(oldestParticle);
                
                // 回收到对象池
                if (TrailParticlePool.instance != null)
                {
                    TrailParticlePool.instance.returnParticle(oldestParticle);
                }
                else
                {
                    oldestParticle.destroy();
                }
            }
        }
        
        if (trailParticles.length > maxParticleCount * 0.8)
        {
            trace("MouseTrail: Particle count = " + trailParticles.length + "/" + maxParticleCount);
            
            // 输出对象池状态
            if (TrailParticlePool.instance != null)
            {
                var stats = TrailParticlePool.instance.getPoolStats();
                trace("MouseTrail: Pool stats - Available: " + stats.available + 
                      ", Utilization: " + Std.int(stats.utilizationRate * 100) + "%");
            }
        }
    }
    
    /**
     * 设置拖尾是否启用
     */
    public function setEnabled(enabled:Bool):Void
    {
        visible = enabled;
        active = enabled;
        
        if (!enabled)
        {
            // 隐藏所有粒子和连接线
            for (particle in trailParticles)
            {
                if (particle != null)
                {
                    particle.visible = false;
                }
            }
            connectionLines.visible = false;
        }
        else
        {
            connectionLines.visible = true;
        }
    }
    
    /**
     * 设置拖尾颜色
     */
    public function setTrailColor(newColor:FlxColor):Void
    {
        baseColor = newColor;
        
        // 重新创建所有现有粒子的图形
        for (particle in trailParticles)
        {
            if (particle != null && particle.visible)
            {
                createGlowParticleGraphic(particle, particle.size);
            }
        }
    }
    
    override public function destroy():Void
    {
        if (connectionLines != null)
        {
            connectionLines.destroy();
            connectionLines = null;
        }
        
        // 清理所有粒子（回收到对象池）
        if (trailParticles != null)
        {
            for (particle in trailParticles)
            {
                if (particle != null)
                {
                    if (TrailParticlePool.instance != null)
                    {
                        TrailParticlePool.instance.returnParticle(particle);
                    }
                    else
                    {
                        particle.destroy();
                    }
                }
            }
            trailParticles = null;
        }
        
        mouseHistory = null;
        
        super.destroy();
    }
}

// TrailParticle类现在在TrailParticlePool.hx中定义
// 这里不再需要重复定义