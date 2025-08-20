package examples.Flixel;

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

class FlixelState extends FlxState
{
	var spineSprite:SkeletonSprite;
	var sprite:FlxSprite;
	var sprite2:FlxSprite;
	var myText:FlxText;
	var group:FlxSpriteGroup;
	var justSetWalking = false;

	var jumping = false;

	var scale = 4;
	var speed:Float;

	override public function create():Void
	{

		FlxG.cameras.bgColor = 0xff000000;

		
		//自己写的
		var atlasFile = Assets.getText("assets/CH0288_spr.atlas");
		var skeletonFile = Assets.getBytes("assets/CH0288_spr.skel");

		var atlas1 = new TextureAtlas(atlasFile, new FlixelTextureLoader("assets/CH0288_spr.atlas"));
		var skeletondata = SkeletonData.from(skeletonFile, atlas1);

		var animationStateData = new AnimationStateData(skeletondata);

		// Instantiate the SkeletonSprite
		var qingyetest = new SkeletonSprite(skeletondata, animationStateData);
		// 设置主要动画在轨道0
		qingyetest.state.setAnimationByName(0, "19", true);
		// 设置光环动画在轨道1
		qingyetest.state.setAnimationByName(1, "Idle_01", true);
		qingyetest.screenCenter(X);
		qingyetest.x -= 500;
		//qingyetest.state.addAnimationByName(0, "19", true);
		// Add the SkeletonSprite as a child of the DisplayObject in the stage
		add(qingyetest);

		var atlasFile2 = Assets.getText("assets/CH0145_spr.atlas");
		var skeletonFile2 = Assets.getBytes("assets/CH0145_spr.skel");

		var atlas2 = new TextureAtlas(atlasFile2, new FlixelTextureLoader("assets/CH0145_spr.atlas"));
		var skeletondata2 = SkeletonData.from(skeletonFile2, atlas2);
		var animationStateData2 = new AnimationStateData(skeletondata2);
		var miyutest = new SkeletonSprite(skeletondata2, animationStateData2);
		// 设置主要动画在轨道0
		miyutest.state.setAnimationByName(0, "09", true);
		// 设置光环动画在轨道1
		miyutest.state.setAnimationByName(1, "Idle_01", true);
		miyutest.screenCenter(X);
		miyutest.x += 500;
		add(miyutest);


		//下面是官方写的
		/*var atlas = new TextureAtlas(Assets.getText("assets/CH0288_spr.atlas"), new FlixelTextureLoader("assets/CH0288_spr.atlas"));
		var skeletondata = SkeletonData.from(Assets.getBytes("assets/CH0288_spr.skel"), atlas, .25);
		var animationStateData = new AnimationStateData(skeletondata);
		spineSprite = new SkeletonSprite(skeletondata, animationStateData);

		// 定位Spine角色
		trace("Positioning Spine character at (0.5 * FlxG.width, 0.5 * FlxG.height)");
		spineSprite.setPosition(.5 * FlxG.width, .5 * FlxG.height);
		//spineObject.state.setAnimation(0, "walk", true);
		spineSprite.state.setAnimation(0, "19", true);*/
		//add(spineSprite);

		/*trace("=== FlixelState.create() ===");

		// 设置背景颜色
		trace("Setting background color to 0xffa1b2b0");

		// 设置速度
		trace("Setting speed to 450 / scale (scale = $scale)");
		speed = 450 / scale;

		// 创建组
		trace("Creating FlxSpriteGroup");
		group = new FlxSpriteGroup();
		group.setPosition(50, 50);
		add(group);

		// 创建检测重叠的精灵
		trace("Creating sprite for overlap detection");
		sprite = new FlxSprite();
		sprite.loadGraphic(FlxGraphic.fromRectangle(150, 100, 0xff8d008d));
		group.add(sprite);

		// 创建文本显示重叠状态
		trace("Creating text for overlap state");
		myText = new FlxText(0, 25, 150, "", 16);
		myText.alignment = CENTER;
		group.add(myText);

		// 创建按钮
		trace("Creating button for next scene");
		var button = new FlxButton(0, 0, "Next scene", () -> FlxG.switchState(() -> new BasicExample()));
		button.setPosition(FlxG.width * .75, FlxG.height / 10);
		add(button);

		// 创建地板精灵
		trace("Creating floor sprite");
		var floor = new FlxSprite();
		floor.loadGraphic(FlxGraphic.fromRectangle(FlxG.width, FlxG.height - 100, 0xff822f02));
		floor.y = FlxG.height - 100;
		add(floor);

		// 添加指令
		trace("Adding instructions");
		var groupInstructions = new FlxSpriteGroup();
		groupInstructions.setPosition(50, 405);
		groupInstructions.add(new FlxText(0, 0, 200, "Left/Right - Move", 16));
		groupInstructions.add(new FlxText(0, 25, 150, "Space - Jump", 16));
		groupInstructions.add(new FlxText(200, 25, 400, "Click the button for the next example", 16));
		add(groupInstructions);

		// 加载Spine角色
		trace("Loading Spine character");
		var atlas = new TextureAtlas(Assets.getText("assets/CH0288_spr.atlas"), new FlixelTextureLoader("assets/CH0288_spr.atlas"));
		var skeletondata = SkeletonData.from(Assets.getBytes("assets/CH0288_spr.skel"), atlas, .25);
		var animationStateData = new AnimationStateData(skeletondata);
		spineSprite = new SkeletonSprite(skeletondata, animationStateData);

		// 定位Spine角色
		trace("Positioning Spine character at (0.5 * FlxG.width, 0.5 * FlxG.height)");
		spineSprite.setPosition(.5 * FlxG.width, .5 * FlxG.height);

		// 设置动画混合时间
		trace("Setting animation mix times");
		animationStateData.defaultMix = 0.5;
		animationStateData.setMixByName("12", "12", 0.1);
		animationStateData.setMixByName("13", "13", 0.1);
		animationStateData.setMixByName("14", "14", 0.05);
		animationStateData.setMixByName("15", "15", 0.05);
		animationStateData.setMixByName("16", "16", 0.3);
		animationStateData.setMixByName("17", "17", 0);
		animationStateData.setMixByName("18", "18", 0.05);
		animationStateData.setMixByName("19", "19", 0.05);
		animationStateData.setMixByName("20", "20", 0.05);

		// 设置初始动画
		trace("Setting initial animation to 'idle'");
		spineSprite.state.setAnimationByName(0, "16", true);

		// 设置跳跃动画的回调
		trace("Setting up jump animation callbacks");
		var hip = spineSprite.skeleton.findBone("hip");
		var initialY = 0.0;
		var initialOffsetY = 0.0;
		spineSprite.state.onStart.add(entry -> {
			trace("Animation started: ${entry.animation.name}");
			if (entry.animation.name == "15") {
				initialY = spineSprite.y;
				initialOffsetY = spineSprite.offsetY;
				trace("Jump animation started, initialY = $initialY, initialOffsetY = $initialOffsetY");
			}
		});
		spineSprite.state.onComplete.add(entry -> {
			trace("Animation completed: ${entry.animation.name}");
			if (entry.animation.name == "15") {
				jumping = false;
				spineSprite.y = initialY;
				spineSprite.offsetY = initialOffsetY;
				trace("Jump animation completed, jumping = $jumping");
			}
		});

		// 设置跳跃时的Y偏移
		var diff = 0.0;
		spineSprite.afterUpdateWorldTransforms = spineSprite -> {
			if (jumping) {
				diff -= hip.y;
				spineSprite.offsetY -= diff;
				spineSprite.y += diff;
				trace("Updating jump position: diff = $diff, offsetY = ${spineSprite.offsetY}, y = ${spineSprite.y}");
			}
			diff = hip.y;
		}

		// 添加Spine角色到舞台
		trace("Adding Spine character to stage");
		add(spineSprite);

		// 调用父类的create方法
		trace("Calling super.create()");*/
		super.create();
	}

