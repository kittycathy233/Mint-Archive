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
    
    /**
     * 将设置导出为JSON字符串
     * @return String 包含所有设置的JSON字符串
     */
    public function exportToJson():String
    {
        var settingsObj = {
            masterVolume: masterVolume,
            musicVolume: musicVolume,
            sfxVolume: sfxVolume,
            fullscreen: fullscreen,
            resolution: {
                x: resolution.x,
                y: resolution.y
            },
            showFPS: showFPS,
            languagePlus: languagePlus,
            vsync: vsync,
            autoPause: autoPause,
            titleTheme: titleTheme,
            antialiasing: antialiasing,
            frameRateLimit: frameRateLimit
        };
        
        return haxe.Json.stringify(settingsObj, null, "  ");
    }
    
    /**
     * 从JSON字符串导入设置
     * @param jsonString 包含设置的JSON字符串
     * @return Dynamic 包含导入结果和变更信息的对象
     */
    public function importFromJson(jsonString:String):Dynamic
    {
        try
        {
            var settingsObj = haxe.Json.parse(jsonString);
            
            // 验证必要的字段
            if (settingsObj.masterVolume == null || 
                settingsObj.musicVolume == null || 
                settingsObj.sfxVolume == null)
            {
                return { success: false, changes: null };
            }
            
            // 创建一个临时设置对象来存储新设置
            var newSettings = new SettingsData();
            
            // 应用设置到临时对象
            if (settingsObj.masterVolume != null) newSettings.masterVolume = settingsObj.masterVolume;
            if (settingsObj.musicVolume != null) newSettings.musicVolume = settingsObj.musicVolume;
            if (settingsObj.sfxVolume != null) newSettings.sfxVolume = settingsObj.sfxVolume;
            if (settingsObj.fullscreen != null) newSettings.fullscreen = settingsObj.fullscreen;
            
            if (settingsObj.resolution != null)
            {
                newSettings.resolution.x = settingsObj.resolution.x;
                newSettings.resolution.y = settingsObj.resolution.y;
            }
            
            if (settingsObj.showFPS != null) newSettings.showFPS = settingsObj.showFPS;
            if (settingsObj.languagePlus != null) newSettings.languagePlus = settingsObj.languagePlus;
            if (settingsObj.vsync != null) newSettings.vsync = settingsObj.vsync;
            if (settingsObj.autoPause != null) newSettings.autoPause = settingsObj.autoPause;
            if (settingsObj.titleTheme != null) newSettings.titleTheme = settingsObj.titleTheme;
            if (settingsObj.antialiasing != null) newSettings.antialiasing = settingsObj.antialiasing;
            if (settingsObj.frameRateLimit != null) newSettings.frameRateLimit = settingsObj.frameRateLimit;
            
            // 比较新旧设置，找出变更
            var changes = compareSettings(this, newSettings);
            
            // 如果有变更，返回变更信息
            if (changes.length > 0)
            {
                return { success: true, changes: changes, newSettings: newSettings };
            }
            else
            {
                // 没有变更，直接应用设置
                applyNewSettings(newSettings);
                return { success: true, changes: null };
            }
        }
        catch (e:Dynamic)
        {
            trace("Error importing settings: " + e);
            return { success: false, changes: null };
        }
    }
    
    /**
     * 比较两个设置对象，返回变更列表
     * @param oldSettings 旧设置
     * @param newSettings 新设置
     * @return Array<{setting:String, oldValue:Dynamic, newValue:Dynamic}> 变更列表
     */
    private function compareSettings(oldSettings:SettingsData, newSettings:SettingsData):Array<{setting:String, oldValue:Dynamic, newValue:Dynamic}>
    {
        var changes:Array<{setting:String, oldValue:Dynamic, newValue:Dynamic}> = [];
        
        // 比较各个设置项
        if (oldSettings.masterVolume != newSettings.masterVolume)
            changes.push({setting: "Master Volume", oldValue: oldSettings.masterVolume, newValue: newSettings.masterVolume});
            
        if (oldSettings.musicVolume != newSettings.musicVolume)
            changes.push({setting: "Music Volume", oldValue: oldSettings.musicVolume, newValue: newSettings.musicVolume});
            
        if (oldSettings.sfxVolume != newSettings.sfxVolume)
            changes.push({setting: "SFX Volume", oldValue: oldSettings.sfxVolume, newValue: newSettings.sfxVolume});
            
        if (oldSettings.fullscreen != newSettings.fullscreen)
            changes.push({setting: "Fullscreen", oldValue: oldSettings.fullscreen, newValue: newSettings.fullscreen});
            
        if (oldSettings.resolution.x != newSettings.resolution.x || oldSettings.resolution.y != newSettings.resolution.y)
            changes.push({
                setting: "Resolution", 
                oldValue: oldSettings.resolution.x + "x" + oldSettings.resolution.y, 
                newValue: newSettings.resolution.x + "x" + newSettings.resolution.y
            });
            
        if (oldSettings.showFPS != newSettings.showFPS)
            changes.push({setting: "Show FPS", oldValue: oldSettings.showFPS, newValue: newSettings.showFPS});
            
        if (oldSettings.languagePlus != newSettings.languagePlus)
            changes.push({setting: "Language", oldValue: oldSettings.languagePlus, newValue: newSettings.languagePlus});
            
        if (oldSettings.vsync != newSettings.vsync)
            changes.push({setting: "VSync", oldValue: oldSettings.vsync, newValue: newSettings.vsync});
            
        if (oldSettings.autoPause != newSettings.autoPause)
            changes.push({setting: "Auto Pause", oldValue: oldSettings.autoPause, newValue: newSettings.autoPause});
            
        if (oldSettings.titleTheme != newSettings.titleTheme)
            changes.push({setting: "Title Theme", oldValue: oldSettings.titleTheme, newValue: newSettings.titleTheme});
            
        if (oldSettings.antialiasing != newSettings.antialiasing)
            changes.push({setting: "Antialiasing", oldValue: oldSettings.antialiasing, newValue: newSettings.antialiasing});
            
        if (oldSettings.frameRateLimit != newSettings.frameRateLimit)
            changes.push({setting: "Frame Rate Limit", oldValue: oldSettings.frameRateLimit, newValue: newSettings.frameRateLimit});
            
        return changes;
    }
    
    /**
     * 应用新设置
     * @param newSettings 新设置对象
     */
    public function applyNewSettings(newSettings:SettingsData):Void
    {
        // 复制所有设置
        this.masterVolume = newSettings.masterVolume;
        this.musicVolume = newSettings.musicVolume;
        this.sfxVolume = newSettings.sfxVolume;
        this.fullscreen = newSettings.fullscreen;
        this.resolution.x = newSettings.resolution.x;
        this.resolution.y = newSettings.resolution.y;
        this.showFPS = newSettings.showFPS;
        this.languagePlus = newSettings.languagePlus;
        this.vsync = newSettings.vsync;
        this.autoPause = newSettings.autoPause;
        this.titleTheme = newSettings.titleTheme;
        this.antialiasing = newSettings.antialiasing;
        this.frameRateLimit = newSettings.frameRateLimit;
    }
}