package player;

import flixel.FlxG;
import BaseState;

class PlayState extends BaseState
{
	override public function create():Void
	{
		super.create();
		
		trace('PlayState created with mouse trail effect');
		
		// 这里可以添加PlayState特有的内容
		// 鼠标拖尾效果已经通过BaseState自动添加
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// 这里可以添加PlayState特有的更新逻辑
		// 鼠标拖尾的控制已经在BaseState中实现
		// F1: 切换鼠标拖尾显示/隐藏
		// F2-F7: 切换不同颜色
	}
}