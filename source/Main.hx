package;

import player.LogoState;
import starling.scenes.StarlingLogoState;
import starling.scenes.SceneManager;
import starling.core.Starling;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import starling.events.Event;
import debug.FPSCounter;
import utils.SettingsData;
import utils.LoadingManager;
import utils.AssetLoader;
import utils.TrailParticlePool;

class Main extends Sprite {
    private var background:Sprite;
    private var flixelButton:Sprite;
    private var starlingButton:Sprite;
    private var uiContainer:Sprite;
    private var flixelGame:FlxGame;
    private var fpsCounter:FPSCounter;
    private var starlingSingleton:Starling;

    private static inline var ratio = 4;
    private static inline var STAGE_WIDTH:Int = 100 * ratio;
    private static inline var STAGE_HEIGHT:Int = 200 * ratio;
    private static inline var BUTTON_WIDTH:Int = 80 * ratio;
    private static inline var BUTTON_HEIGHT:Int = 40 * ratio;
    private static inline var BUTTON_SPACING:Int = 20 * ratio;

    public function new() {
        super();
        
        trace("Main: Starting application initialization...");
        
        // Initialize core systems first
        SettingsData.init();
        LoadingManager.init();
        
        // Start multi-threaded loading and object pool initialization
        LoadingManager.instance.startInitialization(onSystemsReady);
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        
        trace("Main: Application initialized, background loading started");
    }
    
    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        createUI();
        centerUI();
        stage.addEventListener(Event.RESIZE, onResize);
    }

    private function createUI():Void {
        uiContainer = new Sprite();
        addChild(uiContainer);

        background = new Sprite();
        background.graphics.beginFill(0xA2A2A2);
        background.graphics.drawRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
        background.graphics.endFill();
        uiContainer.addChild(background);

        flixelButton = createButton("Flixel", 0xFF0000);
        uiContainer.addChild(flixelButton);

        starlingButton = createButton("Starling", 0x00FF00);
        uiContainer.addChild(starlingButton);

        positionButtons();

        flixelButton.addEventListener(MouseEvent.CLICK, onFlixelClick);
        starlingButton.addEventListener(MouseEvent.CLICK, onStarlingClick);
    }

    private function createButton(label:String, color:Int):Sprite {
        var button = new Sprite();
        var g = button.graphics;

        g.beginFill(color);
        g.drawRoundRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT, 10, 10);
        g.endFill();

        // Add button text
        var tf = new TextField();
        var format = new TextFormat("_sans", 14 * ratio, 0x000000, true, null, null, null, null, "center");
        tf.defaultTextFormat = format;
        tf.text = label;
        tf.width = BUTTON_WIDTH;
        tf.height = BUTTON_HEIGHT;
        tf.mouseEnabled = false;
        tf.selectable = false;

        tf.y = (BUTTON_HEIGHT - tf.textHeight) / 2;

        button.addChild(tf);

        return button;
    }

    private function positionButtons():Void {
        var totalHeight = (BUTTON_HEIGHT * 2) + BUTTON_SPACING;
        var startY = (STAGE_HEIGHT - totalHeight) / 2;

        flixelButton.x = (STAGE_WIDTH - BUTTON_WIDTH) / 2;
        flixelButton.y = startY + BUTTON_HEIGHT + BUTTON_SPACING;

        starlingButton.x = (STAGE_WIDTH - BUTTON_WIDTH) / 2;
        starlingButton.y = startY;
    }

    private function centerUI():Void {
        uiContainer.x = (stage.stageWidth - STAGE_WIDTH) / 2;
        uiContainer.y = (stage.stageHeight - STAGE_HEIGHT) / 2;
    }

    private function onResize(e:Event):Void {
        centerUI();
    }

    private function onFlixelClick(e:MouseEvent):Void {
        trace("Launching Flixel game");
        destroyUI();
        
        // Create the Flixel game
        flixelGame = new FlxGame(1920, 1080, LogoState, 60);
        FlxG.autoPause = false;
        
        // Apply settings
        SettingsData.instance.apply();
        
        addChild(flixelGame);

        // Create FPS counter if enabled
        if (SettingsData.instance.showFPS) {
            fpsCounter = new FPSCounter(10, 10);
            addChild(fpsCounter);
        }
    }

    private function onStarlingClick(e:MouseEvent):Void {
        trace("Launching Starling game");
        starlingSingleton = new Starling(starling.display.Sprite, stage, new Rectangle(0, 0, 1920, 1080));
        starlingSingleton.supportHighResolutions = true;
        starlingSingleton.addEventListener(Event.ROOT_CREATED, onStarlingRootCreated);
    }

    private function onStarlingRootCreated(event:Event):Void {
        destroyUI();
        starlingSingleton.removeEventListener(Event.ROOT_CREATED, onStarlingRootCreated);
        starlingSingleton.start();
        Starling.current.stage.color = 0x000000;

        SceneManager.getInstance().switchScene(new StarlingLogoState());
    }

    private function destroyUI():Void {
        if (flixelButton != null) {
            flixelButton.removeEventListener(MouseEvent.CLICK, onFlixelClick);
        }
        if (starlingButton != null) {
            starlingButton.removeEventListener(MouseEvent.CLICK, onStarlingClick);
        }
        if (stage != null) {
            stage.removeEventListener(Event.RESIZE, onResize);
        }

        if (uiContainer != null && contains(uiContainer)) {
            removeChild(uiContainer);
        }

        background = null;
        flixelButton = null;
        starlingButton = null;
        uiContainer = null;
    }
    
    /**
     * 当所有系统准备就绪时调用
     */
    private function onSystemsReady():Void
    {
        trace("Main: All systems ready - multi-threaded loading complete");
        
        // 可以在这里执行需要等待加载完成的操作
        // 例如：预缓存某些数据、初始化高级功能等
        
        // 输出性能统计
        if (TrailParticlePool.instance != null)
        {
            var stats = TrailParticlePool.instance.getPoolStats();
            trace("Main: TrailParticlePool ready - " + stats.available + " particles available");
        }
    }
}