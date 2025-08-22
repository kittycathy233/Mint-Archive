package options;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import utils.Conductor;
import utils.SettingsData;
import openfl.Assets;

class OptionsState extends FlxState
{
    private var backButton:FlxButton;
    private var titleText:FlxText;
    private var titleTrailGroup:FlxTypedGroup<FlxText>;
    
    // UI Elements
    private var masterVolumeSlider:FlxUISlider;
    private var musicVolumeSlider:FlxUISlider;
    private var sfxVolumeSlider:FlxUISlider;
    private var fullscreenCheckbox:FlxUICheckBox;
    private var vsyncCheckbox:FlxUICheckBox;
    private var showFPSCheckbox:FlxUICheckBox;
    private var autoPauseCheckbox:FlxUICheckBox;
    private var languageDropdown:FlxUIDropDownMenu;
    private var resolutionDropdown:FlxUIDropDownMenu;
    private var titleThemeDropdown:FlxUIDropDownMenu;
    private var applyButton:FlxButton;
    private var resetButton:FlxButton;
    
    // 背景元素
    private var bg:FlxSprite;
    private var bgMusic:flixel.sound.FlxSound;
    private var bgSfx:flixel.sound.FlxSound;
    
    // 添加这些字段用于滑块绑定
    public var masterVolumeValue:Float = SettingsData.instance.masterVolume;
    public var musicVolumeValue:Float = SettingsData.instance.musicVolume;
    public var sfxVolumeValue:Float = SettingsData.instance.sfxVolume;

    // 动画变量
    private var titleY:Float = 50;
    private var titleAmplitude:Float = 4;
    private var titleSpeed:Float = 4;
    private var titleTime:Float = 0;
    private var defaultBgScale:Float = 1.7;
    private var targetBgScale:Float = 1.7;
    
    override public function create():Void
    {
        super.create();

        // Initialize settings if not already done
        SettingsData.init();

        FlxG.autoPause = SettingsData.instance.autoPause;

        // 初始化Conductor，设置BPM为114
        Conductor.init(114);
        
        // 加载背景图
        bg = new FlxSprite(0, 0).loadGraphic("assets/images/bg/BG_Garret_Night.jpg");
        bg.scale.set(1.8, 1.8);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set(0.2, 0.2);
        add(bg);
        
        // 播放背景音乐
        bgMusic = FlxG.sound.play("assets/music/Theme_281.ogg", 0.8, true);
        bgMusic.persist = true;
        
        masterVolumeValue = SettingsData.instance.masterVolume;
        musicVolumeValue = SettingsData.instance.musicVolume;
        sfxVolumeValue = SettingsData.instance.sfxVolume;
        
        updateMusicVolume();

        titleText = new FlxText(0, titleY, FlxG.width, "SETTINGS", 32);
        titleText.setFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        //trail.defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/arturito-slab.ttf").fontName, 40, 0xFFFFFF, true);
        titleText.borderSize = 4;
        add(titleText);

        titleTrailGroup = new FlxTypedGroup<FlxText>();
        add(titleTrailGroup);
        
        backButton = new FlxButton(100, FlxG.height - 120, "Back", goBack);
        backButton.updateHitbox();
        backButton.label.scale.set(2, 2);
        backButton.scale.set(2, 2);
        add(backButton);
        
        createSettingsUI();

        applyButton = new FlxButton(FlxG.width - 300, FlxG.height - 120, "Apply", applySettings);
        applyButton.updateHitbox();
        applyButton.scale.set(2, 2);
        applyButton.label.scale.set(2, 2);
        add(applyButton);
        
        resetButton = new FlxButton(FlxG.width - 600, FlxG.height - 120, "Reset", resetSettings);
        resetButton.updateHitbox();
        resetButton.scale.set(2, 2);
        resetButton.label.scale.set(2, 2);
        add(resetButton);
        
        // 设置Conductor的节拍回调
        Conductor.onBeat = onBeat;
    }
    
    private function updateMusicVolume():Void
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
    
    private function onBeat():Void
    {
        // 在节拍时立即放大背景
        bg.scale.x += 0.01;
        bg.scale.y += 0.01;
        
        bg.updateHitbox();
        bg.screenCenter();
        
        // 创建标题残影
        //createTitleTrail();
    }
    
