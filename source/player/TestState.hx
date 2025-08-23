package player;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTextInput;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import openfl.Assets;
import spine.animation.AnimationStateData;
import spine.animation.AnimationState;
import spine.atlas.TextureAtlas;
import spine.SkeletonData;
import spine.flixel.SkeletonSprite;
import spine.flixel.FlixelTextureLoader;
import openfl.text.Font;

class TestState extends FlxState
{
    // Spine characters
    var qingyetest:SkeletonSprite;
    var miyutest:SkeletonSprite;
    
    // 存储所有Spine角色的数组
    var spineCharacters:Array<SkeletonSprite> = [];
    var spineCharacterData:Array<{
        name:String,
        x:Float,
        y:Float,
        scale:Float,
        visible:Bool,
        atlasPath:String,
        skeletonPath:String,
        defaultAnim:String
    }> = [];
    
    // Text system
    var dialogText:FlxTypeText;
    var nextTextInput:FlxTextInput;
    var nextTextInputBackground:FlxSprite;
    var applyTextButton:FlxButton;
    var dialogBackground:FlxSprite;
    
    // UI control panel
    var controlPanel:FlxUITabMenu;
    var focusCheckbox:FlxUICheckBox;
    var xPosStepper:FlxUINumericStepper;
    var yPosStepper:FlxUINumericStepper;
    var textSpeedStepper:FlxUINumericStepper;
    
    // Animation controls
    var qingyeAnimInput:FlxTextInput;
    var miyuAnimInput:FlxTextInput;
    var qingyeAnimBackground:FlxSprite;
    var miyuAnimBackground:FlxSprite;
    var applyQingyeAnimButton:FlxButton;
    var applyMiyuAnimButton:FlxButton;
    
    // Spine character management
    var spineCharSelect:FlxUINumericStepper;
    var spineCharXStepper:FlxUINumericStepper;
    var spineCharYStepper:FlxUINumericStepper;
    var spineCharScaleStepper:FlxUINumericStepper;
    var toggleSpineCharButton:FlxButton;
    
    // Current dialog index
    var currentDialogIndex:Int = 0;
    
    // Track if typing is complete
    var isTypingComplete:Bool = false;
    
    // Predefined dialogs
    var dialogs:Array<String> = [
        "清月: 你好，我是清月。很高兴认识你！",
        "美优: 我是美优，很高兴认识你。",
        "清月: 今天天气真不错。",
        "美优: 是的，是个散步的好日子。",
        "清月: 你想去喝点茶吗？",
        "美优: 好主意，我知道附近有个不错的地方。"
    ];
    
    override public function create():Void
    {
        // Set background color
        FlxG.cameras.bgColor = 0xff131c1b;
        
        // 初始化角色数据
        initSpineCharacterData();
        
        // Load Spine characters
        loadSpineCharacters();
        
        // Create dialog background
        createDialogBackground();
        
        // Create dialog text
        createDialogText();
        
        // Create next dialog input and apply button
        createNextDialogControls();
        
        // Create animation controls
        createAnimationControls();
        
        // Create Spine character management controls
        createSpineCharacterControls();
        
        // Create control panel
        createControlPanel();
        
        // Start first dialog
        startDialog(0);
        
        super.create();
    }
    
    function initSpineCharacterData():Void
    {
        spineCharacterData = [
            {
                name: "清月",
                x: FlxG.width/2 - 300,
                y: FlxG.height - 400,
                scale: 0.8,
                visible: true,
                atlasPath: "assets/spr/BlueArchive/CH0288_spr.atlas",
                skeletonPath: "assets/spr/BlueArchive/CH0288_spr.skel",
                defaultAnim: "19"
            },
            {
                name: "美优",
                x: FlxG.width/2 + 300,
                y: FlxG.height - 400,
                scale: 0.8,
                visible: true,
                atlasPath: "assets/spr/BlueArchive/CH0145_spr.atlas",
                skeletonPath: "assets/spr/BlueArchive/CH0145_spr.skel",
                defaultAnim: "09"
            }
        ];
    }
    
