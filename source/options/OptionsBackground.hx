package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import utils.Conductor;
import utils.SettingsData;

class OptionsBackground
{
    public var bg:FlxSprite;
    public var bgMusic:FlxSound;
    public var bgSfx:FlxSound;
    
    // 动画变量
    private var defaultBgScale:Float = 1.7;
    private var targetBgScale:Float = 1.7;
    
    private var parent:OptionsState;
    
    public function new(parent:OptionsState)
    {
        this.parent = parent;
    }
    
    public function create():Void
    {
        // 加载背景图
        bg = new FlxSprite(0, 0).loadGraphic("assets/images/bg/BG_Garret_Night.jpg");
        bg.scale.set(1.8, 1.8);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set(0.2, 0.2);
        parent.add(bg);
        
        // 播放背景音乐
        bgMusic = FlxG.sound.play("assets/music/Theme_281.ogg", SettingsData.instance.masterVolume * SettingsData.instance.musicVolume * 0.8, true);
        bgMusic.persist = true;
        
        updateMusicVolume();
    }
    
    public function updateMusicVolume():Void
    {
        if (bgMusic != null)
        {
            bgMusic.volume = SettingsData.instance.masterVolume * SettingsData.instance.musicVolume * 0.8;
        }
        if (bgSfx != null)
        {
            bgSfx.volume = SettingsData.instance.masterVolume * SettingsData.instance.sfxVolume * 0.6;
        }
    }
    
    public function onBeat():Void
    {
        // 在节拍时立即放大背景
        bg.scale.x += 0.01;
        bg.scale.y += 0.01;
        
        bg.updateHitbox();
        bg.screenCenter();
    }
    
    public function update(elapsed:Float):Void
    {
        // 更新Conductor的歌曲位置
        if (bgMusic != null)
        {
            // 检测音乐是否循环（当时间回到接近0时）
            if (bgMusic.time < 100 && Conductor.songPosition > bgMusic.length - 100) {
                Conductor.reset();
            }

            Conductor.songPosition = bgMusic.time;
            Conductor.update(elapsed);
        }
        
        updateBgScale(elapsed);
    }
    
    private function updateBgScale(elapsed:Float):Void
    {
        var currentScale = bg.scale.x;
        var newScale = FlxMath.lerp(currentScale, defaultBgScale, elapsed * 5);
        
        bg.scale.set(newScale, newScale);
        bg.updateHitbox();
        bg.screenCenter();
    }
    
    public function playConfirmSound():Void
    {
        bgSfx = FlxG.sound.play("assets/sounds/saveoptions.ogg", SettingsData.instance.masterVolume * SettingsData.instance.sfxVolume * 0.8, false);
    }
    
    public function stop():Void
    {
        if (bgMusic != null)
        {
            bgMusic.stop();
        }
        if (bgSfx != null)
        {
            bgSfx.stop();
        }
    }
    
    public function destroy():Void
    {
        if (bgMusic != null)
        {
            bgMusic.stop();
            bgMusic.destroy();
        }
        if (bgSfx != null)
        {
            bgSfx.stop();
            bgSfx.destroy();
        }
    }
}