    private function createTitleTrail():Void
    {
        var trail:FlxText = new FlxText(titleText.x, titleText.y, FlxG.width, "SETTINGS", 32);
        trail.setFormat(null, 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        trail.borderSize = 4;
        trail.alpha = 0.5;
        titleTrailGroup.add(trail);
    }
    
    private function createSettingsUI():Void
    {
        var yPos:Float = 100;
        var labelWidth:Int = 200;
        var controlX:Int = 250;
        
        // Master Volume
        var masterLabel = new FlxText(50, yPos, labelWidth, "Master Volume:", 16);
        add(masterLabel);
        
        masterVolumeSlider = new FlxUISlider(this, "masterVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        masterVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.masterVolume = value;
            FlxG.sound.volume = value;
            updateMusicVolume();
        };
        add(masterVolumeSlider);
        
        yPos += 80;
        
        // Music Volume
        var musicLabel = new FlxText(50, yPos, labelWidth, "Music Volume:", 16);
        add(musicLabel);
        
        musicVolumeSlider = new FlxUISlider(this, "musicVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        musicVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.musicVolume = value;
            updateMusicVolume();
        };
        add(musicVolumeSlider);
        
        yPos += 80;
        
        // SFX Volume
        var sfxLabel = new FlxText(50, yPos, labelWidth, "SFX Volume:", 16);
        add(sfxLabel);
        
        sfxVolumeSlider = new FlxUISlider(this, "sfxVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        sfxVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.sfxVolume = value;
        };
        add(sfxVolumeSlider);
        
        yPos += 80;
        
        // Fullscreen
        var fullscreenLabel = new FlxText(50, yPos, labelWidth, "Fullscreen:", 16);
        add(fullscreenLabel);
        
        fullscreenCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        fullscreenCheckbox.checked = SettingsData.instance.fullscreen;
        fullscreenCheckbox.callback = function() {
            SettingsData.instance.fullscreen = fullscreenCheckbox.checked;
        };
        add(fullscreenCheckbox);
        
        yPos += 40;
        
        // VSync
        var vsyncLabel = new FlxText(50, yPos, labelWidth, "VSync:", 16);
        add(vsyncLabel);
        
        vsyncCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        vsyncCheckbox.checked = SettingsData.instance.vsync;
        vsyncCheckbox.callback = function() {
            SettingsData.instance.vsync = vsyncCheckbox.checked;
        };
        add(vsyncCheckbox);
        
        yPos += 40;
        
        // Show FPS
        var fpsLabel = new FlxText(50, yPos, labelWidth, "Show FPS:", 16);
        add(fpsLabel);
        
        showFPSCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        showFPSCheckbox.checked = SettingsData.instance.showFPS;
        showFPSCheckbox.callback = function() {
            SettingsData.instance.showFPS = showFPSCheckbox.checked;
        };
        add(showFPSCheckbox);
        
        yPos += 40;

        // Auto Pause
        var autoPauseLabel = new FlxText(50, yPos, labelWidth, "Auto Pause:", 16);
        add(autoPauseLabel);

        autoPauseCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        autoPauseCheckbox.checked = SettingsData.instance.autoPause;
        autoPauseCheckbox.callback = function() {
            SettingsData.instance.autoPause = autoPauseCheckbox.checked;
        };
        add(autoPauseCheckbox);

        yPos += 40;

        // Language
        var languageLabel = new FlxText(50, yPos, labelWidth, "Language:", 16);
        add(languageLabel);
        
        var languages = ["English", "Spanish", "French", "German", "Japanese"];
        languageDropdown = new FlxUIDropDownMenu(controlX, yPos, FlxUIDropDownMenu.makeStrIdLabelArray(languages, true), function(language:String) {
            SettingsData.instance.language = language.toLowerCase();
        });
        languageDropdown.selectedLabel = SettingsData.instance.language.charAt(0).toUpperCase() + SettingsData.instance.language.substr(1);
        add(languageDropdown);
        
        yPos += 40;
        
        // Resolution
        var resolutionLabel = new FlxText(50, yPos, labelWidth, "Resolution:", 16);
        add(resolutionLabel);
        
        var resolutions = ["1280x720", "1920x1080", "2560x1440", "3840x2160"];
        resolutionDropdown = new FlxUIDropDownMenu(controlX, yPos, FlxUIDropDownMenu.makeStrIdLabelArray(resolutions, true), function(resolution:String) {
            var parts = resolution.split("x");
            SettingsData.instance.resolution.set(Std.parseInt(parts[0]), Std.parseInt(parts[1]));
        });
        resolutionDropdown.selectedLabel = Std.int(SettingsData.instance.resolution.x) + "x" + Std.int(SettingsData.instance.resolution.y);
        add(resolutionDropdown);

        yPos += 40;
        
        // Title Theme
        var titleThemeLabel = new FlxText(50, yPos, labelWidth, "Title Theme:", 16);
        add(titleThemeLabel);

        var titleThemes = ["1st PV", "2nd PV", "3rd PV", "4th PV", "4th PV_2", "4.5th PV", "5th PV"];
        titleThemeDropdown = new FlxUIDropDownMenu(controlX, yPos, FlxUIDropDownMenu.makeStrIdLabelArray(titleThemes, true), function(title:String) {
            SettingsData.instance.titleTheme = title;
        });
        titleThemeDropdown.selectedLabel = SettingsData.instance.titleTheme;
        add(titleThemeDropdown);
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 更新Conductor的歌曲位置
        if (bgMusic != null)
        {
            Conductor.songPosition = bgMusic.time;
            Conductor.update(elapsed);
        }
		if (bgMusic != null) {
			// 检测音乐是否循环（当时间回到接近0时）
			if (bgMusic.time < 100 && Conductor.songPosition > bgMusic.length - 100) {
				Conductor.reset();
			}

			Conductor.songPosition = bgMusic.time;
			Conductor.update(elapsed);
		}

        titleTime += elapsed;
        titleText.y = titleY + Math.sin(titleTime * titleSpeed) * titleAmplitude;
        
        updateTitleTrails(elapsed);
        
        updateBgScale(elapsed);
        
        // Handle escape key to go back
        if (FlxG.keys.justPressed.ESCAPE)
        {
            goBack();
        }
    }
    
    private function updateTitleTrails(elapsed:Float):Void
    {
        for (trail in titleTrailGroup.members)
        {
            if (trail != null)
            {
                trail.y += elapsed * 50;
                trail.alpha -= elapsed * 2;
                
                if (trail.alpha <= 0)
                {
                    titleTrailGroup.remove(trail, true);
                    trail.destroy();
                }
            }
        }
    }
    
    private function updateBgScale(elapsed:Float):Void
    {
        var currentScale = bg.scale.x;
        var newScale = FlxMath.lerp(currentScale, defaultBgScale, elapsed * 5);
        
        bg.scale.set(newScale, newScale);
        bg.updateHitbox();
        bg.screenCenter();
    }
    
    private function applySettings():Void
    {
        // Apply and save settings
        SettingsData.instance.apply();
        SettingsData.instance.save();
        
        updateMusicVolume();
        
        // Show confirmation
        var confirmText = new FlxText(0, FlxG.height - 200, FlxG.width, "Settings Applied!", 42);
        confirmText.setFormat(null, 42, FlxColor.GREEN, CENTER);
        add(confirmText);

        bgSfx = FlxG.sound.play("assets/sounds/saveoptions.ogg", 0.6, false);

        FlxTween.tween(confirmText, {alpha: 0}, 2, {onComplete: function(_) {
            remove(confirmText);
            confirmText.destroy();
        }});
    }
    
    private function resetSettings():Void
    {
        // Reset to default values
        SettingsData.instance.masterVolume = 1.0;
        SettingsData.instance.musicVolume = 0.7;
        SettingsData.instance.sfxVolume = 0.8;
        SettingsData.instance.fullscreen = false;
        SettingsData.instance.resolution.set(1280, 720);
        SettingsData.instance.showFPS = true;
        SettingsData.instance.language = "english";
        SettingsData.instance.vsync = false;
        SettingsData.instance.autoPause = false;
        SettingsData.instance.titleTheme = "1st PV";
        
        // Update UI
        masterVolumeValue = SettingsData.instance.masterVolume;
        musicVolumeValue = SettingsData.instance.musicVolume;
        sfxVolumeValue = SettingsData.instance.sfxVolume;
        fullscreenCheckbox.checked = SettingsData.instance.fullscreen;
        vsyncCheckbox.checked = SettingsData.instance.vsync;
        showFPSCheckbox.checked = SettingsData.instance.showFPS;
        autoPauseCheckbox.checked = SettingsData.instance.autoPause;
        languageDropdown.selectedLabel = "English";
        resolutionDropdown.selectedLabel = "1280x720";
        titleThemeDropdown.selectedLabel = "1st PV";
        
        // 强制更新滑块显示
        masterVolumeSlider.value = masterVolumeValue;
        musicVolumeSlider.value = musicVolumeValue;
        sfxVolumeSlider.value = sfxVolumeValue;
        
        // 更新音乐音量
        updateMusicVolume();
        
        // Apply settings
        SettingsData.instance.apply();
        SettingsData.instance.save();
        
        // Show confirmation
        var confirmText = new FlxText(0, FlxG.height - 100, FlxG.width, "Settings Reset to Default!", 24);
        confirmText.setFormat(null, 24, FlxColor.GREEN, CENTER);
        add(confirmText);
        
        FlxTween.tween(confirmText, {alpha: 0}, 2, {onComplete: function(_) {
            remove(confirmText);
            confirmText.destroy();
        }});
    }
    
    private function goBack():Void
    {
        if (bgMusic != null)
        {
            bgMusic.stop();
        }
        if (bgSfx != null)
        {
            bgSfx.stop();
        }
        
        FlxG.switchState(new MainMenuState());
    }
    
    override public function destroy():Void
    {
        super.destroy();

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