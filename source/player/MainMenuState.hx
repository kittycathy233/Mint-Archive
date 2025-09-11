package player;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import debug.TransitionManager;
import debug.TransitionSubState.TransitionType;
import hxvlc.flixel.FlxVideoSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import flixel.math.FlxRect;
import openfl.geom.Rectangle;
import openfl.display.Shape;
import openfl.geom.Point;
import options.OptionsState;

import examples.flixel.FlixelState;
import examples.ReisaHome;
import player.TestState;
import examples.SoraShop;
import BaseState;
import objects.CustomProgressBar;

class MainMenuState extends BaseState
{
    private var playButton:FlxButton;
    private var reisaButton:FlxButton;
    private var shopButton:FlxButton;
    private var settingsButton:FlxButton;

    private var bgMusic:flixel.sound.FlxSound;
    private var video:FlxVideoSprite;
    private var isTransitioning:Bool = false; // 防止多次点击
    
    // 新添加的UI元素
    private var loadingCircle:FlxSprite;
    private var loadingText:FlxText;
    private var customProgressBar:CustomProgressBar;
    private var progressValue:Float = 0;
    
    // 旋转动画计时器
    private var rotationTimer:Float = 0;
    private var circleGraphic:FlxGraphic;
    private var circleAngle:Float = 0;
    
    // 视频和音频路径变量
    private var videoPath:String = "assets/videos/title.mp4";
    private var musicPath:String = "assets/music/Theme_01.ogg";

    private var logo:FlxSprite;



