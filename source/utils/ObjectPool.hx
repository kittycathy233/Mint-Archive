package utils;

import flixel.util.FlxPool;
import flixel.util.FlxDestroyUtil;

/**
 * 通用对象池系统
 * 用于高效管理和重用对象，减少垃圾回收压力
 */
class ObjectPool<T>
{
    private var pool:Array<T>;
    private var createFunction:Void->T;
    private var resetFunction:T->Void;
    private var maxSize:Int;
    private var currentSize:Int = 0;
    
    /**
     * 创建对象池
     * @param createFunc 创建新对象的函数
     * @param resetFunc 重置对象状态的函数
     * @param maxSize 池的最大大小
     */
    public function new(createFunc:Void->T, resetFunc:T->Void, maxSize:Int = 100)
    {
        this.createFunction = createFunc;
        this.resetFunction = resetFunc;
        this.maxSize = maxSize;
        this.pool = [];
        
        // 预创建一些对象
        var preCreateCount = Std.int(maxSize * 0.2); // 预创建20%
        for (i in 0...preCreateCount)
        {
            var obj = createFunction();
            pool.push(obj);
            currentSize++;
        }
        
        trace("ObjectPool: Created with " + preCreateCount + " pre-allocated objects");
    }
    
    /**
     * 从池中获取对象
     */
    public function get():T
    {
        var obj:T;
        
        if (pool.length > 0)
        {
            obj = pool.pop();
            currentSize--;
        }
        else
        {
            obj = createFunction();
            trace("ObjectPool: Created new object (pool was empty)");
        }
        
        return obj;
    }
    
    /**
     * 将对象返回到池中
     */
    public function put(obj:T):Void
    {
        if (obj == null) return;
        
        // 重置对象状态
        if (resetFunction != null)
        {
            resetFunction(obj);
        }
        
        // 如果池未满，则添加到池中
        if (currentSize < maxSize)
        {
            pool.push(obj);
            currentSize++;
        }
        else
        {
            // 池已满，销毁对象
            if (Std.is(obj, flixel.util.FlxDestroyUtil.IFlxDestroyable))
            {
                cast(obj, flixel.util.FlxDestroyUtil.IFlxDestroyable).destroy();
            }
        }
    }
    
    /**
     * 清空池
     */
    public function clear():Void
    {
        for (obj in pool)
        {
            if (Std.is(obj, flixel.util.FlxDestroyUtil.IFlxDestroyable))
            {
                cast(obj, flixel.util.FlxDestroyUtil.IFlxDestroyable).destroy();
            }
        }
        pool = [];
        currentSize = 0;
        trace("ObjectPool: Cleared all objects");
    }
    
    /**
     * 获取池的状态信息
     */
    public function getStats():{available:Int, maxSize:Int, utilizationRate:Float}
    {
        var utilizationRate = (maxSize - currentSize) / maxSize;
        return {
            available: currentSize,
            maxSize: maxSize,
            utilizationRate: utilizationRate
        };
    }
    
    /**
     * 预热池（预创建对象）
     */
    public function warmUp(count:Int):Void
    {
        var actualCount = Std.int(Math.min(count, maxSize - currentSize));
        for (i in 0...actualCount)
        {
            var obj = createFunction();
            pool.push(obj);
            currentSize++;
        }
        trace("ObjectPool: Warmed up with " + actualCount + " objects");
    }
}