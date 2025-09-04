package starling.scenes;

import starling.display.Quad;
import starling.text.TextField;
import starling.core.Starling;
import starling.display.Sprite;

class SceneManager {
    private static var instance:SceneManager;

    private var currentScene:Sprite;

    private function new() {
        // Singleton pattern to ensure only one instance of SceneManager
    }

    public static function getInstance():SceneManager {
        if (instance == null) {
            instance = new SceneManager();
        }
        return instance;
    }

    public function switchScene(newScene:Scene):Void {
        if (currentScene != null) {
            currentScene.dispose();
            currentScene.removeFromParent(true);
        }
        currentScene = newScene;
        starling.core.Starling.current.stage.addChild(currentScene);
        newScene.load();
    }
}

class Scene extends Sprite {
    var juggler = new starling.animation.Juggler();

    public var background:Quad;

    public function new() {
        super();
        var stageWidth = Starling.current.stage.stageWidth;
        var stageHeight = Starling.current.stage.stageHeight;
        background = new Quad(stageWidth, stageHeight, 0x0);
        this.addChild(background);
        Starling.current.juggler.add(juggler);
    }

    public function load():Void {
        // Abstract method to be implemented by subclasses
    }

    public override function dispose():Void {
        juggler.purge();
        Starling.current.juggler.remove(juggler);
        super.dispose();
    }

    public function addText(text:String, x:Int = 10, y:Int = 10) {
        var textField = new TextField(250, 30, text);
        textField.x = x;
        textField.y = y;
        textField.format.color = 0xffffffff;
        addChild(textField);
        return textField;
    }
}