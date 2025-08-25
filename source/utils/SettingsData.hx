package utils;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSave;
import flixel.math.FlxMath;

class SettingsData
{
    public static var instance:SettingsData;
    
    public var masterVolume:Float = 1.0;
    public var musicVolume:Float = 0.6;
    public var sfxVolume:Float = 0.7;
    public var fullscreen:Bool = false;
    public var resolution:FlxPoint = FlxPoint.get(1280, 720);
    public var showFPS:Bool = true;
    public var languagePlus:String = "English";
    public var vsync:Bool = false;
    public var autoPause:Bool = false;
    public var titleTheme:String = "1st_PV";
    public var antialiasing:Bool = true;
    public var frameRateLimit:Int = 60; // 新增帧率限制字段

    public function new() {}
    
    public static function init():Void
    {
        if (instance == null)
        {
            instance = new SettingsData();
            instance.load();
        }
    }
    
    public function save():Void
    {
        var save:FlxSave = new FlxSave();
        save.bind("MintArchive_Settings");
        
        save.data.masterVolume = masterVolume;
        save.data.musicVolume = musicVolume;
        save.data.sfxVolume = sfxVolume;
        save.data.fullscreen = fullscreen;
        save.data.resolution = {x: resolution.x, y: resolution.y};
        save.data.showFPS = showFPS;
        save.data.languagePlus = languagePlus;
        save.data.vsync = vsync;
        save.data.autoPause = autoPause;
        save.data.titleTheme = titleTheme;
        save.data.antialiasing = antialiasing;
        save.data.frameRateLimit = frameRateLimit;
        
        save.flush();
        save.close();

        trace("Settings saved:     TitleTheme: " + titleTheme + "   Language: " + languagePlus);
    }
    
    public function load():Void
    {
        var save:FlxSave = new FlxSave();
        save.bind("MintArchive_Settings");
        
        if (save.data.masterVolume != null) masterVolume = save.data.masterVolume;
        if (save.data.musicVolume != null) musicVolume = save.data.musicVolume;
        if (save.data.sfxVolume != null) sfxVolume = save.data.sfxVolume;
        if (save.data.fullscreen != null) fullscreen = save.data.fullscreen;
        if (save.data.resolution != null)
        {
            resolution.x = save.data.resolution.x;
            resolution.y = save.data.resolution.y;
        }
        if (save.data.showFPS != null) showFPS = save.data.showFPS;
        if (save.data.languagePlus != null) languagePlus = save.data.languagePlus;
        if (save.data.vsync != null) vsync = save.data.vsync;
        if (save.data.autoPause != null) autoPause = save.data.autoPause;

        if (save.data.titleTheme != null) {
            var themeValue = save.data.titleTheme;
            themeValue = replaceSpecialChars(themeValue);
            
            // 修复titleTheme被保存为数字的问题
            if (themeValue == "6") {
                titleTheme = "5th_PV";
            } else if (themeValue == "5") {
                titleTheme = "4.5th_PV";
            } else if (themeValue == "4") {
                titleTheme = "4th_PV_2";
            } else if (themeValue == "3") {
                titleTheme = "4th_PV";
            } else if (themeValue == "2") {
                titleTheme = "3rd_PV";
            } else if (themeValue == "1") {
                titleTheme = "2nd_PV";
            } else if (themeValue == "0") {
                titleTheme = "1st_PV";
            } else {
                titleTheme = themeValue;
            }
        }
        
		if (save.data.languagePlus != null) {
			var languageValue = save.data.languagePlus;
			languageValue = replaceSpecialChars(languageValue);

			if (languageValue == "2") {
				languagePlus = "Japanese";
			} else if (languageValue == "1") {
				languagePlus = "Simplified_Chinese";
			} else if (languageValue == "0") {
				languagePlus = "English";
			} else {
				languagePlus = languageValue;
			}
		}
        
        if (save.data.antialiasing != null) antialiasing = save.data.antialiasing;
        if (save.data.frameRateLimit != null) frameRateLimit = save.data.frameRateLimit;
        
        save.close();

        final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
        FlxG.stage.frameRate = vsync ? Std.int(FlxMath.bound(refreshRate, 60, 240)) : frameRateLimit;

        trace("Settings loaded:     TitleTheme: " + titleTheme + "   Language: " + languagePlus + "     FPS:" + frameRateLimit);
    }
    
    private function replaceSpecialChars(str:String):String
    {
        // 替换空格和特殊字符为下划线
        return ~/[ ~%&\\;:"',<>?#]+/g.replace(str, "_");
    }
    
    public function apply():Void
    {
        FlxG.sound.volume = masterVolume;
        FlxG.fullscreen = fullscreen;
        FlxG.autoPause = autoPause;
        
        final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
        FlxG.updateFramerate = vsync ? Std.int(FlxMath.bound(refreshRate, 60, 240)) : frameRateLimit;

        FlxG.save.flush();
    }
}