    function loadSpineCharacters():Void
    {
        for (i in 0...spineCharacterData.length)
        {
            var data = spineCharacterData[i];
            if (data.visible)
            {
                try {
                    var atlasFile = Assets.getText(data.atlasPath);
                    var skeletonFile = Assets.getBytes(data.skeletonPath);
                    var atlas = new TextureAtlas(atlasFile, new FlixelTextureLoader(data.atlasPath));
                    var skeletonData = SkeletonData.from(skeletonFile, atlas, data.scale);
                    var animationStateData = new AnimationStateData(skeletonData);
                    
                    var character = new SkeletonSprite(skeletonData, animationStateData);
                    character.state.setAnimationByName(0, data.defaultAnim, true);
                    character.state.setAnimationByName(1, "Idle_01", true);
                    character.x = data.x;
                    character.y = data.y;
                    //character.scale.set(data.scale, data.scale);
                    
                    add(character);
                    spineCharacters.push(character);
                } catch (e:Dynamic) {
                    trace('Failed to load ${data.name} character: ' + e);
                    // 创建占位符
                    var placeholder = new FlxSprite(data.x, data.y - 100);
                    placeholder.makeGraphic(200, 300, i == 0 ? FlxColor.BLUE : FlxColor.PINK);
                    add(placeholder);
                    
                    var errorText = new FlxText(data.x, data.y + 220, 200, '${data.name}加载失败', 16);
                    errorText.alignment = CENTER;
                    errorText.setFormat("ResourceHanRoundedCN-Bold.ttf", 16);
                    add(errorText);
                    
                    // 添加空引用以保持索引一致
                    spineCharacters.push(null);
                }
            }
            else
            {
                // 角色不可见，添加空引用
                spineCharacters.push(null);
            }
        }
    }
    
    function createDialogBackground():Void
    {
        dialogBackground = new FlxSprite(0, FlxG.height - 200);
        dialogBackground.makeGraphic(FlxG.width, 200, FlxColor.BLACK);
        dialogBackground.alpha = 0.7;
        add(dialogBackground);
    }
    
    function createDialogText():Void
    {
        dialogText = new FlxTypeText(50, FlxG.height - 180, FlxG.width - 100, "", 24);
        dialogText.color = FlxColor.WHITE;
        dialogText.delay = 0.05;
        dialogText.showCursor = true;
        dialogText.cursorBlinkSpeed = 0.5;
        dialogText.autoErase = true;
        dialogText.waitTime = 2.0;
        dialogText.setFormat("ResourceHanRoundedCN-Bold.ttf", 24);
        
        add(dialogText);
    }
    
    function createNextDialogControls():Void
    {
        var nextTextLabel = new FlxText(FlxG.width - 350, 50, 100, "下一句对话:", 16);
        nextTextLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 16);
        add(nextTextLabel);
        
        // 添加文本框背景
        nextTextInputBackground = new FlxSprite(FlxG.width - 250, 50);
        nextTextInputBackground.makeGraphic(200, 30, FlxColor.GRAY);
        add(nextTextInputBackground);
        
        // 改为使用 FlxTextInput
        nextTextInput = new FlxTextInput(FlxG.width - 250, 50, 200, "", 16);
        nextTextInput.setFormat("ResourceHanRoundedCN-Bold.ttf", 16);
        nextTextInput.color = FlxColor.WHITE;
        add(nextTextInput);
        
        applyTextButton = createButton(FlxG.width - 350, 80, "应用对话", applyNextDialog);
        add(applyTextButton);
        
        var nextDialogButton = createButton(FlxG.width - 350, 110, "下一句预设", nextPresetDialog);
        add(nextDialogButton);
        
