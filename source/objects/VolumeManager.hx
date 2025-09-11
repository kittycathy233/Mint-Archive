package objects;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.CustomVolumeSlider;

/**
 * 音量管理器 - 管理多个音量滑块和音量设置
 */
class VolumeManager extends FlxGroup
{
    // 音量滑块
    private var masterVolumeSlider:CustomVolumeSlider;
    private var musicVolumeSlider:CustomVolumeSlider;
    private var soundVolumeSlider:CustomVolumeSlider;
    
    // 标签
    private var masterLabel:FlxText;
    private var musicLabel:FlxText;
    private var soundLabel:FlxText;
    
    // 当前样式
    public var currentStyle:String = CustomVolumeSlider.STYLE_MODERN;
    
    // 位置和尺寸
    private var startX:Float;
    private var startY:Float;
    private var sliderWidth:Float;
    private var sliderHeight:Float;
    private var spacing:Float;
    
    public function new(x:Float = 100, y:Float = 100, width:Float = 300, height:Float = 30, spacing:Float = 80)
    {
        super();
        
        this.startX = x;
        this.startY = y;
        this.sliderWidth = width;
        this.sliderHeight = height;
        this.spacing = spacing;
        
        // 从设置中获取样式
        if (SettingsData.instance != null && SettingsData.instance.volumeSliderStyle != null)
        {
            currentStyle = SettingsData.instance.volumeSliderStyle;
        }
        
        createVolumeControls();
        updateVolumesFromSettings();
        
        #if desktop
        // 禁用默认的音量热键
        disableDefaultVolumeKeys();
        #end
    }
    
    private function createVolumeControls():Void
    {
        // 主音量
        masterLabel = new FlxText(startX, startY - 25, sliderWidth, "主音量", 16);
        masterLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
        add(masterLabel);
        
        masterVolumeSlider = new CustomVolumeSlider(startX, startY, sliderWidth, sliderHeight, currentStyle);
        masterVolumeSlider.onVolumeChange = onMasterVolumeChange;
        add(masterVolumeSlider);
        
        // 音乐音量
        musicLabel = new FlxText(startX, startY + spacing - 25, sliderWidth, "音乐音量", 16);
        musicLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
        add(musicLabel);
        
        musicVolumeSlider = new CustomVolumeSlider(startX, startY + spacing, sliderWidth, sliderHeight, currentStyle);
        musicVolumeSlider.onVolumeChange = onMusicVolumeChange;
        add(musicVolumeSlider);
        
        // 音效音量
        soundLabel = new FlxText(startX, startY + spacing * 2 - 25, sliderWidth, "音效音量", 16);
        soundLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
        add(soundLabel);
        
        soundVolumeSlider = new CustomVolumeSlider(startX, startY + spacing * 2, sliderWidth, sliderHeight, currentStyle);
        soundVolumeSlider.onVolumeChange = onSoundVolumeChange;
        add(soundVolumeSlider);
    }
    
    private function updateVolumesFromSettings():Void
    {
        if (SettingsData.instance != null)
        {
            masterVolumeSlider.setVolume(SettingsData.instance.masterVolume, false);
            musicVolumeSlider.setVolume(SettingsData.instance.musicVolume, false);
            soundVolumeSlider.setVolume(SettingsData.instance.soundVolume, false);
        }
    }
    
    private function onMasterVolumeChange(volume:Float):Void
    {
        if (SettingsData.instance != null)
        {
            SettingsData.instance.masterVolume = volume;
            SettingsData.instance.save();
            
            // 更新FlxG的音量设置
            FlxG.sound.volume = volume;
        }
    }
    
    private function onMusicVolumeChange(volume:Float):Void
    {
        if (SettingsData.instance != null)
        {
            SettingsData.instance.musicVolume = volume;
            SettingsData.instance.save();
        }
    }
    
    private function onSoundVolumeChange(volume:Float):Void
    {
        if (SettingsData.instance != null)
        {
            SettingsData.instance.soundVolume = volume;
            SettingsData.instance.save();
        }
    }
    
    public function setStyle(style:String):Void
    {
        currentStyle = style;
        
        masterVolumeSlider.setStyle(style);
        musicVolumeSlider.setStyle(style);
        soundVolumeSlider.setStyle(style);
        
        // 保存到设置
        if (SettingsData.instance != null)
        {
            SettingsData.instance.volumeSliderStyle = style;
            SettingsData.instance.save();
        }
    }
    
    public function setPosition(x:Float, y:Float):Void
    {
        startX = x;
        startY = y;
        
        masterLabel.x = startX;
        masterLabel.y = startY - 25;
        masterVolumeSlider.setPosition(startX, startY);
        
        musicLabel.x = startX;
        musicLabel.y = startY + spacing - 25;
        musicVolumeSlider.setPosition(startX, startY + spacing);
        
        soundLabel.x = startX;
        soundLabel.y = startY + spacing * 2 - 25;
        soundVolumeSlider.setPosition(startX, startY + spacing * 2);
    }
    
    #if desktop
    private function disableDefaultVolumeKeys():Void
    {
        // 禁用FlxG的默认音量热键
        FlxG.sound.volumeUpKeys = [];
        FlxG.sound.volumeDownKeys = [];
        FlxG.sound.muteKeys = [];
    }
    #end
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        #if desktop
        // 确保默认热键保持禁用状态
        if (FlxG.sound.volumeUpKeys.length > 0 || 
            FlxG.sound.volumeDownKeys.length > 0 || 
            FlxG.sound.muteKeys.length > 0)
        {
            disableDefaultVolumeKeys();
        }
        #end
    }
    
    // 获取可用的样式列表
    public static function getAvailableStyles():Array<String>
    {
        return [
            CustomVolumeSlider.STYLE_MODERN,
            CustomVolumeSlider.STYLE_RETRO,
            CustomVolumeSlider.STYLE_NEON,
            CustomVolumeSlider.STYLE_MINIMAL,
            CustomVolumeSlider.STYLE_GAMING
        ];
    }
    
    // 获取样式的显示名称
    public static function getStyleDisplayName(style:String):String
    {
        switch (style)
        {
            case CustomVolumeSlider.STYLE_MODERN: return "现代风格";
            case CustomVolumeSlider.STYLE_RETRO: return "复古风格";
            case CustomVolumeSlider.STYLE_NEON: return "霓虹风格";
            case CustomVolumeSlider.STYLE_MINIMAL: return "简约风格";
            case CustomVolumeSlider.STYLE_GAMING: return "游戏风格";
            default: return "未知风格";
        }
    }
}