	var justSetIdle = true;
	override public function update(elapsed:Float):Void
	{
		/*trace("=== FlixelState.update(elapsed = $elapsed) ===");

		// 检测重叠
		if (FlxG.overlap(spineSprite, group)) {
			myText.text = "Overlapping";
			trace("Spine character is overlapping with group");
		} else {
			myText.text = "Non overlapping";
			trace("Spine character is not overlapping with group");
		}

		// 处理跳跃
		if (!jumping && FlxG.keys.anyJustPressed([SPACE])) {
			trace("Space key pressed, setting jump animation");
			spineSprite.state.setAnimationByName(0, "14", false);
			jumping = true;
			justSetIdle = false;
			justSetWalking = false;
		}

		// 处理调试键
		if (FlxG.keys.anyJustPressed([J])) {
			trace("J key pressed, toggling debugger visibility");
			FlxG.debugger.visible = !FlxG.debugger.visible;
		}

		// 处理左右移动
		if (FlxG.keys.anyPressed([RIGHT, LEFT])) {
			justSetIdle = false;
			var flipped = false;
			var deltaX = 0.0;

			if (FlxG.keys.anyPressed([RIGHT])) {
				if (spineSprite.flipX == true) flipped = true;
				spineSprite.flipX = false;
				trace("Right key pressed, flipX set to false");
			}
			if (FlxG.keys.anyPressed([LEFT])) {
				if (spineSprite.flipX == false) flipped = true;
				spineSprite.flipX = true;
				trace("Left key pressed, flipX set to true");
			}

			deltaX = (spineSprite.flipX == false ? 1 : -1) * speed * elapsed;
			spineSprite.x += deltaX;
			trace("Moving Spine character by $deltaX, new x = ${spineSprite.x}");

			if (!jumping && !justSetWalking) {
				justSetWalking = true;
				if (flipped) {
					spineSprite.state.setAnimationByName(0, "12", false);
					spineSprite.state.addAnimationByName(0, "17", true, 0);
					trace("Setting animation to 'idle-turn' then 'walk'");
				} else {
					spineSprite.state.setAnimationByName(0, "13", true);
					trace("Setting animation to 'walk'");
				}
			}

		} else if (!jumping && !justSetIdle) {
			justSetWalking = false;
			justSetIdle = true;
			spineSprite.state.setAnimationByName(0, "16", true);
			trace("Setting animation to 'idle'");
		}

		// 调用父类的update方法
		trace("Calling super.update(elapsed)");*/
		super.update(elapsed);
	}
}