        var prevDialogButton = createButton(FlxG.width - 350, 140, "上一句预设", prevPresetDialog);
        add(prevDialogButton);
    }
    
    // 创建带中文字体的按钮
    function createButton(x:Float, y:Float, text:String, onClick:Void->Void):FlxButton
    {
        var button = new FlxButton(x, y, text, onClick);
        
        // 设置按钮标签的字体
        if (button.label != null)
        {
            button.label.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        }
        
        return button;
    }
    
    function createAnimationControls():Void
    {
        var animLabel = new FlxText(FlxG.width - 350, 170, 100, "角色动画控制:", 16);
        animLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 16);
        add(animLabel);
        
        var qingyeLabel = new FlxText(FlxG.width - 350, 190, 100, "清月动画:", 12);
        qingyeLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(qingyeLabel);
        
        // 清月动画输入框背景
        qingyeAnimBackground = new FlxSprite(FlxG.width - 250, 190);
        qingyeAnimBackground.makeGraphic(200, 20, FlxColor.GRAY);
        add(qingyeAnimBackground);
        
        // 清月动画输入框
        qingyeAnimInput = new FlxTextInput(FlxG.width - 250, 190, 200, "19", 12);
        qingyeAnimInput.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        qingyeAnimInput.color = FlxColor.WHITE;
        add(qingyeAnimInput);
        
        applyQingyeAnimButton = createButton(FlxG.width - 350, 210, "应用清月动画", applyQingyeAnimation);
        add(applyQingyeAnimButton);
        
        var miyuLabel = new FlxText(FlxG.width - 350, 230, 100, "美优动画:", 12);
        miyuLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(miyuLabel);
        
        // 美优动画输入框背景
        miyuAnimBackground = new FlxSprite(FlxG.width - 250, 230);
        miyuAnimBackground.makeGraphic(200, 20, FlxColor.GRAY);
        add(miyuAnimBackground);
        
        // 美优动画输入框
        miyuAnimInput = new FlxTextInput(FlxG.width - 250, 230, 200, "09", 12);
        miyuAnimInput.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        miyuAnimInput.color = FlxColor.WHITE;
        add(miyuAnimInput);
        
        applyMiyuAnimButton = createButton(FlxG.width - 350, 250, "应用美优动画", applyMiyuAnimation);
        add(applyMiyuAnimButton);
    }
    
    function createSpineCharacterControls():Void
    {
        var spineLabel = new FlxText(FlxG.width - 350, 280, 100, "角色管理:", 16);
        spineLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 16);
        add(spineLabel);
        
        var charSelectLabel = new FlxText(FlxG.width - 350, 300, 100, "选择角色:", 12);
        charSelectLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(charSelectLabel);
        
        spineCharSelect = new FlxUINumericStepper(FlxG.width - 250, 300, 1, 0, 0, spineCharacterData.length - 1, 0);
        add(spineCharSelect);
        
        var xPosLabel = new FlxText(FlxG.width - 350, 320, 100, "X 位置:", 12);
        xPosLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(xPosLabel);
        
        spineCharXStepper = new FlxUINumericStepper(FlxG.width - 250, 320, 10, 0, -FlxG.width, FlxG.width * 2, 0);
        add(spineCharXStepper);
        
        var yPosLabel = new FlxText(FlxG.width - 350, 340, 100, "Y 位置:", 12);
        yPosLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(yPosLabel);
        
        spineCharYStepper = new FlxUINumericStepper(FlxG.width - 250, 340, 10, 0, -FlxG.height, FlxG.height * 2, 0);
        add(spineCharYStepper);
        
        var scaleLabel = new FlxText(FlxG.width - 350, 360, 100, "缩放:", 12);
        scaleLabel.setFormat("ResourceHanRoundedCN-Bold.ttf", 12);
        add(scaleLabel);
        
        spineCharScaleStepper = new FlxUINumericStepper(FlxG.width - 250, 360, 0.1, 0.8, 0.1, 2.0, 1);
        add(spineCharScaleStepper);
        
        var applyPosButton = createButton(FlxG.width - 350, 380, "应用位置/缩放", applySpineCharacterPosition);
        add(applyPosButton);
        
        toggleSpineCharButton = createButton(FlxG.width - 350, 410, "隐藏角色", toggleSpineCharacter);
        add(toggleSpineCharButton);
    }
    
    function createControlPanel():Void
    {
        var tabs = [
            {name: "Position", label: "位置"},
            {name: "Appearance", label: "外观"},
            {name: "Animation", label: "动画"}
        ];
        
        controlPanel = new FlxUITabMenu(null, tabs, true);
        controlPanel.resize(300, 200);
        controlPanel.x = FlxG.width - 350;
        controlPanel.y = 440;
        add(controlPanel);
        
        // Position tab
        var positionTab = new FlxUI(null, controlPanel);
        positionTab.name = "Position";
        
        var xPosLabel = new FlxText(10, 10, 100, "X 位置:", 12);
        positionTab.add(xPosLabel);
        
        xPosStepper = new FlxUINumericStepper(80, 10, 10, dialogText.x, 0, FlxG.width - 100, 0);
        positionTab.add(xPosStepper);
        
        var yPosLabel = new FlxText(10, 40, 100, "Y 位置:", 12);
        positionTab.add(yPosLabel);
        
        yPosStepper = new FlxUINumericStepper(80, 40, 10, dialogText.y, 0, FlxG.height - 100, 0);
        positionTab.add(yPosStepper);
        
        var applyPosButton = createButton(10, 70, "应用位置", applyPosition);
        positionTab.add(applyPosButton);
        
        // Appearance tab
        var appearanceTab = new FlxUI(null, controlPanel);
        appearanceTab.name = "Appearance";
        
        focusCheckbox = new FlxUICheckBox(10, 10, null, null, "焦点模式", 100);
        focusCheckbox.callback = onFocusChanged;
        appearanceTab.add(focusCheckbox);
        
        var textSpeedLabel = new FlxText(10, 40, 100, "文本速度:", 12);
        appearanceTab.add(textSpeedLabel);
        
        textSpeedStepper = new FlxUINumericStepper(80, 40, 0.01, 0.05, 0.01, 0.5, 2);
        appearanceTab.add(textSpeedStepper);
        
        var applySpeedButton = createButton(10, 70, "应用速度", applyTextSpeed);
        appearanceTab.add(applySpeedButton);
        
        var textColorButton = createButton(10, 100, "文本颜色", openColorPicker);
        appearanceTab.add(textColorButton);
        
        // Animation tab
        var animationTab = new FlxUI(null, controlPanel);
        animationTab.name = "Animation";
        
        /*
        // 注释掉有问题的Stepper
        var scaleLabel = new FlxText(10, 10, 100, "角色缩放:", 12);
        animationTab.add(scaleLabel);
        
        var scaleStepper = new FlxUINumericStepper(80, 10, 0.1, 0.8, 0.1, 2.0, 1);
        // scaleStepper.callback = function(value:Float) {
        //     if (qingyetest != null) qingyetest.scale.set(value, value);
        //     if (miyutest != null) miyutest.scale.set(value, value);
        // };
        animationTab.add(scaleStepper);
        
        var xOffsetLabel = new FlxText(10, 40, 100, "X 偏移:", 12);
        animationTab.add(xOffsetLabel);
        
        var xOffsetStepper = new FlxUINumericStepper(80, 40, 10, 0, -500, 500, 0);
        // xOffsetStepper.callback = function(value:Float) {
        //     if (qingyetest != null) qingyetest.x = FlxG.width/2 - 300 + value;
        //     if (miyutest != null) miyutest.x = FlxG.width/2 + 300 + value;
        // };
        animationTab.add(xOffsetStepper);
        
        var yOffsetLabel = new FlxText(10, 70, 100, "Y 偏移:", 12);
        animationTab.add(yOffsetLabel);
        
        var yOffsetStepper = new FlxUINumericStepper(80, 70, 10, 0, -500, 500, 0);
        // yOffsetStepper.callback = function(value:Float) {
        //     if (qingyetest != null) qingyetest.y = FlxG.height - 250 + value;
        //     if (miyutest != null) miyutest.y = FlxG.height - 250 + value;
        // };
        animationTab.add(yOffsetStepper);
        */
        
        var resetAnimButton = createButton(10, 100, "重置动画", resetAnimations);
        animationTab.add(resetAnimButton);
        
        controlPanel.addGroup(positionTab);
        controlPanel.addGroup(appearanceTab);
        controlPanel.addGroup(animationTab);
    }
    
    function startDialog(index:Int):Void
    {
        if (index >= 0 && index < dialogs.length)
        {
            isTypingComplete = false;
            dialogText.resetText(dialogs[index]);
            dialogText.start(0.02, false, false, null, onTypingComplete);
        }
    }
    
    function onTypingComplete():Void
    {
        isTypingComplete = true;
    }
    
    function applyNextDialog():Void
    {
        if (nextTextInput.text != "")
        {
            // 将新对话添加到对话列表中，放在当前对话后面
            if (currentDialogIndex < dialogs.length - 1)
            {
                dialogs.insert(currentDialogIndex + 1, nextTextInput.text);
            }
            else
            {
                dialogs.push(nextTextInput.text);
            }
            
            // 显示新对话
            isTypingComplete = false;
            dialogText.resetText(nextTextInput.text);
            dialogText.start(0.02, false, false, null, onTypingComplete);
            
            // 更新当前对话索引
            currentDialogIndex = dialogs.indexOf(nextTextInput.text);
        }
    }
    
    function applyQingyeAnimation():Void
    {
        var character = spineCharacters[0];
        if (character != null && qingyeAnimInput.text != "" && qingyeAnimInput.text != "Idle_01")
        {
            try {
                character.state.setAnimationByName(0, qingyeAnimInput.text, true);
            } catch (e:Dynamic) {
                trace("Failed to set Qingyue animation: " + e);
                // 恢复默认动画
                character.state.setAnimationByName(0, spineCharacterData[0].defaultAnim, true);
            }
        }
    }
    
    function applyMiyuAnimation():Void
    {
        var character = spineCharacters[1];
        if (character != null && miyuAnimInput.text != "" && miyuAnimInput.text != "Idle_01")
        {
            try {
                character.state.setAnimationByName(0, miyuAnimInput.text, true);
            } catch (e:Dynamic) {
                trace("Failed to set Miyu animation: " + e);
                // 恢复默认动画
                character.state.setAnimationByName(0, spineCharacterData[1].defaultAnim, true);
            }
        }
    }
    
    function applySpineCharacterPosition():Void
    {
        var charIndex = Std.int(spineCharSelect.value);
        if (charIndex >= 0 && charIndex < spineCharacters.length)
        {
            var character = spineCharacters[charIndex];
            if (character != null)
            {
                character.x = spineCharXStepper.value;
                character.y = spineCharYStepper.value;
                //character.scale.set(spineCharScaleStepper.value, spineCharScaleStepper.value);
                
                // 更新角色数据
                spineCharacterData[charIndex].x = character.x;
                spineCharacterData[charIndex].y = character.y;
                spineCharacterData[charIndex].scale = spineCharScaleStepper.value;
            }
        }
    }
    
    function toggleSpineCharacter():Void
    {
        var charIndex = Std.int(spineCharSelect.value);
        if (charIndex >= 0 && charIndex < spineCharacters.length)
        {
            var character = spineCharacters[charIndex];
            if (character != null)
            {
                character.visible = !character.visible;
                spineCharacterData[charIndex].visible = character.visible;
                
                toggleSpineCharButton.text = character.visible ? "隐藏角色" : "显示角色";
            }
        }
    }
    
    function resetAnimations():Void
    {
        for (i in 0...spineCharacters.length)
        {
            var character = spineCharacters[i];
            if (character != null)
            {
                character.state.setAnimationByName(0, spineCharacterData[i].defaultAnim, true);
                character.state.setAnimationByName(1, "Idle_01", true);
            }
        }
    }
    
    function nextPresetDialog():Void
    {
        currentDialogIndex = (currentDialogIndex + 1) % dialogs.length;
        startDialog(currentDialogIndex);
    }
    
    function prevPresetDialog():Void
    {
        currentDialogIndex = (currentDialogIndex - 1 + dialogs.length) % dialogs.length;
        startDialog(currentDialogIndex);
    }
    
    function applyPosition():Void
    {
        dialogText.x = xPosStepper.value;
        dialogText.y = yPosStepper.value;
    }
    
    function applyTextSpeed():Void
    {
        dialogText.delay = textSpeedStepper.value;
    }
    
    function onFocusChanged():Void
    {
        if (focusCheckbox.checked)
        {
            // Focus mode: characters dimmed
            for (character in spineCharacters)
            {
                if (character != null) character.alpha = 0.5;
            }
            dialogBackground.alpha = 0.9;
        }
        else
        {
            // Normal mode
            for (character in spineCharacters)
            {
                if (character != null) character.alpha = 1.0;
            }
            dialogBackground.alpha = 0.7;
        }
    }
    
    function openColorPicker():Void
    {
        // Simplified version: cycle through preset colors
        var colors = [FlxColor.WHITE, FlxColor.YELLOW, FlxColor.CYAN, FlxColor.LIME];
        var currentIndex = colors.indexOf(dialogText.color);
        var nextIndex = (currentIndex + 1) % colors.length;
        dialogText.color = colors[nextIndex];
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // Add keyboard controls
        if (FlxG.keys.justPressed.RIGHT)
        {
            nextPresetDialog();
        }
        else if (FlxG.keys.justPressed.LEFT)
        {
            prevPresetDialog();
        }
        else if (FlxG.keys.justPressed.SPACE)
        {
            if (isTypingComplete)
            {
                nextPresetDialog();
            }
            else
            {
                dialogText.skip();
                isTypingComplete = true;
            }
        }
        
        // 更新文本框背景位置
        if (nextTextInputBackground != null) {
            nextTextInputBackground.x = nextTextInput.x;
            nextTextInputBackground.y = nextTextInput.y;
        }
        
        if (qingyeAnimBackground != null) {
            qingyeAnimBackground.x = qingyeAnimInput.x;
            qingyeAnimBackground.y = qingyeAnimInput.y;
        }
        
        if (miyuAnimBackground != null) {
            miyuAnimBackground.x = miyuAnimInput.x;
            miyuAnimBackground.y = miyuAnimInput.y;
        }
        
        // 更新角色选择器的值
        var charIndex = Std.int(spineCharSelect.value);
        if (charIndex >= 0 && charIndex < spineCharacterData.length)
        {
            var data = spineCharacterData[charIndex];
            spineCharXStepper.value = data.x;
            spineCharYStepper.value = data.y;
            spineCharScaleStepper.value = data.scale;
        }
    }
}