package options;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

@:structInit class SaveVariables {
    // 把Psych Engine的ClientPrefs扒了hhh
    //INT
    public var highScore:Int = 0;
    //FLOAT
    public var totalPlayTime:Float = 0;
    //ARRAY
    public var unlockedSongs:Array<String> = [];
    public var completedWeeks:Array<Int> = [];
    //MAP
    public var achievements:Map<String, Bool> = [];
    public var customScores:Map<String, Int> = []; // 歌曲名称 -> 分数
    public var songStats:Map<String, {plays:Int, wins:Int, losses:Int}> = [];
    //STRING
    public var playerName:String = "";

}

class SaveData {
    public static var data:SaveVariables = {};
    public static var defaultData:SaveVariables = {};

    public static function saveSettings() {
        for (key in Reflect.fields(data))
            Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

        FlxG.save.flush();

        var save:FlxSave = new FlxSave();
        save.bind('optionsData_v1', CoolUtil.getSavePath());
        save.data.saveVariables = data;
        save.flush();
        FlxG.log.add("Data saved!");
    }

    public static function loadPrefs() {
        // 首先加载默认值
        data = defaultData;

        // 尝试从主保存文件加载
        for (key in Reflect.fields(data)) {
            if (Reflect.hasField(FlxG.save.data, key)) {
                Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
            }
        }

        var save:FlxSave = new FlxSave();
        save.bind('optionsData_v1', CoolUtil.getSavePath());
        if (save != null && save.data.saveVariables != null) {
            var loadedData:SaveVariables = save.data.saveVariables;
            for (key in Reflect.fields(loadedData)) {
                Reflect.setField(data, key, Reflect.field(loadedData, key));
            }
        }
    }
}