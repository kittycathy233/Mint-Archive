package starling.mouse;

import starling.display.Sprite;
import starling.display.Quad;
import starling.core.Starling;
import starling.events.Event;
import starling.animation.Tween;
import starling.animation.Transitions;
import openfl.geom.Point;

/**
 * Starling 版本的鼠标拖尾效果
 * 提供平滑的粒子拖尾效果
 */
class MouseTrail extends Sprite {
    private var particles:Array<TrailParticle>;
    private var maxParticles:Int = 50;
    private var trailColor:UInt = 0xFFFFFF;
    private var isEnabled:Bool = true;
    
    private var lastMousePos:Point;
    private var mouseVelocity:Point;
    
    public function new() {
        super();
        
        particles = [];
        lastMousePos = new Point();
        mouseVelocity = new Point();
        
        // 监听每帧更新
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        
        trace("StarlingMouseTrail: Initialized with " + maxParticles + " max particles");
    }
    
    private function onEnterFrame(event:Event):Void {
        if (!isEnabled || !visible) return;
        
        var mouseX = Starling.current.nativeStage.mouseX;
        var mouseY = Starling.current.nativeStage.mouseY;
        
        // 计算鼠标速度
        mouseVelocity.x = mouseX - lastMousePos.x;
        mouseVelocity.y = mouseY - lastMousePos.y;
        
        // 只有当鼠标移动时才创建粒子
        var speed = Math.sqrt(mouseVelocity.x * mouseVelocity.x + mouseVelocity.y * mouseVelocity.y);
        if (speed > 2) {
            createParticle(mouseX, mouseY, speed);
        }
        
        // 更新所有粒子
        updateParticles();
        
        // 记录当前鼠标位置
        lastMousePos.x = mouseX;
        lastMousePos.y = mouseY;
    }
    
    private function createParticle(x:Float, y:Float, speed:Float):Void {
        // 如果粒子数量达到上限，移除最老的粒子
        if (particles.length >= maxParticles) {
            var oldParticle = particles.shift();
            if (oldParticle != null) {
                oldParticle.dispose();
                removeChild(oldParticle.quad);
            }
        }
        
        // 创建新粒子
        var particle = new TrailParticle();
        particle.quad = new Quad(8, 8, trailColor);
        particle.quad.x = x - 4;
        particle.quad.y = y - 4;
        particle.quad.alpha = 0.8;
        
        // 根据速度调整粒子大小
        var scale = Math.min(1.0, speed / 20.0);
        particle.quad.scaleX = particle.quad.scaleY = 0.5 + scale * 0.5;
        
        particle.life = 1.0;
        particle.maxLife = 1.0;
        particle.velocityX = mouseVelocity.x * 0.1;
        particle.velocityY = mouseVelocity.y * 0.1;
        
        addChild(particle.quad);
        particles.push(particle);
    }
    
    private function updateParticles():Void {
        var i = particles.length - 1;
        while (i >= 0) {
            var particle = particles[i];
            
            // 更新粒子生命周期
            particle.life -= 0.02;
            
            // 更新粒子位置
            particle.quad.x += particle.velocityX;
            particle.quad.y += particle.velocityY;
            
            // 应用阻力
            particle.velocityX *= 0.95;
            particle.velocityY *= 0.95;
            
            // 更新透明度和大小
            var lifeRatio = particle.life / particle.maxLife;
            particle.quad.alpha = lifeRatio * 0.8;
            particle.quad.scaleX = particle.quad.scaleY = lifeRatio;
            
            // 移除死亡的粒子
            if (particle.life <= 0) {
                particle.dispose();
                removeChild(particle.quad);
                particles.splice(i, 1);
            }
            
            i--;
        }
    }
    
    /**
     * 设置拖尾颜色
     */
    public function setTrailColor(color:UInt):Void {
        trailColor = color;
        
        // 更新现有粒子的颜色
        for (particle in particles) {
            particle.quad.color = color;
        }
        
        trace("StarlingMouseTrail: Color changed to 0x" + StringTools.hex(color, 6));
    }
    
    /**
     * 启用或禁用拖尾效果
     */
    public function setEnabled(enabled:Bool):Void {
        isEnabled = enabled;
        visible = enabled;
        
        if (!enabled) {
            clearAllParticles();
        }
        
        trace("StarlingMouseTrail: " + (enabled ? "Enabled" : "Disabled"));
    }
    
    /**
     * 清除所有粒子
     */
    private function clearAllParticles():Void {
        for (particle in particles) {
            particle.dispose();
            removeChild(particle.quad);
        }
        particles = [];
    }
    
    /**
     * 获取当前粒子数量
     */
    public function getParticleCount():Int {
        return particles.length;
    }
    
    public override function dispose():Void {
        removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        clearAllParticles();
        super.dispose();
    }
}

/**
 * 拖尾粒子类
 */
class TrailParticle {
    public var quad:Quad;
    public var life:Float;
    public var maxLife:Float;
    public var velocityX:Float;
    public var velocityY:Float;
    
    public function new() {
        velocityX = 0;
        velocityY = 0;
    }
    
    public function dispose():Void {
        if (quad != null) {
            quad.dispose();
            quad = null;
        }
    }
}