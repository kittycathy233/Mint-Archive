package examples;

import flixel.addons.transition.FlxTransitionableState;
import flixel.ui.FlxButton;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import spine.animation.AnimationStateData;
import spine.animation.AnimationState;
import openfl.Assets;
import spine.atlas.TextureAtlas;
import spine.SkeletonData;
import spine.flixel.SkeletonSprite;
import spine.flixel.FlixelTextureLoader;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import debug.TransitionManager;
import debug.TransitionSubState.TransitionType;
import player.MainMenuState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

class ReisaHome extends FlxTransitionableState
{
    private var backButton:FlxButton;
    private var bgMusic:flixel.sound.FlxSound;
    private var isTransitioning:Bool = false;
    
    // 摄像机控制变量
    private var cameraTargetPos:FlxPoint;
    private var cameraTargetZoom:Float = 1.0;
    private var minZoom:Float = 0.5;
    private var maxZoom:Float = 2.0;
    private var zoomSpeed:Float = 0.05;
    private var moveSpeed:Float = 5.0;
    
    override public function create():Void
    {
        FlxG.cameras.bgColor = 0xff000000;

        var atlasFile = Assets.getText("assets/spr/BlueArchive/CH0167_home.atlas");
        var skeletonFile = Assets.getBytes("assets/spr/BlueArchive/CH0167_home.skel");

        var atlas = new TextureAtlas(atlasFile, new FlixelTextureLoader("assets/spr/BlueArchive/CH0167_home.atlas"));
        var skeletonData = SkeletonData.from(skeletonFile, atlas, .5);

        var animationStateData = new AnimationStateData(skeletonData);

        var reisa = new SkeletonSprite(skeletonData, animationStateData);

        reisa.state.setAnimationByName(0, "Idle_01", true);

        reisa.screenCenter();
        add(reisa);

        // 初始化摄像机位置
        cameraTargetPos = FlxPoint.get(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
        
        // 添加返回按钮
        backButton = new FlxButton(0, 0, "Back", () -> {
            if (isTransitioning) return;
            isTransitioning = true;
            
            // 淡出音乐
            if (bgMusic != null) {
                FlxTween.tween(bgMusic, {volume: 0}, 1.5, {
                    ease: FlxEase.quadOut,
                    onComplete: function(tween:FlxTween) {
                        bgMusic.stop();
                        bgMusic.destroy();
                        bgMusic = null;
                        TransitionManager.switchState(MainMenuState);
                    }
                });
            } else {
                TransitionManager.switchState(MainMenuState);
            }
        });
        backButton.setPosition(20, 20);
        backButton.scale.set(1.5, 1.5);
        backButton.updateHitbox();
        add(backButton);
        
        // 播放背景音乐
        bgMusic = FlxG.sound.play("assets/music/Theme_09.ogg", 0.5, true);
        bgMusic.persist = true;

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 摄像机控制
        handleCameraControls(elapsed);
    }
    
    private function handleCameraControls(elapsed:Float):Void
    {
        // WASD控制摄像机移动
        if (FlxG.keys.pressed.W) {
            cameraTargetPos.y -= moveSpeed * elapsed * 100 / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.S) {
            cameraTargetPos.y += moveSpeed * elapsed * 100 / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.A) {
            cameraTargetPos.x -= moveSpeed * elapsed * 100 / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.D) {
            cameraTargetPos.x += moveSpeed * elapsed * 100 / FlxG.camera.zoom;
        }
        
        // Q/E控制缩放
        if (FlxG.keys.justPressed.Q) {
            cameraTargetZoom += zoomSpeed;
            if (cameraTargetZoom > maxZoom) cameraTargetZoom = maxZoom;
        }
        if (FlxG.keys.justPressed.E) {
            cameraTargetZoom -= zoomSpeed;
            if (cameraTargetZoom < minZoom) cameraTargetZoom = minZoom;
        }
        
        // 平滑应用摄像机变化
        FlxG.camera.scroll.x += (cameraTargetPos.x - FlxG.camera.scroll.x) * 0.2;
        FlxG.camera.scroll.y += (cameraTargetPos.y - FlxG.camera.scroll.y) * 0.2;
        FlxG.camera.zoom += (cameraTargetZoom - FlxG.camera.zoom) * 0.2;
    }
    
    override public function destroy():Void
    {
        if (bgMusic != null) {
            bgMusic.stop();
            bgMusic.destroy();
        }
        if (cameraTargetPos != null) {
            cameraTargetPos.put();
        }
        super.destroy();
    }
}