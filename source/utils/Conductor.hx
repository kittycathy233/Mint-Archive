package utils;

class Conductor
{
    public static var bpm:Float = 100;
    public static var crochet:Float = ((60 / bpm) * 1000); // 每拍毫秒数
    public static var stepCrochet:Float = crochet / 4; // 每步毫秒数
    public static var songPosition:Float = 0;
    
    public static var onBeat:Void->Void = null;
    public static var curBeat:Int = 0;
    public static var curStep:Int = 0;
    
    public static function init(newBPM:Float):Void
    {
        bpm = newBPM;
        crochet = calculateCrochet(bpm);
        stepCrochet = crochet / 4;
        songPosition = 0;
        curBeat = 0;
        curStep = 0;
    }

    public static function update(elapsed:Float):Void
    {
        // 计算当前节拍和步数
        var beat:Float = getBeat(songPosition);
        var step:Float = getStep(songPosition);
        
        // 检查是否进入新节拍
        if (Math.floor(beat) > curBeat)
        {
            curBeat = Math.floor(beat);
            if (onBeat != null)
                onBeat();
        }
        
        curStep = Math.floor(step);
    }
    
    public static function calculateCrochet(bpm:Float):Float
    {
        return (60 / bpm) * 1000;
    }
    
    public static function getBeat(time:Float):Float
    {
        return getStep(time) / 4;
    }
    
    public static function getStep(time:Float):Float
    {
        return time / stepCrochet;
    }
    
    public static function setBPM(newBPM:Float):Void
    {
        bpm = newBPM;
        crochet = calculateCrochet(bpm);
        stepCrochet = crochet / 4;
    }

	public static function reset():Void {
		songPosition = 0;
		curBeat = 0;
		curStep = 0;
	}

}