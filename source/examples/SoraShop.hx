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
import flixel.FlxCamera;
import utils.SettingsData;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;

class SoraShop extends FlxState
{
    private var backButton:FlxButton;
    private var bgMusic:flixel.sound.FlxSound;
    private var sfx1:flixel.sound.FlxSound;
    private var isTransitioning:Bool = false;
    
    // UI相机
    private var uiCamera:FlxCamera;
    // 显示缩放值的文本
    private var zoomText:FlxText;
    
    // 摄像机控制变量
    private var cameraTargetPos:FlxPoint;
    private var cameraTargetZoom:Float = 1.0;
    private var minZoom:Float = 0.5;
    private var maxZoom:Float = 100.0;
    private var zoomSpeed:Float = 0.01;
    private var moveSpeed:Float = 5.0;
    
    private var animationTimer:Float = 0;
    private var hasSwitchedAnimation:Bool = false;
    private var hasPlayedIntro:Bool = false;

    private var shop:SkeletonSprite;

    private var dialogText:FlxTypeText;
    private var dialogBackground:FlxSprite;
    private var dialogTimer:Float = 0;
    private var currentDialogIndex:Int = 0;
    private var dialogFinished:Bool = false;
    
    // 随机选择的登录效果
    private var selectedIntroType:Int = 0;

    private var itemBackground:FlxSprite;
    private var itemBGTween:FlxTween;

    // Spine资源
    private var atlas:TextureAtlas;
    private var skeletonData:SkeletonData;
    private var animationStateData:AnimationStateData;
    
    // 碰撞箱
    private var headTouchHitbox:FlxSprite;
    private var eyeFollowHitbox:FlxSprite;
    private var talkHitbox:FlxSprite; // 对话碰撞箱
    
    // Talk相关变量
    private var talkOrder:Array<Int> = [7, 2, 3, 4, 1, 5, 6];
    private var currentTalkIndex:Int = 0;
    private var isPlayingTalk:Bool = false;
    private var talkFinished:Bool = true;
    private var talkCooldown:Float = 0;
    private var talkCooldownTimer:Float = 0;
    private var hasCompletedFirstRound:Bool = false;
    private var usedRandomIndices:Array<Int> = [];

    // 第一种效果的对话内容
    private var dialogs1:Array<{text:String, time:Float, cumulative:Bool}> = [
        {text: "い", time: 0.1, cumulative: true},
        {text: "、い", time: 1.0, cumulative: true},
        {text: "、いらっしゃいませ！", time: 2.0, cumulative: true},
        {text: " …先生！", time: 4.0, cumulative: true}
    ];
    
    // 第二种效果的对话内容
    private var dialogs2:Array<{text:String, time:Float, cumulative:Bool}> = [
        {text: "暇だなぁ…。", time: 0.3, cumulative: true},
        {text: "…え", time: 3.8, cumulative: true},
        {text: "、うわあ！?", time: 4.35, cumulative: true},
        {text: "い、いつから来てました？！", time: 5.4, cumulative: true}
    ];
    
    // Talk对话内容
    private var talkDialogs:Map<Int, String>;

    // 当前使用的对话数组
    private var currentDialogs:Array<{text:String, time:Float, cumulative:Bool}>;

    private var cumulativeText:String = "";

	private var wasMousePressed:Bool = false;
	
	// 用于存储渐隐tween的变量
	private var dialogBackgroundTween:FlxTween;
	private var dialogTextTween:FlxTween;
	
	// 骨骼控制相关变量
	private var touchPointBone:spine.Bone;
	private var touchEyeBone:spine.Bone;
	private var isTouchingHead:Bool = false;
	private var isFollowingMouse:Bool = false;
	private var touchPointOriginalPos:Array<Float> = [0, 0];
	private var touchEyeOriginalPos:Array<Float> = [0, 0];
	private var touchPointRadius:Float = 5;    // 头部触摸骨骼移动限制（改为5）
	private var touchEyeRadius:Float = 6;      // 眼睛跟随骨骼移动限制
	
	// 平滑回归变量 - 改为使用单独变量而不是数组
	private var touchPointTween:FlxTween;
	private var touchEyeTween:FlxTween;
	private var touchPointCurrentX:Float = 0;
	private var touchPointCurrentY:Float = 0;
	private var touchEyeCurrentX:Float = 0;
	private var touchEyeCurrentY:Float = 0;
	
	// 回归标志
	private var isReturningHead:Bool = false;
	private var isReturningEye:Bool = false;

