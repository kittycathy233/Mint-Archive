package utils;

import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * 鼠标拖尾粒子对象池
 * 专门优化TrailParticle的创建和回收
 */
class TrailParticlePool
{
    public static var instance:TrailParticlePool;
    
    private var pool:ObjectPool<TrailParticle>;
    private var maxParticles:Int = 50; // 增加池大小以应对高频使用
    
    public function new()
    {
        pool = new ObjectPool<TrailParticle>(
            createParticle,
            resetParticle,
            maxParticles
        );
        
        // 预热池
        pool.warmUp(20);
    }
    
    public static function init():Void
    {
        if (instance == null)
        {
            instance = new TrailParticlePool();
            trace("TrailParticlePool: Initialized");
        }
    }
    
    /**
     * 获取粒子
     */
    public function getParticle():TrailParticle
    {
        return pool.get();
    }
    
    /**
     * 回收粒子
     */
    public function returnParticle(particle:TrailParticle):Void
    {
        if (particle != null)
        {
            pool.put(particle);
        }
    }
    
    /**
     * 创建新粒子
     */
    private function createParticle():TrailParticle
    {
        return new TrailParticle();
    }
    
    /**
     * 重置粒子状态
     */
    private function resetParticle(particle:TrailParticle):Void
    {
        if (particle == null) return;
        
        // 使用专门的重置方法
        particle.resetForPool();
    }
    
    /**
     * 获取池状态
     */
    public function getPoolStats():{available:Int, maxSize:Int, utilizationRate:Float}
    {
        return pool.getStats();
    }
    
    /**
     * 清理池
     */
    public function clear():Void
    {
        pool.clear();
    }
}

/**
 * 优化的拖尾粒子类
 * 添加了对象池支持
 */
class TrailParticle extends FlxSprite
{
    public var age:Float = 0.0;
    public var maxAge:Float = 0.3;
    public var size:Int = 24;
    public var initialSize:Int = 24;
    public var isDead:Bool = false;
    
    public function new()
    {
        super();
    }
    
    /**
     * 重置粒子到初始状态（用于对象池）
     */
    override public function reset(X:Float, Y:Float):Void
    {
        super.reset(X, Y);
        
        age = 0.0;
        maxAge = 0.3;
        size = 24;
        initialSize = 24;
        isDead = false;
        visible = true;
        alpha = 1.0;
        
        if (graphic != null)
        {
            makeGraphic(1, 1, FlxColor.TRANSPARENT);
        }
    }
    
    /**
     * 重置粒子状态（不带位置参数，用于对象池）
     */
    public function resetForPool():Void
    {
        age = 0.0;
        maxAge = 0.3;
        size = 24;
        initialSize = 24;
        isDead = false;
        visible = true;
        alpha = 1.0;
        x = 0;
        y = 0;
        
        if (graphic != null)
        {
            makeGraphic(1, 1, FlxColor.TRANSPARENT);
        }
    }
    
    /**
     * 标记粒子为死亡状态
     */
    override public function kill():Void
    {
        super.kill();
        isDead = true;
        visible = false;
        alpha = 0;
    }
    
    override public function destroy():Void
    {
        // 不要真正销毁，而是返回到池中
        if (TrailParticlePool.instance != null)
        {
            TrailParticlePool.instance.returnParticle(this);
        }
        else
        {
            super.destroy();
        }
    }
}