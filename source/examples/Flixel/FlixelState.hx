package examples.flixel;

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
import utils.SettingsData;

class FlixelState extends FlxState
{
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff000000;
		//FlxG.drawFramerate = FlxG.updateFramerate = 120;
		FlxG.updateFramerate = SettingsData.instance.frameRateLimit;
        FlxG.autoPause = SettingsData.instance.autoPause;

		var atlasFile = Assets.getText("assets/spr/BlueArchive/CH0288_spr.atlas");
		var skeletonFile = Assets.getBytes("assets/spr/BlueArchive/CH0288_spr.skel");

		var atlas1 = new TextureAtlas(atlasFile, new FlixelTextureLoader("assets/spr/BlueArchive/CH0288_spr.atlas"));
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
		// Add the SkeletonSprite as a child of the DisplayObject in the stage
		add(qingyetest);

		var atlasFile2 = Assets.getText("assets/spr/BlueArchive/CH0145_spr.atlas");
		var skeletonFile2 = Assets.getBytes("assets/spr/BlueArchive/CH0145_spr.skel");

		var atlas2 = new TextureAtlas(atlasFile2, new FlixelTextureLoader("assets/spr/BlueArchive/CH0145_spr.atlas"));
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

		var menuButton = new FlxButton(0, 0, "Main Menu", () -> {
			TransitionManager.switchState(MainMenuState);
		});
		menuButton.setPosition(FlxG.width - menuButton.width - 100, 50);
		menuButton.updateHitbox();
		menuButton.label.scale.set(2, 2);
		menuButton.scale.set(2, 2);
		add(menuButton);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}