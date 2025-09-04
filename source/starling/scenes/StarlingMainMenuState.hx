package starling.scenes;

import starling.display.Button;
import starling.display.Image;
import starling.display.Quad;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.core.Starling;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.animation.Tween;
import starling.animation.Transitions;
import starling.scenes.SceneManager.Scene;
import openfl.utils.Assets;
import utils.SettingsData;

class StarlingMainMenuState extends BaseStarlingState {
    private var playButton:TextField;
    private var testButton:TextField;
    private var settingsButton:TextField;
    private var backButton:TextField;
    
    private var logo:Image;
    private var versionText:TextField;
    
    private var isTransitioning:Bool = false;
    
    public override function load():Void {
        super.load();
        
        trace("StarlingMainMenuState: Creating Starling main menu...");
        
        // 设置背景色
        background.color = 0x2A2A2A;
        
        createUI();
        
        trace("StarlingMainMenuState: Main menu created successfully");
    }
    
    private function createUI():Void {
        // 创建标题
        var titleText = new TextField(400, 80, "Mint Archive - Starling", new TextFormat("Verdana", 32, 0xFFFFFF));
        titleText.x = (Starling.current.stage.stageWidth - titleText.width) / 2;
        titleText.y = 50;
        addChild(titleText);
        
        // 创建按钮
        var buttonY = 200;
        var buttonSpacing = 80;
        
        // Play 按钮
        playButton = createButton("Run Starling Test", 0x4CAF50);
        playButton.x = (Starling.current.stage.stageWidth - playButton.width) / 2;
        playButton.y = buttonY;
        addChild(playButton);
        
        // Test 按钮
        testButton = createButton("Starling Spine Test", 0x2196F3);
        testButton.x = (Starling.current.stage.stageWidth - testButton.width) / 2;
        testButton.y = buttonY + buttonSpacing;
        addChild(testButton);
        
        // Settings 按钮
        settingsButton = createButton("Settings", 0xFF9800);
        settingsButton.x = (Starling.current.stage.stageWidth - settingsButton.width) / 2;
        settingsButton.y = buttonY + buttonSpacing * 2;
        addChild(settingsButton);
        
        // Back to Menu 按钮
        backButton = createButton("Back to Main Menu", 0xF44336);
        backButton.x = (Starling.current.stage.stageWidth - backButton.width) / 2;
        backButton.y = buttonY + buttonSpacing * 3;
        addChild(backButton);
        
        // 添加事件监听
        playButton.addEventListener(TouchEvent.TOUCH, onPlayClick);
        testButton.addEventListener(TouchEvent.TOUCH, onTestClick);
        settingsButton.addEventListener(TouchEvent.TOUCH, onSettingsClick);
        backButton.addEventListener(TouchEvent.TOUCH, onBackClick);
        
        // 创建Logo（如果存在）
        try {
            var logoTexture = Texture.fromBitmapData(Assets.getBitmapData("assets/images/game/MArchiveLogo.png"));
            logo = new Image(logoTexture);
            logo.scaleX = logo.scaleY = 0.5;
            logo.x = Starling.current.stage.stageWidth - logo.width - 20;
            logo.y = 20;
            addChild(logo);
        } catch (e:Dynamic) {
            trace("StarlingMainMenuState: Could not load logo: " + e);
        }
        
        // 版本信息
        versionText = new TextField(200, 30, "Starling v1.0", new TextFormat("Verdana", 16, 0xCCCCCC));
        versionText.x = Starling.current.stage.stageWidth - versionText.width - 20;
        versionText.y = Starling.current.stage.stageHeight - versionText.height - 20;
        addChild(versionText);
        
        // 添加说明文本
        var infoText = new TextField(600, 100, 
            "Starling Environment\n" +
            "F1: Toggle Mouse Trail\n" +
            "F2-F7: Change Trail Colors", 
            new TextFormat("Verdana", 14, 0xAAAAAA));
        infoText.x = 20;
        infoText.y = Starling.current.stage.stageHeight - infoText.height - 20;
        addChild(infoText);
    }
    
    private function createButton(text:String, color:UInt):TextField {
        var button = new TextField(250, 50, text, new TextFormat("Verdana", 18, 0xFFFFFF));
        
        // 创建按钮背景
        var buttonBg = new Quad(button.width + 20, button.height + 10, color);
        buttonBg.x = button.x - 10;
        buttonBg.y = button.y - 5;
        
        // 先添加背景，再添加文本
        addChild(buttonBg);
        
        return button;
    }
    
    private function onPlayClick(event:TouchEvent):Void {
        var touch = event.getTouch(playButton);
        if (touch != null && touch.phase == TouchPhase.ENDED && !isTransitioning) {
            trace("StarlingMainMenuState: Play button clicked");
            transitionToState(new StarlingPlayState());
        }
    }
    
    private function onTestClick(event:TouchEvent):Void {
        var touch = event.getTouch(testButton);
        if (touch != null && touch.phase == TouchPhase.ENDED && !isTransitioning) {
            trace("StarlingMainMenuState: Test button clicked");
            transitionToState(new BasicExample());
        }
    }
    
    private function onSettingsClick(event:TouchEvent):Void {
        var touch = event.getTouch(settingsButton);
        if (touch != null && touch.phase == TouchPhase.ENDED && !isTransitioning) {
            trace("StarlingMainMenuState: Settings button clicked");
            // 这里可以添加设置界面
            addText("Settings not implemented yet", 10, 100);
        }
    }
    
    private function onBackClick(event:TouchEvent):Void {
        var touch = event.getTouch(backButton);
        if (touch != null && touch.phase == TouchPhase.ENDED && !isTransitioning) {
            trace("StarlingMainMenuState: Back button clicked - returning to main menu");
            // 这里需要回到主选择界面，但由于架构限制，我们只能重启应用或显示消息
            addText("Please restart application to return to main menu", 10, 150);
        }
    }
    
    private function transitionToState(newState:Scene):Void {
        if (isTransitioning) return;
        isTransitioning = true;
        
        // 简单的淡出效果
        var fadeOut = new Tween(this, 0.5, Transitions.EASE_OUT);
        fadeOut.animate("alpha", 0);
        fadeOut.onComplete = function() {
            SceneManager.getInstance().switchScene(newState);
        };
        
        Starling.current.juggler.add(fadeOut);
    }
    
    public override function dispose():Void {
        // 移除事件监听
        if (playButton != null) {
            playButton.removeEventListener(TouchEvent.TOUCH, onPlayClick);
        }
        if (testButton != null) {
            testButton.removeEventListener(TouchEvent.TOUCH, onTestClick);
        }
        if (settingsButton != null) {
            settingsButton.removeEventListener(TouchEvent.TOUCH, onSettingsClick);
        }
        if (backButton != null) {
            backButton.removeEventListener(TouchEvent.TOUCH, onBackClick);
        }
        
        // 清理资源
        if (logo != null) {
            logo.dispose();
            logo = null;
        }
        
        super.dispose();
    }
}