    override public function create():Void
    {
        FlxG.cameras.bgColor = 0xff000000;
        FlxG.autoPause = SettingsData.instance.autoPause;

        var atlasFile = Assets.getText("assets/spr/BlueArchive/sora_shop.atlas");
        var skeletonFile = Assets.getBytes("assets/spr/BlueArchive/sora_shop.skel");

        atlas = new TextureAtlas(atlasFile, new FlixelTextureLoader("assets/spr/BlueArchive/sora_shop.png"));
        skeletonData = SkeletonData.from(skeletonFile, atlas, .1);

        animationStateData = new AnimationStateData(skeletonData);

        shop = new SkeletonSprite(skeletonData, animationStateData);

		if (SettingsData.instance.languagePlus == "Simplified_Chinese") {
			talkDialogs = [
				1 => "呀！请，请您别碰我的额头！",
				2 => "我，我觉得……执行任务，应该要做好充分的准备！",
				3 => "所以……还是建议您多买一点！大家都说，在我们店里买东西很划算！",
				4 => "呃，老师，您一直这么盯着我看，我会不好意思的……！",
				5 => "可以请您……给我看一下大人的卡片吗？",
				6 => "可，可是……我觉得我们店的价格真的很良心了！",
				7 => "一天24小时，您随时都可以来光顾！毕竟这里算是便利店嘛！"
			];
		} else {
			talkDialogs = [
				1 => "ひぁっ！お、おでこは 触らないでください！",
				2 => "任務には…その、 じゅ、充分な準備が必要だと 思います！",
				3 => "ですから…いっぱい買った方が いいですよ！うちのお店の物は買った方が 絶対にお得ですって！",
				4 => "あ、あの、そんなにじっと 見つめられると 困ってしまうのですが…！",
				5 => "大人のカード…見せていただいても よろしいでしょうか？",
				6 => "で、ですが…うちのお店は！ すごく良心的なお値段ですから！",
				7 => "24時間！いつでも訪問してください！ コンビニみたいなものですから！"
			];
		}

        // 随机选择登录效果
        selectedIntroType = FlxG.random.int(0, 1);
        //shop.state.setAnimationByName(0, "Idle_01", true);

        if (selectedIntroType == 0) {
            // 第一种效果
            shop.state.setAnimationByName(0, "Start02_Idle_01", false);
            currentDialogs = dialogs1;
        } else {
            // 第二种效果
            shop.state.setAnimationByName(0, "Start01_Idle_01", false);
            currentDialogs = dialogs2;
        }
        //shop.state.setAnimationByName(0, "Idle_01", true);

		animationStateData.defaultMix = 0.4;

        shop.screenCenter();
        add(shop);
        
        // 初始化骨骼控制
        setupBoneControl();

        // 创建头部触摸碰撞箱
        headTouchHitbox = new FlxSprite(0, 0).makeGraphic(100, 100, FlxColor.fromRGB(255, 0, 0, 100));
        headTouchHitbox.screenCenter();
        headTouchHitbox.x -= 50;
        headTouchHitbox.y -= 100;
        headTouchHitbox.visible = true; // 设置为半透明可见，便于测试
        add(headTouchHitbox);
        
        // 创建眼睛跟随碰撞箱（全屏）
        eyeFollowHitbox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 255, 0, 50));
        eyeFollowHitbox.visible = true; // 设置为半透明可见，便于测试
        add(eyeFollowHitbox);
        
        // 创建对话碰撞箱
        talkHitbox = new FlxSprite(0, 0).makeGraphic(95, 140, FlxColor.fromRGB(0, 191, 255, 100));
        talkHitbox.screenCenter();
        talkHitbox.x -= 67;
        talkHitbox.y += 2;
        talkHitbox.visible = true; // 设置为半透明可见，便于测试
        add(talkHitbox);

        // 初始化摄像机位置
        cameraTargetPos = FlxPoint.get(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
        
        // 创建UI相机
        uiCamera = new FlxCamera();
        uiCamera.bgColor = 0; // 透明背景
        uiCamera.setPosition(0, 0);
        uiCamera.width = FlxG.width;
        uiCamera.height = FlxG.height;
        FlxG.cameras.add(uiCamera, false); // 添加到相机列表但不设为默认
        
		// 创建对话背景（带3像素描边）
		dialogBackground = new FlxSprite();
		var dialogWidth:Int = Std.int(FlxG.width / 2);
		var dialogHeight:Int = 120;
		dialogBackground.makeGraphic(dialogWidth, dialogHeight, FlxColor.TRANSPARENT);

		// 先绘制描边（3像素粗，颜色#2F4F4F）
		FlxSpriteUtil.drawRoundRect(dialogBackground, 20, 20, // 位置
			dialogWidth - 40, dialogHeight - 40, // 尺寸
			20, 20, // 圆角半径
			FlxColor.fromString('#2F4F4F') // 描边颜色
		);

		// 再绘制内部矩形（比外部小3像素，形成描边效果）
		FlxSpriteUtil.drawRoundRect(dialogBackground, 23, 23, // 向内偏移3像素
			dialogWidth - 46, dialogHeight - 46, // 宽高各减少6像素
			17, 17, // 稍微调整圆角半径
			FlxColor.WHITE // 内部颜色
		);

		dialogBackground.alpha = 0.5;
		dialogBackground.color = FlxColor.fromString('#87CEFA');
		dialogBackground.x = 140;
		dialogBackground.y = FlxG.height - 220;
		dialogBackground.camera = uiCamera;
		dialogBackground.visible = false;
		add(dialogBackground);

		// 创建对话文本（带3像素描边）
		dialogText = new FlxTypeText(0, 0, Std.int(FlxG.width / 2) - 100, "", 24);
		dialogText.color = FlxColor.BLACK;
		dialogText.setFormat("ResourceHanRoundedCN-Bold.ttf", 24);
		dialogText.borderStyle = OUTLINE; // 设置边框样式
		dialogText.borderSize = 3; // 设置边框大小
		dialogText.borderColor = FlxColor.fromString('#2F4F4F'); // 设置边框颜色
		dialogText.delay = 0.05;
		dialogText.showCursor = false;
		dialogText.screenCenter();
		dialogText.x = dialogBackground.x + 40;
		dialogText.y = dialogBackground.y + 40;
		dialogText.camera = uiCamera;
		dialogText.visible = false;
		add(dialogText);
        
		// 创建物品背景（带描边效果）
		itemBackground = new FlxSprite();
		var bgWidth:Int = Std.int(FlxG.width / 2.3);
		var bgHeight:Int = Std.int(FlxG.height / 1.5);
		itemBackground.makeGraphic(bgWidth, bgHeight, FlxColor.TRANSPARENT);

		// 先绘制描边（5像素粗，颜色#2F4F4F）
		FlxSpriteUtil.drawRoundRect(itemBackground, 0, 0, // 从左上角开始绘制
			bgWidth, bgHeight, // 使用完整尺寸
			40, 40, // 圆角半径
			FlxColor.fromString('#2F4F4F') // 描边颜色
		);

		// 再绘制内部矩形（比外部小5像素，形成描边效果）
		FlxSpriteUtil.drawRoundRect(itemBackground, 5, 5, // 向内偏移5像素
			bgWidth - 10, bgHeight - 10, // 宽高各减少10像素
			35, 35, // 稍微调整圆角半径
			FlxColor.WHITE // 内部颜色
		);

		itemBackground.alpha = 0.15;
		itemBackground.color = FlxColor.fromString('#000000');
		itemBackground.x = Std.int(FlxG.width) + 200;
		itemBackground.y = 150;
		itemBackground.camera = uiCamera;
		add(itemBackground);

		itemBGTween = FlxTween.tween(itemBackground, {x: Std.int(FlxG.width / 2)}, 0.7, {ease: FlxEase.backOut});

        // 添加返回按钮
		backButton = new FlxButton(0, 0, "Back", () -> {
			if (isTransitioning)
				return;
			isTransitioning = true;

			// 淡出音乐
			if (bgMusic != null) {
				FlxTween.tween(bgMusic, {volume: 0}, 1.5, {
					ease: FlxEase.quadOut,
					onComplete: function(tween:FlxTween) {
						bgMusic.stop();
						bgMusic.destroy();
						bgMusic = null;
					}
				});
            }
            if (sfx1 != null) {
                FlxTween.tween(sfx1, {volume: 0}, 1.5, {
                    ease: FlxEase.quadOut,
                    onComplete: function(tween:FlxTween) {
                        sfx1.stop();
                        sfx1.destroy();
                        sfx1 = null;
                    }
                });
            }

            if (itemBGTween != null) {
                itemBGTween.cancel();
                itemBGTween = null;
            }
            
            TransitionManager.switchState(MainMenuState);
		});
		backButton.setPosition(60, FlxG.height - 100);
		backButton.updateHitbox();
		backButton.label.scale.set(2, 2);
		backButton.scale.set(2, 2);

		backButton.camera = uiCamera;
		add(backButton);
        
        // 添加显示缩放值的文本
        zoomText = new FlxText(20, FlxG.height - 40, 200, "Cam Zoom: 1.00x", 16);
        zoomText.camera = uiCamera;
        add(zoomText);
        
        // 播放背景音乐
        bgMusic = FlxG.sound.play("assets/music/Theme_17.ogg", SettingsData.instance.masterVolume * SettingsData.instance.musicVolume * 0.6, true);
        bgMusic.persist = true;

        super.create();
    }

	// 设置骨骼控制
	private function setupBoneControl():Void {
		// 查找触摸点和眼睛骨骼
		touchPointBone = shop.skeleton.findBone("Touch_Point");
		touchEyeBone = shop.skeleton.findBone("Touch_Eye");
		
		if (touchPointBone != null) {
			touchPointOriginalPos = [touchPointBone.x, touchPointBone.y];
			touchPointCurrentX = touchPointBone.x;
			touchPointCurrentY = touchPointBone.y;
		}
		
		if (touchEyeBone != null) {
			touchEyeOriginalPos = [touchEyeBone.x, touchEyeBone.y];
			touchEyeCurrentX = touchEyeBone.x;
			touchEyeCurrentY = touchEyeBone.y;
		}
		
		// 设置骨骼更新前的回调
		shop.beforeUpdateWorldTransforms = function(skeletonSprite:SkeletonSprite) {
			// 处理头部触摸
			if (isTouchingHead && touchPointBone != null) {
				var mouseWorldPos = FlxG.mouse.getWorldPosition();
				var point = [mouseWorldPos.x, mouseWorldPos.y];
				skeletonSprite.haxeWorldCoordinatesToBone(point, touchPointBone);
				
				// 计算基于距离差的偏移
				var dx = (point[0] - touchPointOriginalPos[0]) * 0.5; // 降低x轴变换
				var dy = (point[1] - touchPointOriginalPos[1]) * 0.15; // 降低y轴变换
				
				// 限制移动范围
				var distance = Math.sqrt(dx * dx + dy * dy);
				if (distance > touchPointRadius) {
					var angle = Math.atan2(dy, dx);
					dx = Math.cos(angle) * touchPointRadius;
					dy = Math.sin(angle) * touchPointRadius;
				}
				
				// 更新当前位置
				touchPointCurrentX = touchPointOriginalPos[0] + dx;
				touchPointCurrentY = touchPointOriginalPos[1] + dy;
				
				touchPointBone.x = touchPointCurrentX;
				touchPointBone.y = touchPointCurrentY;
			}
			
			// 处理眼睛跟随
			if (isFollowingMouse && touchEyeBone != null) {
				var mouseWorldPos = FlxG.mouse.getWorldPosition();
				var point = [mouseWorldPos.x, mouseWorldPos.y];
				skeletonSprite.haxeWorldCoordinatesToBone(point, touchEyeBone);
				
				// 计算基于距离差的偏移
				var dx = (point[0] - touchEyeOriginalPos[0]) * 0.3; // 降低x轴变换
				var dy = (point[1] - touchEyeOriginalPos[1]) * 0.08; // 降低y轴变换
				
				// 限制移动范围
				var distance = Math.sqrt(dx * dx + dy * dy);
				if (distance > touchEyeRadius) {
					var angle = Math.atan2(dy, dx);
					dx = Math.cos(angle) * touchEyeRadius;
					dy = Math.sin(angle) * touchEyeRadius;
				}
				
				// 更新当前位置
				touchEyeCurrentX = touchEyeOriginalPos[0] + dx;
				touchEyeCurrentY = touchEyeOriginalPos[1] + dy;
				
				touchEyeBone.x = touchEyeCurrentX;
				touchEyeBone.y = touchEyeCurrentY;
			}
		};
	}

	// 平滑回归到默认位置 - 修复版本
	private function smoothReturnToDefault(isHead:Bool):Void {
		if (isHead && touchPointBone != null) {
			// 取消之前的补间
			if (touchPointTween != null) {
				touchPointTween.cancel();
			}
			
			// 设置回归标志
			isReturningHead = true;
			
			// 创建新的补间，0.5秒内回到默认位置
			touchPointTween = FlxTween.tween(
				this, 
				{ 
					touchPointCurrentX: touchPointOriginalPos[0],
					touchPointCurrentY: touchPointOriginalPos[1]
				}, 
				0.5, 
				{
					ease: FlxEase.quadOut,
					onUpdate: function(tween:FlxTween) {
						if (isTransitioning) {
							tween.cancel();
							return;
						}
						touchPointBone.x = touchPointCurrentX;
						touchPointBone.y = touchPointCurrentY;
					},
					onComplete: function(tween:FlxTween) {
						if (isTransitioning) return;
						isReturningHead = false;
						// 回归完成后播放Idle动画
						shop.state.setAnimationByName(0, "Idle_01", true);
					}
				}
			);
		} else if (!isHead && touchEyeBone != null) {
			// 取消之前的补间
			if (touchEyeTween != null) {
				touchEyeTween.cancel();
			}
			
			// 设置回归标志
			isReturningEye = true;
			
			// 创建新的补间，0.5秒内回到默认位置
			touchEyeTween = FlxTween.tween(
				this, 
				{ 
					touchEyeCurrentX: touchEyeOriginalPos[0],
					touchEyeCurrentY: touchEyeOriginalPos[1]
				}, 
				0.5, 
				{
					ease: FlxEase.quadOut,
					onUpdate: function(tween:FlxTween) {
						if (isTransitioning) {
							tween.cancel();
							return;
						}
						touchEyeBone.x = touchEyeCurrentX;
						touchEyeBone.y = touchEyeCurrentY;
					},
					onComplete: function(tween:FlxTween) {
						if (isTransitioning) return;
						isReturningEye = false;
						// 回归完成后播放Idle动画
						shop.state.setAnimationByName(0, "Idle_01", true);
					}
				}
			);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// 摄像机控制
		handleCameraControls(elapsed);
        
		// 更新Talk冷却计时器
		if (talkCooldownTimer > 0) {
			talkCooldownTimer -= elapsed;
			if (talkCooldownTimer <= 0) {
				talkFinished = true;
			}
		}

		// 检测鼠标点击
		var mousePressed = FlxG.mouse.pressed;
		var mouseWorldPos = FlxG.mouse.getWorldPosition();

		// 检查鼠标是否在头部触摸碰撞箱上
		var mouseOverHead = headTouchHitbox.overlapsPoint(mouseWorldPos);
		
		// 检查鼠标是否在眼睛跟随碰撞箱上（全屏）
		var mouseOverEye = eyeFollowHitbox.overlapsPoint(mouseWorldPos);
		
		// 检查鼠标是否在对话碰撞箱上
		var mouseOverTalk = talkHitbox.overlapsPoint(mouseWorldPos);

		// 检测鼠标点击事件
		if (mousePressed && !wasMousePressed) {
			if (mouseOverHead && !isTouchingHead && !isFollowingMouse && !isReturningHead && !isReturningEye) {
				// 开始头部触摸
				isTouchingHead = true;
				trace("开始头部触摸");
				
				// 取消任何正在进行的回归动画
				if (touchPointTween != null) {
					touchPointTween.cancel();
					touchPointTween = null;
				}
				isReturningHead = false;
				
				// 播放头部触摸动画
				shop.state.setAnimationByName(1, "Pat_01_M", true);
			} else if (mouseOverEye && !isFollowingMouse && !isTouchingHead && !isReturningHead && !isReturningEye) {
				// 开始眼睛跟随
				isFollowingMouse = true;
				trace("开始眼睛跟随");
				
				// 取消任何正在进行的回归动画
				if (touchEyeTween != null) {
					touchEyeTween.cancel();
					touchEyeTween = null;
				}
				isReturningEye = false;
				
				// 播放眼睛跟随动画
				shop.state.setAnimationByName(1, "Look_01_M", true);
			} else if (mouseOverTalk && talkFinished && !isPlayingTalk && hasSwitchedAnimation) {
				// 开始对话
				playNextTalk();
			}
		}

		// 检测鼠标释放事件
		if (!mousePressed && wasMousePressed) {
			if (isTouchingHead) {
				// 结束头部触摸
				isTouchingHead = false;
				trace("结束头部触摸");
				
				// 播放头部触摸结束动画
				shop.state.setAnimationByName(1, "PatEnd_01_A", false);
				
				// 平滑回归到默认位置
				smoothReturnToDefault(true);
			}
			
			if (isFollowingMouse) {
				// 结束眼睛跟随
				isFollowingMouse = false;
				trace("结束眼睛跟随");
				
				// 播放眼睛跟随结束动画
				shop.state.setAnimationByName(1, "LookEnd_01_A", false);
				
				// 平滑回归到默认位置
				smoothReturnToDefault(false);
			}
		}

		wasMousePressed = mousePressed;

		if (!hasPlayedIntro) {
			cameraTargetZoom = 6;

			animationTimer += elapsed;

			// 根据选择的登录效果设置不同的音频播放时间
			var soundPlayTime:Float = (selectedIntroType == 0) ? 1.55 : 0;

			if (animationTimer >= soundPlayTime) {
				// 根据选择的登录效果播放不同的音频
				var voicePath:String = getVoicePath((selectedIntroType == 0) ? "Sora_Shop_In_1.ogg" : "Sora_Shop_In_2.ogg");
				trace("Playing voice: " + voicePath);
				
				if (Assets.exists(voicePath)) {
					sfx1 = FlxG.sound.play(voicePath, SettingsData.instance.masterVolume * SettingsData.instance.sfxVolume * 0.8, false);
				} else {
					trace("Voice file not found: " + voicePath);
				}
				
				hasPlayedIntro = true;
				// 重置对话计时器
				dialogTimer = 0;
				currentDialogIndex = 0;
				dialogFinished = false;
			}
		}

		// 更新计时器
		if (!hasSwitchedAnimation) {
			animationTimer += elapsed;
			// 根据选择的登录效果设置不同的切换动画时间
			var switchTime:Float = (selectedIntroType == 0) ? 11.05 : 9.5;
			if (animationTimer >= switchTime) {
				// 切换动画
				shop.state.setAnimationByName(0, "Idle_01", true);
				hasSwitchedAnimation = true;
			}
		}

		// 处理对话显示
		if (hasPlayedIntro && !dialogFinished) {
			dialogTimer += elapsed;

			// 检查是否需要显示下一段对话
			if (currentDialogIndex < currentDialogs.length && dialogTimer >= currentDialogs[currentDialogIndex].time) {
				// 显示对话背景和文本
				dialogBackground.visible = true;
				dialogText.visible = true;

				// 累积文本
				if (currentDialogs[currentDialogIndex].cumulative) {
					cumulativeText += currentDialogs[currentDialogIndex].text;
				} else {
					cumulativeText = currentDialogs[currentDialogIndex].text;
				}

				// 设置并开始显示文本
				dialogText.resetText(cumulativeText);
				dialogText.start(0.02, false, false, null, null);

				currentDialogIndex++;

				// 如果已经是最后一段对话，标记对话完成
				if (currentDialogIndex >= currentDialogs.length) {
					dialogFinished = true;

					// 4秒后隐藏对话
					FlxTween.tween(dialogBackground, {alpha: 0}, 1.0, {
						startDelay: 4.0,
						onComplete: function(tween:FlxTween) {
							dialogBackground.visible = false;
							dialogText.visible = false;
						}
					});
					FlxTween.tween(dialogText, {alpha: 0}, 1.0, {
						startDelay: 4.0
					});
				}
			}
		}

		// 更新缩放显示文本
		zoomText.text = "Cam Zoom: " + FlxMath.roundDecimal(FlxG.camera.zoom, 2) + "x";
	}

	// 播放下一个Talk
	private function playNextTalk():Void {
		trace("playNextTalk called - isPlayingTalk: " + isPlayingTalk + ", talkFinished: " + talkFinished);

		if (isPlayingTalk || !talkFinished) {
			trace("Cannot play next talk - already playing or cooldown active");
			return;
		}

		isPlayingTalk = true;
		talkFinished = false;

		var talkNum:Int;

		if (!hasCompletedFirstRound) {
			trace("Playing first round talk in order");
			// 第一轮按顺序播放
			talkNum = talkOrder[currentTalkIndex];
			trace("Selected talk number from order: " + talkNum + " (index: " + currentTalkIndex + ")");
			currentTalkIndex++;

			if (currentTalkIndex >= talkOrder.length) {
				trace("First round completed, switching to random mode");
				hasCompletedFirstRound = true;
				currentTalkIndex = 0;
			}
		} else {
			trace("Playing random talk from second round");
			// 第二轮及以后随机播放，但不重复上一次
			var availableIndices = [];
			for (i in 0...talkOrder.length) {
				if (!usedRandomIndices.contains(i)) {
					availableIndices.push(i);
				}
			}

			trace("Available indices: " + availableIndices + ", used indices: " + usedRandomIndices);

			// 如果所有索引都已使用，重置
			if (availableIndices.length == 0) {
				trace("All indices used, resetting used indices");
				usedRandomIndices = [];
				availableIndices = [for (i in 0...talkOrder.length) i];
			}

			var randomIndex = availableIndices[FlxG.random.int(0, availableIndices.length - 1)];
			usedRandomIndices.push(randomIndex);
			talkNum = talkOrder[randomIndex];
			trace("Selected random talk number: " + talkNum + " (index: " + randomIndex + ")");
		}

		// 播放Talk动画
		trace("Setting animation: Talk_0" + talkNum + "_A and Talk_0" + talkNum + "_M");
		try {
			shop.state.setAnimationByName(1, 'Talk_0${talkNum}_A', false);
			shop.state.setAnimationByName(2, 'Talk_0${talkNum}_M', false);
			trace("Animation set successfully");
		} catch (e:Dynamic) {
			trace("Error setting animation: " + e);
			handleTalkComplete();
			return;
		}

		// 停止并清理之前的音频
		trace("Cleaning up previous audio if exists");
		if (sfx1 != null) {
			try {
				trace("Stopping previous audio");
				// 移除所有回调以防止循环引用
				sfx1.stop();
				sfx1.destroy();
				sfx1 = null;
				trace("Previous audio cleaned up");
			} catch (e:Dynamic) {
				trace("Error cleaning up previous audio: " + e);
				sfx1 = null; // 强制设为null
			}
		}

		// 播放Talk语音
		var voicePath = getVoicePath('Sora_Shop_Talk_$talkNum.ogg');
		trace("Voice path: " + voicePath);

		// 确保音频文件存在
		trace("Checking if voice file exists");
		if (Assets.exists(voicePath)) {
			trace("Voice file exists, will play after 0.7s delay");

			// 使用FlxTimer延迟0.7秒播放音频
			new flixel.util.FlxTimer().start(0.7, function(timer:flixel.util.FlxTimer) {
				if (isTransitioning) {
					trace("Transition in progress, skipping audio playback");
					return;
				}

				trace("Playing voice after 0.7s delay");
				try {
					sfx1 = FlxG.sound.play(voicePath, SettingsData.instance.masterVolume * SettingsData.instance.sfxVolume * 0.8, false);

					if (sfx1 != null) {
						trace("Voice playback started successfully after delay");

						// 存储当前状态的引用
						var currentState = this;

						// 语音播放完毕后2.5秒切换回Idle
						sfx1.onComplete = function() {
							trace("Voice playback completed");

							if (currentState.isTransitioning) {
								trace("Transition in progress, skipping talk completion");
								return;
							}

							// 使用FlxTimer而不是haxe.Timer
							new flixel.util.FlxTimer().start(2.5, function(timer:flixel.util.FlxTimer) {
								if (currentState.isTransitioning) {
									trace("State destroyed or transitioning, skipping final steps");
									return;
								}

								trace("Talk cooldown completed");
								if (!currentState.isTransitioning) {
									trace("Setting idle animation");
									// 注意: 这里可能需要检查shop是否存在
									if (currentState.shop != null && currentState.shop.state != null) {
										currentState.shop.state.setAnimationByName(0, "Idle_01", true);
									}
								}
								currentState.isPlayingTalk = false;
								currentState.talkCooldownTimer = 0.5; // 额外0.5秒冷却，确保动画切换完成
								trace("Talk state reset - isPlayingTalk: false, talkCooldownTimer: 0.5");
								
								// 音频播放完毕后开始渐隐文本和背景框
								if (currentState.dialogBackground.visible && currentState.dialogText.visible) {
									trace("Starting dialog fade out after audio completion");
									
									// 取消之前的渐隐tween（如果有）
									if (currentState.dialogBackgroundTween != null) {
										currentState.dialogBackgroundTween.cancel();
									}
									if (currentState.dialogTextTween != null) {
										currentState.dialogTextTween.cancel();
									}
									
									// 创建新的渐隐tween
									currentState.dialogBackgroundTween = FlxTween.tween(currentState.dialogBackground, {alpha: 0}, 1.0, {
										onComplete: function(tween:FlxTween) {
											currentState.dialogBackground.visible = false;
										}
									});
									
									currentState.dialogTextTween = FlxTween.tween(currentState.dialogText, {alpha: 0}, 1.0, {
										onComplete: function(tween:FlxTween) {
											currentState.dialogText.visible = false;
										}
									});
								}
							});
						};
					} else {
						trace("Voice playback returned null after delay, using fallback");
						// 如果音频播放失败，直接执行完成逻辑
						handleTalkComplete();
					}
				} catch (e:Dynamic) {
					trace("Error playing voice after delay: " + e);
					handleTalkComplete();
				}
			});
		} else {
			trace("Voice file not found: " + voicePath);
			// 如果没有语音文件，直接执行完成逻辑
			handleTalkComplete();
		}

		// 显示对话
		if (talkDialogs.exists(talkNum)) {
			showTalkDialog(talkDialogs[talkNum]);
			trace("Showing talk dialog: " + talkDialogs[talkNum]);
		} else {
			trace("No dialog found for talk number: " + talkNum);
		}
	}

	// 处理Talk完成逻辑
	private function handleTalkComplete():Void {
		trace("handleTalkComplete called");
		if (isTransitioning) {
			trace("Transition in progress, skipping talk completion");
			return;
		}

		// 使用FlxTimer而不是haxe.Timer
		new flixel.util.FlxTimer().start(2.5, function(timer:flixel.util.FlxTimer) {
			if (isTransitioning) {
				trace("Transition in progress during fallback completion, skipping");
				return;
			}

			trace("Fallback talk cooldown completed");
			if (!isTransitioning) {
				trace("Setting idle animation (fallback)");
				if (shop != null && shop.state != null) {
					shop.state.setAnimationByName(0, "Idle_01", true);
				}
			}
			isPlayingTalk = false;
			talkCooldownTimer = 0.5;
			trace("Talk state reset (fallback) - isPlayingTalk: false, talkCooldownTimer: 0.5");
			
			// 音频播放完毕后开始渐隐文本和背景框（fallback情况）
			if (dialogBackground.visible && dialogText.visible) {
				trace("Starting dialog fade out after audio completion (fallback)");
				
				// 取消之前的渐隐tween（如果有）
				if (dialogBackgroundTween != null) {
					dialogBackgroundTween.cancel();
				}
				if (dialogTextTween != null) {
					dialogTextTween.cancel();
				}
				
				// 创建新的渐隐tween
				dialogBackgroundTween = FlxTween.tween(dialogBackground, {alpha: 0}, 1.0, {
					onComplete: function(tween:FlxTween) {
						dialogBackground.visible = false;
					}
				});
				
				dialogTextTween = FlxTween.tween(dialogText, {alpha: 0}, 1.0, {
					onComplete: function(tween:FlxTween) {
						dialogText.visible = false;
					}
				});
			}
		});
	}
    
    // 显示Talk对话
    private function showTalkDialog(text:String):Void {
        dialogBackground.visible = true;
        dialogText.visible = true;
        dialogBackground.alpha = 0.5;
        dialogText.alpha = 1;
        
        // 取消之前的渐隐tween（如果有）
        if (dialogBackgroundTween != null) {
            dialogBackgroundTween.cancel();
        }
        if (dialogTextTween != null) {
            dialogTextTween.cancel();
        }
        
        dialogText.resetText(text);
        dialogText.start(0.02, false, false, null, function() {
            // 文本显示完成后不再自动隐藏对话框，等待音频播放完毕
            trace("Text display completed, waiting for audio to finish before fading out");
        });
    }
    
	// 辅助函数：获取语音文件路径
	private function getVoicePath(filename:String):String {
		var basePath = "assets/vocals/Sora_Shop/";
		var language = SettingsData.instance.languagePlus;

		// 仅当语言为简体中文时使用CN目录，其他情况使用JP目录
		if (language == "Simplified_Chinese") {
			return basePath + "CN/" + filename;
		} else {
			return basePath + "JP/" + filename;
		}
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
        if (FlxG.keys.pressed.Q) {
            cameraTargetZoom += zoomSpeed;
            if (cameraTargetZoom > maxZoom) cameraTargetZoom = maxZoom;
        }
        if (FlxG.keys.pressed.E) {
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
        // 取消所有Tween
        if (itemBGTween != null) {
            itemBGTween.cancel();
            itemBGTween = null;
        }
        
        if (touchPointTween != null) {
            touchPointTween.cancel();
            touchPointTween = null;
        }
        
        if (touchEyeTween != null) {
            touchEyeTween.cancel();
            touchEyeTween = null;
        }
        
        // 停止并销毁音乐
        if (bgMusic != null) {
            bgMusic.stop();
            bgMusic.destroy();
            bgMusic = null;
        }
        if (sfx1 != null) {
            sfx1.stop();
            sfx1.destroy();
            sfx1 = null;
        }
        
        // 清理Spine资源
        if (shop != null) {
            shop.destroy();
            shop = null;
        }
        
        if (cameraTargetPos != null) {
            cameraTargetPos.put();
            cameraTargetPos = null;
        }
        
        // 移除UI相机
        if (uiCamera != null) {
            FlxG.cameras.remove(uiCamera);
            uiCamera.destroy();
            uiCamera = null;
        }
        
        // 移除碰撞箱
        if (headTouchHitbox != null) {
            headTouchHitbox.destroy();
            headTouchHitbox = null;
        }
        if (eyeFollowHitbox != null) {
            eyeFollowHitbox.destroy();
            eyeFollowHitbox = null;
        }
        if (talkHitbox != null) {
            talkHitbox.destroy();
            talkHitbox = null;
        }
        
        // 取消对话框渐隐tween
        if (dialogBackgroundTween != null) {
            dialogBackgroundTween.cancel();
            dialogBackgroundTween = null;
        }
        if (dialogTextTween != null) {
            dialogTextTween.cancel();
            dialogTextTween = null;
        }
        
        // 重置状态变量
        isTransitioning = false;
        animationTimer = 0;
        hasSwitchedAnimation = false;
        hasPlayedIntro = false;
        dialogTimer = 0;
        currentDialogIndex = 0;
        dialogFinished = false;
        cumulativeText = "";
        isPlayingTalk = false;
        talkFinished = true;
        hasCompletedFirstRound = false;
        usedRandomIndices = [];
        isTouchingHead = false;
        isFollowingMouse = false;
        isReturningHead = false;
        isReturningEye = false;
        
        super.destroy();
    }
}