    override public function create():Void 
    {
        FlxG.autoPause = SettingsData.instance.autoPause;

        super.create();

        // 调试输出当前标题主题
        trace("Current title theme: " + SettingsData.instance.titleTheme);

        video = new FlxVideoSprite(0, 0);
        video.antialiasing = SettingsData.instance.antialiasing;

		switch (SettingsData.instance.titleTheme) {
			case "1st_PV":
				videoPath = "assets/videos/title.mp4";
			case "2nd_PV":
				videoPath = "assets/videos/title_2nd_1.mp4";
			case "3rd_PV":
				videoPath = "assets/videos/title_3rd_1.mp4";
			case "4th_PV":
				videoPath = "assets/videos/title_4nd_1.mp4";
			case "4th_PV_2":
				videoPath = "assets/videos/title_4nd_2.mp4";
			case "4.5th_PV":
				videoPath = "assets/videos/title_4nd_Ep.mp4";
			case "5th_PV":
				videoPath = "assets/videos/title_5th_1.mp4";
			case "Custom":
                trace('WIP: Custom title theme video path');
			default:
				videoPath = "assets/videos/title.mp4";
		}

        // 视频格式设置完成时的回调
        video.bitmap.onFormatSetup.add(function():Void {
            if (video.bitmap != null && video.bitmap.bitmapData != null) {
                // 计算缩放比例，使视频覆盖整个屏幕
                final scale:Float = Math.max(
                    FlxG.width / video.bitmap.bitmapData.width, 
                    FlxG.height / video.bitmap.bitmapData.height
                );
                
                // 设置视频大小
                video.setGraphicSize(
                    Std.int(video.bitmap.bitmapData.width * scale), 
                    Std.int(video.bitmap.bitmapData.height * scale)
                );
                video.updateHitbox();
                video.screenCenter();
            }
        });

		video.bitmap.onEndReached.add(function() {
			#if mobile
			video.stop();
			if (videoPath != "" && video.load(videoPath)) FlxTimer.wait(0.001, () -> video.play());
			#else
			video.stop();
			video.play();
			#end
		});
        
        add(video);

        // 加载视频 - 使用您设置的视频路径
		if (videoPath != "" && video.load(videoPath, #if mobile // 为移动端添加特定的VLC选项
			[
				"--codec=avcodec",
				"--avcodec-hw=any",
				"--no-drop-late-frames",
				"--no-skip-frames"
			] #else null
		#end)) {
			FlxTimer.wait(0.001, () -> video.play());
		}

        switch (SettingsData.instance.titleTheme) {
			case "1st_PV":
                musicPath = "assets/music/Theme_01.ogg";
			case "2nd_PV":
                musicPath = "assets/music/Theme_42_Title.ogg";
			case "3rd_PV":
				musicPath = "assets/music/Theme_271_Title.ogg";
			case "4th_PV":
				musicPath = "assets/music/Theme_59.ogg";
			case "4th_PV_2":
				musicPath = "assets/music/Theme_59_Title.ogg";
			case "4.5th_PV":
				musicPath = "assets/music/Theme_154_Title.ogg";
			case "5th_PV":
				musicPath = "assets/music/Theme_152_Title.ogg";
			case "Custom":
                trace('WIP: Custom title theme audio path');
			default:
				musicPath = "assets/music/Theme_01.ogg";
		}

        // 播放背景音乐 - 使用您设置的音频路径
        if (musicPath != "") {
            bgMusic = FlxG.sound.play(musicPath, SettingsData.instance.masterVolume * SettingsData.instance.musicVolume * 0.8, true);
            bgMusic.persist = true; // 确保在状态切换时音乐不会停止
        }

        playButton = new FlxButton(0, 0, "Run TEST", onPlayClick);
        playButton.updateHitbox();
        playButton.scale.set(2, 2);
        playButton.label.scale.set(2, 2);
        playButton.screenCenter();
        playButton.y -= 40; // 向上移动一点，为Reisa按钮腾出空间
        playButton.x += 600;
        add(playButton);
        
        // 添加Reisa按钮
        reisaButton = new FlxButton(0, 0, "Run Reisa Test", onReisaClick);
        reisaButton.updateHitbox();
        reisaButton.scale.set(2, 2);
        reisaButton.label.scale.set(2, 2);
        reisaButton.screenCenter();
        reisaButton.y += 40; // 放在Play按钮下方
        reisaButton.x += 600;
        add(reisaButton);

        shopButton = new FlxButton(0, 0, "Run Shop Test", onShopClick);
        shopButton.updateHitbox();
        shopButton.scale.set(2, 2);
        shopButton.label.scale.set(2, 2);
        shopButton.screenCenter();
        shopButton.y += 120; // 放在Play按钮下方
        shopButton.x += 600;
        add(shopButton);
        
		// 添加设置按钮
		settingsButton = new FlxButton(0, 0, "Settings", onSettingsClick);
        settingsButton.updateHitbox();
		settingsButton.scale.set(2, 2);
        settingsButton.label.scale.set(2, 2);
		settingsButton.screenCenter();
		settingsButton.y += 200; // 放在Reisa按钮下方
        settingsButton.x += 600;
		add(settingsButton);

        // 创建加载UI元素
        createLoadingUI();

        logo = new FlxSprite(0, 0);
        logo.loadGraphic("assets/images/game/MArchiveLogo.png");
        logo.scale.set(0.9, 0.9);
        logo.alpha = 0.9;
        logo.x = FlxG.width - logo.width - 20;
        logo.y = 20;
        
        add(logo);

        FlxG.camera.bgColor = 0xFFA2A2A2;

        super.create();

		// 版本水印
		var versionText = new FlxText(0, 0, 0, "v" + Application.current.meta.get('version'), 24);
		versionText.setFormat(Assets.getFont("assets/fonts/vcr.ttf").fontName, 24, FlxColor.WHITE, RIGHT);
		versionText.x = FlxG.width - versionText.width - 28;
		versionText.y = FlxG.height - versionText.height - 28;
		versionText.alpha = 0.85;
		add(versionText);

    }
    
    private function createLoadingUI():Void
    {
        // 创建类似Android的旋转加载环
        loadingCircle = new FlxSprite();
        loadingCircle.x = 40;
        loadingCircle.y = FlxG.height - 80;
        createAndroidStyleSpinner();
        add(loadingCircle);
        
        // 创建自定义平行四边形进度条
        customProgressBar = new CustomProgressBar(20, FlxG.height - 50, 400, 25);
        
        // 设置天蓝色主题
        customProgressBar.setColorTheme(
            0x80404040, // 深灰50%透明背景
            0xFF87CEEB, // 天蓝色起始
            0xFF4169E1, // 皇家蓝结束
            FlxColor.WHITE // 白色文字
        );
        
        // 设置平行四边形倾斜角度
        customProgressBar.setSkewAngle(20);
        
        // 启用发光效果和文本显示
        customProgressBar.useGlowEffect = true;
        customProgressBar.useTextDisplay = true;
        customProgressBar.textFormat = "Loading... {progress}%";
        customProgressBar.animationDuration = 0.8;
        
        add(customProgressBar);
        
        // 创建加载文本
        loadingText = new FlxText(70, customProgressBar.y - 45, FlxG.width / 2, "(WIP) Welcome to Kivotos!", 16);
        loadingText.setFormat(null, 20, FlxColor.WHITE, LEFT);
        add(loadingText);

        // 鼠标拖尾效果已通过BaseState自动添加

        // 初始进度设置为0
        setProgress(0.08);
    }
    
    private function createAndroidStyleSpinner():Void
    {
        // 创建一个类似Android的旋转加载指示器
        var size:Int = 40;
        var thickness:Int = 4;
        var color:FlxColor = FlxColor.WHITE;
        
        // 创建一个BitmapData来绘制Android风格的旋转环
        var bmd:BitmapData = new BitmapData(size, size, true, FlxColor.TRANSPARENT);
        
        // 使用moveTo和lineTo绘制圆弧
        var centerX:Float = size / 2;
        var centerY:Float = size / 2;
        var radius:Float = size / 2 - thickness;
        var startAngle:Float = 0; // 起始角度
        var endAngle:Float = 270; // 结束角度（270度弧）
        
        // 创建一个Shape来绘制圆弧
        var shape:Shape = new Shape();
        shape.graphics.lineStyle(thickness, color, 1);
        
        // 计算圆弧上的点
        var points:Array<Point> = [];
        var angleStep:Float = 5; // 角度步长
        var angle:Float = startAngle;
        while (angle <= endAngle) {
            var rad:Float = angle * Math.PI / 180;
            var x:Float = centerX + radius * Math.cos(rad);
            var y:Float = centerY + radius * Math.sin(rad);
            points.push(new Point(x, y));
            angle += angleStep;
        }
        
        // 绘制圆弧
        if (points.length > 0) {
            shape.graphics.moveTo(points[0].x, points[0].y);
            for (i in 1...points.length) {
                shape.graphics.lineTo(points[i].x, points[i].y);
            }
        }
        
        // 绘制到BitmapData
        bmd.draw(shape);
        
        // 创建FlxGraphic
        if (circleGraphic != null) {
            circleGraphic.destroy();
        }
        circleGraphic = FlxGraphic.fromBitmapData(bmd);
        
        // 设置loadingCircle的图像
        loadingCircle.loadGraphic(circleGraphic);
        loadingCircle.origin.set(size / 2, size / 2);
        loadingCircle.offset.set(size / 2, size / 2);
    }
    
    private function setProgress(value:Float):Void
    {
        progressValue = Math.max(0, Math.min(1, value));
        if (customProgressBar != null)
        {
            customProgressBar.setProgress(progressValue, true);
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 更新旋转动画 - 更流畅的Android风格旋转
        rotationTimer += elapsed;
        circleAngle = rotationTimer * 180; // 每秒旋转180度
        loadingCircle.angle = circleAngle;
        
        // 每2秒重新创建一次环，以模拟Android的渐变效果
        if (Std.int(rotationTimer * 10) % 20 == 0) {
            createAndroidStyleSpinner();
            loadingCircle.angle = circleAngle; // 保持当前角度
        }

        // 鼠标拖尾更新已通过BaseState自动处理
        // 演示进度条动画效果 - 缓慢增加进度到100%
        if (progressValue < 1.0) {
            setProgress(progressValue + 0.01); // 每帧增加1%，大约100秒完成
        }
    }
	private function transitionToState(targetState:Class<FlxState>, transitionDuration:Float = 1.5):Void {
		// 防止多次点击
		if (isTransitioning)
			return;
		isTransitioning = true;

		// 禁用所有按钮以防止重复点击
		playButton.active = false;
		reisaButton.active = false;
		if (settingsButton != null)
			settingsButton.active = false;

		// 淡出音乐（如果有）
		if (bgMusic != null) {
			FlxTween.tween(bgMusic, {volume: 0}, transitionDuration, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween) {
					bgMusic.stop();
					bgMusic.destroy();
					bgMusic = null;
				}
			});
		}

		// 淡出视频（如果有）
		if (video != null) {
			FlxTween.tween(video, {alpha: 0}, transitionDuration, {
				ease: FlxEase.quadOut,
				onComplete: function(tween:FlxTween) {
					if (video != null) {
						video.bitmap.onEndReached.removeAll();
						video.stop();
						video.destroy();
						video = null;
					}
				}
			});
		}

		// 同时开始转场动画
		TransitionManager.switchState(targetState, TransitionType.CIRCLE_CLOSE, transitionDuration);
	}

	private function onPlayClick():Void {
		transitionToState(TestState);
	}

	private function onReisaClick():Void {
		transitionToState(ReisaHome);
	}

	private function onShopClick():Void {
		transitionToState(SoraShop);
	}

	private function onSettingsClick():Void {
		transitionToState(OptionsState, 1.0);
	}
    
    override public function destroy():Void
    {
        if (video != null) {
            video.bitmap.onEndReached.removeAll(); // 移除所有结束事件
            video.destroy();
            video = null;
        }
        if (bgMusic != null) {
            bgMusic.stop();
            bgMusic.destroy();
        }
        if (circleGraphic != null) {
            circleGraphic.destroy();
            circleGraphic = null;
        }
        super.destroy();
    }
}