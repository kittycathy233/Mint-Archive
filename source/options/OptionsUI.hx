package options;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import utils.SettingsData;
import utils.FileDialog;
import utils.FileDialog.FileDialogType;
import lime.ui.FileDialog as LimeFileDialog;
import lime.ui.FileDialogType as LimeFileDialogType;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class OptionsUI
{
    // UI Elements
    public var masterVolumeSlider:FlxUISlider;
    public var musicVolumeSlider:FlxUISlider;
    public var sfxVolumeSlider:FlxUISlider;
    public var fullscreenCheckbox:FlxUICheckBox;
    public var vsyncCheckbox:FlxUICheckBox;
    public var showFPSCheckbox:FlxUICheckBox;
    public var autoPauseCheckbox:FlxUICheckBox;
    public var languagePlusDropdown:FlxUIDropDownMenu;
    public var resolutionDropdown:FlxUIDropDownMenu;
    public var titleThemeDropdown:FlxUIDropDownMenu;
    public var frameRateStepper:FlxUINumericStepper;
    public var frameRateLabel:FlxText;
    
    // 导入/导出按钮
    public var exportButton:FlxButton;
    public var importButton:FlxButton;
    
    // 位置变量
    private var vsyncX:Float;
    private var frameRateOriginalX:Float;
    
    private var parent:OptionsState;
    
    public function new(parent:OptionsState)
    {
        this.parent = parent;
    }
    
    public function createUI():Void
    {
        var yPos:Float = 100;
        var labelWidth:Int = 200;
        var controlX:Int = 250;
        
        createVolumeControls(yPos, labelWidth, controlX);
        yPos += 240; // 3 volume controls * 80
        
        createDisplayControls(yPos, labelWidth, controlX);
        yPos += 120; // 3 display controls * 40
        
        createLanguageControls(yPos, labelWidth, controlX);
        yPos += 80; // 2 language/theme controls * 40
        
        createImportExportButtons();
    }
    
    /**
     * 创建导入/导出按钮
     */
    private function createImportExportButtons():Void
    {
        // 导出按钮
        exportButton = new FlxButton(FlxG.width / 2 - 150, FlxG.height - 200, "Export Settings", exportSettings);
        exportButton.scale.set(1.5, 1.5);
        parent.add(exportButton);
        
        // 导入按钮
        importButton = new FlxButton(FlxG.width / 2 + 50, FlxG.height - 200, "Import Settings", importSettings);
        importButton.scale.set(1.5, 1.5);
        parent.add(importButton);
    }
    
    private function createVolumeControls(yPos:Float, labelWidth:Int, controlX:Int):Void
    {
        // Master Volume
        var masterLabel = new FlxText(50, yPos, labelWidth, "Master Volume:", 16);
        parent.add(masterLabel);
        
        masterVolumeSlider = new FlxUISlider(parent, "masterVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        masterVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.masterVolume = value;
            FlxG.sound.volume = value;
            parent.updateMusicVolume();
        };
        parent.add(masterVolumeSlider);
        
        yPos += 80;
        
        // Music Volume
        var musicLabel = new FlxText(50, yPos, labelWidth, "Music Volume:", 16);
        parent.add(musicLabel);
        
        musicVolumeSlider = new FlxUISlider(parent, "musicVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        musicVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.musicVolume = value;
            parent.updateMusicVolume();
        };
        parent.add(musicVolumeSlider);
        
        yPos += 80;
        
        // SFX Volume
        var sfxLabel = new FlxText(50, yPos, labelWidth, "SFX Volume:", 16);
        parent.add(sfxLabel);
        
        sfxVolumeSlider = new FlxUISlider(parent, "sfxVolumeValue", controlX, yPos, 0, 1, 300, 15, 5, FlxColor.WHITE, FlxColor.GRAY);
        sfxVolumeSlider.callback = function(value:Float) {
            SettingsData.instance.sfxVolume = value;
        };
        parent.add(sfxVolumeSlider);
    }
    
    private function createDisplayControls(yPos:Float, labelWidth:Int, controlX:Int):Void
    {
        // Fullscreen
        var fullscreenLabel = new FlxText(50, yPos, labelWidth, "Fullscreen:", 16);
        parent.add(fullscreenLabel);
        
        fullscreenCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        fullscreenCheckbox.checked = SettingsData.instance.fullscreen;
        fullscreenCheckbox.callback = function() {
            SettingsData.instance.fullscreen = fullscreenCheckbox.checked;
        };
        parent.add(fullscreenCheckbox);
        
        yPos += 40;
        
        // VSync and Frame Rate
        createVSyncAndFrameRate(yPos, labelWidth, controlX);
        yPos += 40;
        
        // Show FPS
        var fpsLabel = new FlxText(50, yPos, labelWidth, "Show FPS:", 16);
        parent.add(fpsLabel);
        
        showFPSCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        showFPSCheckbox.checked = SettingsData.instance.showFPS;
        showFPSCheckbox.callback = function() {
            SettingsData.instance.showFPS = showFPSCheckbox.checked;
        };
        parent.add(showFPSCheckbox);
        
        yPos += 40;

        // Auto Pause
        var autoPauseLabel = new FlxText(50, yPos, labelWidth, "Auto Pause:", 16);
        parent.add(autoPauseLabel);

        autoPauseCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        autoPauseCheckbox.checked = SettingsData.instance.autoPause;
        autoPauseCheckbox.callback = function() {
            SettingsData.instance.autoPause = autoPauseCheckbox.checked;
        };
        parent.add(autoPauseCheckbox);
    }
    
    private function createVSyncAndFrameRate(yPos:Float, labelWidth:Int, controlX:Int):Void
    {
        var vsyncLabel = new FlxText(50, yPos, labelWidth, "VSync:", 16);
        parent.add(vsyncLabel);
        
        vsyncX = controlX;
        vsyncCheckbox = new FlxUICheckBox(controlX, yPos, null, null, "", 100);
        vsyncCheckbox.checked = SettingsData.instance.vsync;
        vsyncCheckbox.callback = function() {
            SettingsData.instance.vsync = vsyncCheckbox.checked;
            drawFramerateUI();
        };
        parent.add(vsyncCheckbox);
        
        // Frame Rate Limit
        frameRateLabel = new FlxText(controlX - 50, yPos, labelWidth, "FrameRate:", 16);
        parent.add(frameRateLabel);
        
        frameRateOriginalX = controlX + 50;
        frameRateStepper = new FlxUINumericStepper(controlX + 220, yPos, 10, SettingsData.instance.frameRateLimit, 30, 240, 0);
        frameRateStepper.name = "frameRateStepper";
        parent.add(frameRateStepper);
    }
    
    private function createLanguageControls(yPos:Float, labelWidth:Int, controlX:Int):Void
    {
        // Language
        var languagePlusLabel = new FlxText(50, yPos, labelWidth, "Language:", 16);
        parent.add(languagePlusLabel);

        var languagePluss = ["English", "Simplified_Chinese", "Japanese"];
        languagePlusDropdown = new FlxUIDropDownMenu(controlX, yPos, FlxUIDropDownMenu.makeStrIdLabelArray(languagePluss, true), function(languagePlus:String) {
            SettingsData.instance.languagePlus = languagePlus;
        });

        languagePlusDropdown.selectedLabel = SettingsData.instance.languagePlus;
        parent.add(languagePlusDropdown);
        
        yPos += 40;
        
        // Resolution (placeholder)
        var resolutionLabel = new FlxText(50, yPos, 500, "Resolution: In Development...", 16);
        parent.add(resolutionLabel);
 
        yPos += 40;
        
        // Title Theme
        var titleThemeLabel = new FlxText(50, yPos, labelWidth, "Title Theme:", 16);
        parent.add(titleThemeLabel);

        var titleThemes = ["1st_PV", "2nd_PV", "3rd_PV", "4th_PV", "4th_PV_2", "4.5th_PV", "5th_PV"];
        titleThemeDropdown = new FlxUIDropDownMenu(controlX, yPos, FlxUIDropDownMenu.makeStrIdLabelArray(titleThemes, true), function(title:String) {
            SettingsData.instance.titleTheme = title;
        });
        titleThemeDropdown.selectedLabel = SettingsData.instance.titleTheme;
        parent.add(titleThemeDropdown);
    }
    
    public function drawFramerateUI():Void
    {
        var isVsyncEnabled = SettingsData.instance.vsync;
        
        if (isVsyncEnabled) {
            // VSync启用，将帧率设置移动到VSync位置并隐藏
            FlxTween.tween(frameRateLabel, {x: vsyncX, alpha: 0}, 0.3, {
                ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween) {
                    frameRateLabel.visible = false;
                    frameRateLabel.active = false;
                }
            });
            
            FlxTween.tween(frameRateStepper, {x: vsyncX + 100, alpha: 0}, 0.3, {
                ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween) {
                    frameRateStepper.visible = false;
                    frameRateStepper.active = false;
                }
            });
        } else {
            // VSync禁用，将帧率设置移回原位置并显示
            frameRateLabel.visible = true;
            frameRateLabel.active = true;
            frameRateStepper.visible = true;
            frameRateStepper.active = true;
            
            FlxTween.tween(frameRateLabel, {x: frameRateOriginalX, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
            FlxTween.tween(frameRateStepper, {x: frameRateOriginalX + 130, alpha: 1}, 0.3, {ease: FlxEase.quadOut});
        }
    }
    
    /**
     * 导出设置到JSON文件
     */
    private function exportSettings():Void
    {
        // 使用SettingsData的导出方法获取JSON字符串
        var jsonString = SettingsData.instance.exportToJson();
        
        // 获取当前日期时间作为默认文件名
        var now = Date.now();
        var defaultFileName = 'MintArchive_Settings_${now.getFullYear()}-${now.getMonth()+1}-${now.getDate()}.json';
        
        #if windows
        // 在Windows平台上使用Lime的FileDialog
        try {
            // 创建文件对话框
            var fileDialog = new LimeFileDialog();
            
            // 设置回调
            fileDialog.onSelect.add(function(filePath:String) {
                if (filePath != null && filePath != "")
                {
                    // 直接保存文件
                    try {
                        File.saveContent(filePath, jsonString);
                        showMessage("Settings exported successfully", FlxColor.GREEN);
                    } catch (e:Dynamic) {
                        showMessage("Export failed: " + e, FlxColor.RED);
                    }
                }
            });
            
            fileDialog.onCancel.add(function() {
                // 用户取消了对话框
            });
            
            // 显示保存对话框
            fileDialog.browse(
                LimeFileDialogType.SAVE, 
                "JSON Files:*.json;All Files:*.*",
                defaultFileName
            );
        } catch (e:Dynamic) {
            // 如果Lime的FileDialog失败，回退到自定义对话框
            showMessage("Native dialog failed, using custom dialog", FlxColor.YELLOW);
            useCustomFileDialog(FileDialogType.SAVE, defaultFileName, jsonString);
        }
        #else
        // 在非Windows平台上使用自定义对话框
        useCustomFileDialog(FileDialogType.SAVE, defaultFileName, jsonString);
        #end
    }
    
    /**
     * 使用自定义文件对话框
     * @param type 对话框类型
     * @param defaultFileName 默认文件名
     * @param jsonString 要保存的JSON字符串（仅在保存时使用）
     */
    private function useCustomFileDialog(type:FileDialogType, defaultFileName:String = "", jsonString:String = ""):Void
    {
        var dialog = new FileDialog(
            parent, 
            type, 
            function(filePath:String) {
                if (type == FileDialogType.SAVE) {
                    // 直接保存文件，不尝试创建目录
                    try {
                        File.saveContent(filePath, jsonString);
                        showMessage("Settings exported successfully", FlxColor.GREEN);
                    } catch (e:Dynamic) {
                        showMessage("Export failed: " + e, FlxColor.RED);
                    }
                } else {
                    loadSettingsFromFile(filePath);
                }
            },
            ".json"
        );
        
        // 如果是保存对话框，设置默认文件名
        if (type == FileDialogType.SAVE) {
            dialog.fileNameInput.text = defaultFileName;
        }
        
        parent.add(dialog);
    }
    
    /**
     * 从JSON文件导入设置
     */
    private function importSettings():Void
    {
        #if windows
        // 在Windows平台上使用Lime的FileDialog
        try {
            // 创建文件对话框
            var fileDialog = new lime.ui.FileDialog();
            
            // 设置回调
            fileDialog.onSelect.add(function(filePath:String) {
                if (filePath != null && filePath != "")
                {
                    loadSettingsFromFile(filePath);
                }
            });
            
            fileDialog.onCancel.add(function() {
                // 用户取消了对话框
            });
            
            // 显示打开对话框
            fileDialog.browse(
                LimeFileDialogType.OPEN, 
                "JSON Files:*.json;All Files:*.*"
            );
        } catch (e:Dynamic) {
            // 如果Lime的FileDialog失败，回退到自定义对话框
            showMessage("Native dialog failed, using custom dialog", FlxColor.YELLOW);
            useCustomFileDialog(FileDialogType.OPEN);
        }
        #else
        // 在非Windows平台上使用自定义对话框
        useCustomFileDialog(FileDialogType.OPEN);
        #end
    }
    
    /**
     * 从文件加载设置
     * @param filePath 文件路径
     */
    private function loadSettingsFromFile(filePath:String):Void
    {
        try
        {
            // 读取JSON文件
            var jsonString = File.getContent(filePath);
            
            // 使用SettingsData的导入方法
            if (SettingsData.instance.importFromJson(jsonString))
            {
                // 更新UI
                parent.updateUIFromSettings();
                
                // 应用设置
                SettingsData.instance.apply();
                SettingsData.instance.save();
                
                // 显示成功消息
                showMessage("Settings imported successfully", FlxColor.GREEN);
            }
            else
            {
                showMessage("Invalid settings file format", FlxColor.RED);
            }
        }
        catch (e:Dynamic)
        {
            // 显示错误消息
            showMessage("Import failed: " + e, FlxColor.RED);
        }
    }
    
    /**
     * 显示消息
     * @param message 消息内容
     * @param color 消息颜色
     */
    private function showMessage(message:String, color:FlxColor):Void
    {
        var messageText = new FlxText(0, FlxG.height - 250, FlxG.width, message, 20);
        messageText.setFormat(null, 20, color, CENTER);
        parent.add(messageText);
        
        FlxTween.tween(messageText, {alpha: 0}, 2, {
            onComplete: function(_) {
                parent.remove(messageText);
                messageText.destroy();
            }
        });
    }
    
    public function resetToDefaults():Void
    {
        // Update UI elements to default values
        fullscreenCheckbox.checked = false;
        vsyncCheckbox.checked = false;
        showFPSCheckbox.checked = true;
        autoPauseCheckbox.checked = false;
        languagePlusDropdown.selectedLabel = "English";
        titleThemeDropdown.selectedLabel = "1st_PV";
        
        if (frameRateStepper != null) {
            frameRateStepper.value = 60;
        }
        
        drawFramerateUI();
    }
}