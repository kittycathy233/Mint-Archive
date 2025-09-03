package options;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import utils.Conductor;
import utils.SettingsData;
import options.OptionsUI;
import options.OptionsBackground;
import options.OptionsTitle;

class OptionsState extends FlxState
{
    private var backButton:FlxButton;
    private var applyButton:FlxButton;
    private var resetButton:FlxButton;
    
    // 模块化组件
    private var optionsUI:OptionsUI;
    private var optionsBackground:OptionsBackground;
    private var optionsTitle:OptionsTitle;
    
    // 添加这些字段用于滑块绑定
    public var masterVolumeValue:Float = SettingsData.instance.masterVolume;
    public var musicVolumeValue:Float = SettingsData.instance.musicVolume;
    public var sfxVolumeValue:Float = SettingsData.instance.sfxVolume;
    
    override public function create():Void
    {
        super.create();

        // Initialize settings if not already done
        SettingsData.init();

        FlxG.autoPause = SettingsData.instance.autoPause;

        final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
        FlxG.updateFramerate = SettingsData.instance.vsync ? Std.int(FlxMath.bound(refreshRate, 60, 240)) : SettingsData.instance.frameRateLimit;

        // 初始化Conductor，设置BPM为114
        Conductor.init(114);
        
        // 创建模块化组件
        optionsBackground = new OptionsBackground(this);
        optionsBackground.create();
        
        optionsTitle = new OptionsTitle(this);
        optionsTitle.create();
        
        optionsUI = new OptionsUI(this);
        
        // 初始化音量值
        masterVolumeValue = SettingsData.instance.masterVolume;
        musicVolumeValue = SettingsData.instance.musicVolume;
        sfxVolumeValue = SettingsData.instance.sfxVolume;
        
        // 创建UI
        optionsUI.createUI();
        
        // 创建按钮
        createButtons();
        
        // 设置Conductor的节拍回调
        Conductor.onBeat = onBeat;
        
        // 初始更新帧率设置UI状态
        optionsUI.drawFramerateUI();
    }
    
    private function createButtons():Void
    {
        backButton = new FlxButton(100, FlxG.height - 120, "Back", goBack);
        backButton.updateHitbox();
        backButton.label.scale.set(2, 2);
        backButton.scale.set(2, 2);
        add(backButton);
        
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
    }
    
    public function updateMusicVolume():Void
    {
        optionsBackground.updateMusicVolume();
    }
    
    /**
     * 更新主题（背景、音乐和标题）
     */
    public function updateTheme():Void
    {
        // 移除旧背景
        if (optionsBackground != null) {
            optionsBackground.stop();
            remove(optionsBackground.bg);
        }
        
        // 重新创建背景
        optionsBackground = new OptionsBackground(this);
        optionsBackground.create();
        
        // 更新标题颜色
        if (optionsTitle != null) {
            optionsTitle.updateTheme();
        }
    }
    
    private function onBeat():Void
    {
        optionsBackground.onBeat();
        // 可以选择性地创建标题残影
        // optionsTitle.createTitleTrail();
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 检测帧率限制器的值变化
        if (optionsUI.frameRateStepper != null && optionsUI.frameRateStepper.value != SettingsData.instance.frameRateLimit) {
            SettingsData.instance.frameRateLimit = Std.int(optionsUI.frameRateStepper.value);
        }
        
        // 更新各个模块
        optionsBackground.update(elapsed);
        optionsTitle.update(elapsed);
        
        // Handle escape key to go back
        if (FlxG.keys.justPressed.ESCAPE)
        {
            goBack();
        }
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

        optionsBackground.playConfirmSound();

        FlxTween.tween(confirmText, {alpha: 0}, 2, {onComplete: function(_) {
            remove(confirmText);
            confirmText.destroy();
        }});

        SettingsData.instance.load();
        final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
        FlxG.updateFramerate = SettingsData.instance.vsync ? Std.int(FlxMath.bound(refreshRate, 60, 240)) : SettingsData.instance.frameRateLimit;
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
        SettingsData.instance.languagePlus = "english";
        SettingsData.instance.vsync = false;
        SettingsData.instance.autoPause = false;
        SettingsData.instance.titleTheme = "1st_PV";
        SettingsData.instance.frameRateLimit = 60;
        
        // Update UI values
        masterVolumeValue = SettingsData.instance.masterVolume;
        musicVolumeValue = SettingsData.instance.musicVolume;
        sfxVolumeValue = SettingsData.instance.sfxVolume;
        
        // Reset UI elements
        optionsUI.resetToDefaults();
        
        // 强制更新滑块显示
        optionsUI.masterVolumeSlider.value = masterVolumeValue;
        optionsUI.musicVolumeSlider.value = musicVolumeValue;
        optionsUI.sfxVolumeSlider.value = sfxVolumeValue;
        
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
    
    /**
     * 从设置数据更新UI组件
     * 用于导入设置后刷新UI状态
     */
    public function updateUIFromSettings():Void
    {
        // 更新音量值
        masterVolumeValue = SettingsData.instance.masterVolume;
        musicVolumeValue = SettingsData.instance.musicVolume;
        sfxVolumeValue = SettingsData.instance.sfxVolume;
        
        // 更新UI组件
        optionsUI.masterVolumeSlider.value = masterVolumeValue;
        optionsUI.musicVolumeSlider.value = musicVolumeValue;
        optionsUI.sfxVolumeSlider.value = sfxVolumeValue;
        
        optionsUI.fullscreenCheckbox.checked = SettingsData.instance.fullscreen;
        optionsUI.vsyncCheckbox.checked = SettingsData.instance.vsync;
        optionsUI.showFPSCheckbox.checked = SettingsData.instance.showFPS;
        optionsUI.autoPauseCheckbox.checked = SettingsData.instance.autoPause;
        
        optionsUI.languagePlusDropdown.selectedLabel = SettingsData.instance.languagePlus;
        optionsUI.titleThemeDropdown.selectedLabel = SettingsData.instance.titleTheme;
        optionsUI.themeModeDropdown.selectedLabel = SettingsData.instance.themeMode;
        
        if (optionsUI.frameRateStepper != null) {
            optionsUI.frameRateStepper.value = SettingsData.instance.frameRateLimit;
        }
        
        // 更新帧率UI显示
        optionsUI.drawFramerateUI();
        
        // 更新主题
        updateTheme();
        
        // 更新音乐音量
        updateMusicVolume();
    }
    
    private function goBack():Void
    {
        optionsBackground.stop();
        FlxG.switchState(new MainMenuState());
    }
    
    override public function destroy():Void
    {
        super.destroy();
        
        if (optionsBackground != null)
        {
            optionsBackground.destroy();
        }
    }
}