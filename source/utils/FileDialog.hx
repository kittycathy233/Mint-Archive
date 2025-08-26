package utils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.addons.ui.FlxInputText;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import sys.FileSystem;
import haxe.io.Path;

/**
 * 文件对话框类型
 */
enum FileDialogType {
    OPEN;  // 打开文件对话框
    SAVE;  // 保存文件对话框
}

/**
 * 文件对话框回调函数类型
 */
typedef FileDialogCallback = String->Void;

/**
 * 模拟Windows风格的文件对话框
 */
class FileDialog extends FlxGroup
{
    // 对话框尺寸和位置
    private var dialogWidth:Float = 800;
    private var dialogHeight:Float = 600;
    private var dialogX:Float;
    private var dialogY:Float;
    
    // UI元素
    private var background:FlxSprite;
    private var titleBar:FlxSprite;
    private var titleText:FlxText;
    private var fileListBackground:FlxSprite;
    public var fileNameInput:FlxInputText;
    private var fileTypeText:FlxText;
    
    // 按钮
    private var okButton:FlxButton;
    private var cancelButton:FlxButton;
    private var upButton:FlxButton;
    private var newFolderButton:FlxButton;
    
    // 文件列表
    private var fileItems:Array<FileItem> = [];
    private var fileItemsGroup:FlxGroup;
    private var currentPath:String = "";
    private var selectedFile:String = "";
    private var scrollOffset:Int = 0;
    private var maxVisibleItems:Int = 15;
    
    // 对话框类型和回调
    private var dialogType:FileDialogType;
    private var callback:FileDialogCallback;
    private var fileExtension:String;
    private var parent:FlxState;
    
    // 滚动控制
    private var scrollUpButton:FlxButton;
    private var scrollDownButton:FlxButton;
    
    // 路径导航
    private var pathText:FlxText;
    private var pathButtons:Array<{button:FlxButton, path:String}> = [];
    
    /**
     * 创建一个新的文件对话框
     * @param parent 父状态
     * @param type 对话框类型（打开/保存）
     * @param callback 选择文件后的回调函数
     * @param fileExtension 文件扩展名过滤器（例如：".json"）
     */
    public function new(parent:FlxState, type:FileDialogType, callback:FileDialogCallback, fileExtension:String = "")
    {
        super();
        
        this.parent = parent;
        this.dialogType = type;
        this.callback = callback;
        this.fileExtension = fileExtension;
        
        // 计算对话框位置（居中）
        dialogX = (FlxG.width - dialogWidth) / 2;
        dialogY = (FlxG.height - dialogHeight) / 2;
        
        // 初始化当前路径
        #if windows
        currentPath = "C:/";
        #else
        currentPath = "/";
        #end
        
        createDialog();
        refreshFileList();
    }
    
    /**
     * 创建对话框UI
     */
    private function createDialog():Void
    {
        // 半透明背景遮罩（覆盖整个屏幕）
        var overlay = new FlxSprite(0, 0);
        overlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.alpha = 0.5;
        add(overlay);
        
        // 对话框背景
        background = new FlxSprite(dialogX, dialogY);
        background.makeGraphic(Std.int(dialogWidth), Std.int(dialogHeight), FlxColor.fromRGB(240, 240, 240));
        add(background);
        
        // 标题栏
        titleBar = new FlxSprite(dialogX, dialogY);
        titleBar.makeGraphic(Std.int(dialogWidth), 30, FlxColor.fromRGB(0, 120, 215));
        add(titleBar);
        
        // 标题文本
        var titleString = (dialogType == FileDialogType.OPEN) ? "Open File" : "Save File";
        titleText = new FlxText(dialogX + 10, dialogY + 5, dialogWidth - 20, titleString, 16);
        titleText.color = FlxColor.WHITE;
        add(titleText);
        
        // 路径显示
        pathText = new FlxText(dialogX + 10, dialogY + 40, dialogWidth - 20, "Path: " + currentPath, 14);
        pathText.color = FlxColor.BLACK;
        add(pathText);
        
        // 上级目录按钮
        upButton = new FlxButton(dialogX + 10, dialogY + 70, "↑", onUpButtonClick);
        upButton.scale.set(1.5, 1.5);
        add(upButton);
        
        // 新建文件夹按钮
        newFolderButton = new FlxButton(dialogX + 70, dialogY + 70, "New Folder", onNewFolderClick);
        newFolderButton.scale.set(1.5, 1.5);
        add(newFolderButton);
        
        // 文件列表背景
        fileListBackground = new FlxSprite(dialogX + 10, dialogY + 110);
        fileListBackground.makeGraphic(Std.int(dialogWidth - 20), Std.int(dialogHeight - 180), FlxColor.WHITE);
        add(fileListBackground);
        
        // 文件列表组
        fileItemsGroup = new FlxGroup();
        add(fileItemsGroup);
        
        // 滚动按钮
        scrollUpButton = new FlxButton(dialogX + dialogWidth - 40, dialogY + 110, "▲", onScrollUp);
        add(scrollUpButton);
        
        scrollDownButton = new FlxButton(dialogX + dialogWidth - 40, dialogY + dialogHeight - 110, "▼", onScrollDown);
        add(scrollDownButton);
        
        // 文件名输入框
        var fileNameLabel = new FlxText(dialogX + 10, dialogY + dialogHeight - 60, 100, "File name:", 14);
        fileNameLabel.color = FlxColor.BLACK;
        add(fileNameLabel);
        
        fileNameInput = new FlxInputText(dialogX + 120, dialogY + dialogHeight - 60, Std.int(dialogWidth - 250), "", 14, FlxColor.BLACK, FlxColor.WHITE);
        fileNameInput.backgroundColor = FlxColor.WHITE;
        fileNameInput.borderColor = FlxColor.BLACK;
        add(fileNameInput);
        
        // 文件类型文本
        fileTypeText = new FlxText(dialogX + 10, dialogY + dialogHeight - 30, dialogWidth - 20, "File type: " + (fileExtension != "" ? fileExtension : "All Files"), 14);
        fileTypeText.color = FlxColor.BLACK;
        add(fileTypeText);
        
        // 确定和取消按钮
        var okText = (dialogType == FileDialogType.OPEN) ? "Open" : "Save";
        okButton = new FlxButton(dialogX + dialogWidth - 180, dialogY + dialogHeight - 50, okText, onOkButtonClick);
        okButton.scale.set(1.5, 1.5);
        add(okButton);
        
        cancelButton = new FlxButton(dialogX + dialogWidth - 100, dialogY + dialogHeight - 50, "Cancel", onCancelButtonClick);
        cancelButton.scale.set(1.5, 1.5);
        add(cancelButton);
    }
    
    /**
     * 刷新文件列表
     */
    private function refreshFileList():Void
    {
        // 清除现有文件项
        for (item in fileItems)
        {
            fileItemsGroup.remove(item);
            item.destroy();
        }
        fileItems = [];
        
        // 更新路径文本
        pathText.text = "Path: " + currentPath;
        
        // 获取目录内容
        try
        {
            var entries = FileSystem.readDirectory(currentPath);
            
            // 先添加文件夹，再添加文件
            var folders:Array<String> = [];
            var files:Array<String> = [];
            
            for (entry in entries)
            {
                var fullPath = Path.join([currentPath, entry]);
                if (FileSystem.isDirectory(fullPath))
                {
                    folders.push(entry);
                }
                else if (fileExtension == "" || entry.endsWith(fileExtension))
                {
                    files.push(entry);
                }
            }
            
            // 排序
            folders.sort(function(a, b) return a.toLowerCase() > b.toLowerCase() ? 1 : -1);
            files.sort(function(a, b) return a.toLowerCase() > b.toLowerCase() ? 1 : -1);
            
            // 创建文件项
            var yPos = dialogY + 110;
            var index = 0;
            
            // 添加文件夹
            for (folder in folders)
            {
                if (index >= scrollOffset && index < scrollOffset + maxVisibleItems)
                {
                    var item = new FileItem(dialogX + 15, yPos, Std.int(dialogWidth - 50), folder, true, onFileItemClick);
                    fileItems.push(item);
                    fileItemsGroup.add(item);
                    yPos += 30;
                }
                index++;
            }
            
            // 添加文件
            for (file in files)
            {
                if (index >= scrollOffset && index < scrollOffset + maxVisibleItems)
                {
                    var item = new FileItem(dialogX + 15, yPos, Std.int(dialogWidth - 50), file, false, onFileItemClick);
                    fileItems.push(item);
                    fileItemsGroup.add(item);
                    yPos += 30;
                }
                index++;
            }
        }
        catch (e:Dynamic)
        {
            trace("Error reading directory: " + e);
            // 显示错误消息
            var errorText = new FlxText(dialogX + 15, dialogY + 150, dialogWidth - 30, "Error reading directory: " + e, 14);
            errorText.color = FlxColor.RED;
            fileItemsGroup.add(errorText);
        }
    }
    
    /**
     * 文件项点击回调
     * @param name 文件/文件夹名称
     * @param isDirectory 是否为目录
     */
    private function onFileItemClick(name:String, isDirectory:Bool):Void
    {
        if (isDirectory)
        {
            // 进入子目录
            currentPath = Path.join([currentPath, name]);
            scrollOffset = 0;
            refreshFileList();
        }
        else
        {
            // 选择文件
            selectedFile = name;
            fileNameInput.text = name;
        }
    }
    
    /**
     * 上级目录按钮点击回调
     */
    private function onUpButtonClick():Void
    {
        var parent = Path.directory(currentPath);
        if (parent != null && parent != currentPath)
        {
            currentPath = parent;
            scrollOffset = 0;
            refreshFileList();
        }
    }
    
    /**
     * 新建文件夹按钮点击回调
     */
    private function onNewFolderClick():Void
    {
        // 创建一个新的文件夹名称输入对话框
        var folderNameInput = new FlxInputText(dialogX + 200, dialogY + 300, 400, "", 16, FlxColor.BLACK, FlxColor.WHITE);
        folderNameInput.backgroundColor = FlxColor.WHITE;
        folderNameInput.borderColor = FlxColor.BLACK;
        add(folderNameInput);
        
        var inputBackground = new FlxSprite(dialogX + 180, dialogY + 280);
        inputBackground.makeGraphic(440, 100, FlxColor.fromRGB(220, 220, 220));
        add(inputBackground);
        
        // 添加边框
        var border = new FlxSprite(dialogX + 180, dialogY + 280);
        border.makeGraphic(440, 100, FlxColor.TRANSPARENT);
        border.loadGraphic(FlxGraphic.fromRectangle(440, 100, FlxColor.TRANSPARENT));
        // 绘制边框线
        for (i in 0...440) {
            border.pixels.setPixel32(i, 0, FlxColor.BLACK);
            border.pixels.setPixel32(i, 99, FlxColor.BLACK);
        }
        for (i in 0...100) {
            border.pixels.setPixel32(0, i, FlxColor.BLACK);
            border.pixels.setPixel32(439, i, FlxColor.BLACK);
        }
        border.dirty = true;
        //border.updateFrameData();
        add(border);
        
        var inputLabel = new FlxText(dialogX + 200, dialogY + 280, 400, "Enter new folder name:", 16);
        inputLabel.color = FlxColor.BLACK;
        add(inputLabel);
        
        // 创建按钮变量
        var createFolderButton:FlxButton = null;
        var cancelFolderButton:FlxButton = null;
        
        // 创建按钮
        createFolderButton = new FlxButton(dialogX + 300, dialogY + 350, "Create", function() {
            var folderName = folderNameInput.text.trim();
            if (folderName != "")
            {
                try
                {
                    var newFolderPath = Path.join([currentPath, folderName]);
                    if (!FileSystem.exists(newFolderPath))
                    {
                        FileSystem.createDirectory(newFolderPath);
                        refreshFileList();
                    }
                }
                catch (e:Dynamic)
                {
                    trace("Error creating folder: " + e);
                }
            }
            
            // 移除输入对话框
            remove(inputBackground);
            remove(border);
            remove(inputLabel);
            remove(folderNameInput);
            remove(createFolderButton);
            remove(cancelFolderButton);
            
            inputBackground.destroy();
            border.destroy();
            inputLabel.destroy();
            folderNameInput.destroy();
            createFolderButton.destroy();
            cancelFolderButton.destroy();
        });
        createFolderButton.scale.set(1.5, 1.5);
        add(createFolderButton);
        
        cancelFolderButton = new FlxButton(dialogX + 400, dialogY + 350, "Cancel", function() {
            // 移除输入对话框
            remove(inputBackground);
            remove(border);
            remove(inputLabel);
            remove(folderNameInput);
            remove(createFolderButton);
            remove(cancelFolderButton);
            
            inputBackground.destroy();
            border.destroy();
            inputLabel.destroy();
            folderNameInput.destroy();
            createFolderButton.destroy();
            cancelFolderButton.destroy();
        });
        cancelFolderButton.scale.set(1.5, 1.5);
        add(cancelFolderButton);
    }
    
    /**
     * 确定按钮点击回调
     */
    private function onOkButtonClick():Void
    {
        var fileName = fileNameInput.text.trim();
        if (fileName == "")
        {
            return;
        }
        
        // 确保文件有正确的扩展名
        if (dialogType == FileDialogType.SAVE && fileExtension != "" && !fileName.endsWith(fileExtension))
        {
            fileName += fileExtension;
        }
        
        var fullPath = Path.join([currentPath, fileName]);
        
        // 如果是保存对话框，检查文件是否存在
        if (dialogType == FileDialogType.SAVE && FileSystem.exists(fullPath))
        {
            // 显示确认覆盖对话框
            var confirmBackground = new FlxSprite(dialogX + 200, dialogY + 280);
            confirmBackground.makeGraphic(400, 100, FlxColor.fromRGB(220, 220, 220));
            add(confirmBackground);
            
            // 添加边框
            var confirmBorder = new FlxSprite(dialogX + 200, dialogY + 280);
            confirmBorder.makeGraphic(400, 100, FlxColor.TRANSPARENT);
            // 绘制边框线
            var borderBitmap = new BitmapData(400, 100, true, FlxColor.TRANSPARENT);
            for (i in 0...400) {
                borderBitmap.setPixel32(i, 0, FlxColor.BLACK);
                borderBitmap.setPixel32(i, 99, FlxColor.BLACK);
            }
            for (i in 0...100) {
                borderBitmap.setPixel32(0, i, FlxColor.BLACK);
                borderBitmap.setPixel32(399, i, FlxColor.BLACK);
            }
            confirmBorder.loadGraphic(FlxGraphic.fromBitmapData(borderBitmap));
            add(confirmBorder);
            
            var confirmText = new FlxText(dialogX + 210, dialogY + 290, 380, 'File "$fileName" already exists.\nDo you want to replace it?', 16);
            confirmText.color = FlxColor.BLACK;
            add(confirmText);
            
            // 创建按钮变量
            var yesButton:FlxButton = null;
            var noButton:FlxButton = null;
            
            yesButton = new FlxButton(dialogX + 300, dialogY + 340, "Yes", function() {
                // 移除确认对话框
                remove(confirmBackground);
                remove(confirmBorder);
                remove(confirmText);
                remove(yesButton);
                remove(noButton);
                
                confirmBackground.destroy();
                confirmBorder.destroy();
                confirmText.destroy();
                yesButton.destroy();
                noButton.destroy();
                
                // 调用回调并关闭对话框
                callback(fullPath);
                close();
            });
            yesButton.scale.set(1.5, 1.5);
            add(yesButton);
            
            noButton = new FlxButton(dialogX + 400, dialogY + 340, "No", function() {
                // 移除确认对话框
                remove(confirmBackground);
                remove(confirmBorder);
                remove(confirmText);
                remove(yesButton);
                remove(noButton);
                
                confirmBackground.destroy();
                confirmBorder.destroy();
                confirmText.destroy();
                yesButton.destroy();
                noButton.destroy();
            });
            noButton.scale.set(1.5, 1.5);
            add(noButton);
        }
        else
        {
            // 调用回调并关闭对话框
            callback(fullPath);
            close();
        }
    }
    
    /**
     * 取消按钮点击回调
     */
    private function onCancelButtonClick():Void
    {
        close();
    }
    
    /**
     * 向上滚动
     */
    private function onScrollUp():Void
    {
        if (scrollOffset > 0)
        {
            scrollOffset--;
            refreshFileList();
        }
    }
    
    /**
     * 向下滚动
     */
    private function onScrollDown():Void
    {
        scrollOffset++;
        refreshFileList();
    }
    
    /**
     * 关闭对话框
     */
    public function close():Void
    {
        parent.remove(this);
        destroy();
    }
    
    /**
     * 更新
     */
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 处理ESC键关闭对话框
        if (FlxG.keys.justPressed.ESCAPE)
        {
            close();
        }
    }
}

/**
 * 文件项类
 */
class FileItem extends FlxGroup
{
    public var name:String;
    public var isDirectory:Bool;
    private var background:FlxSprite;
    private var text:FlxText;
    private var icon:FlxText;
    private var callback:String->Bool->Void;
    
    /**
     * 创建一个新的文件项
     * @param x X坐标
     * @param y Y坐标
     * @param width 宽度
     * @param name 文件/文件夹名称
     * @param isDirectory 是否为目录
     * @param callback 点击回调
     */
    public function new(x:Float, y:Float, width:Int, name:String, isDirectory:Bool, callback:String->Bool->Void)
    {
        super();
        
        this.name = name;
        this.isDirectory = isDirectory;
        this.callback = callback;
        
        // 背景
        background = new FlxSprite(x, y);
        background.makeGraphic(width, 25, FlxColor.WHITE);
        add(background);
        
        // 图标
        var iconText = isDirectory ? "📁" : "📄";
        icon = new FlxText(x + 5, y + 2, 20, iconText, 16);
        icon.color = FlxColor.BLACK;
        add(icon);
        
        // 文本
        text = new FlxText(x + 30, y + 2, width - 35, name, 14);
        text.color = FlxColor.BLACK;
        add(text);
        
        // 鼠标悬停效果
        background.ID = 1; // 用于标识这是一个可点击项
    }
    
    /**
     * 更新
     */
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // 检查鼠标悬停
        var mouseX = FlxG.mouse.x;
        var mouseY = FlxG.mouse.y;
        
        if (mouseX >= background.x && mouseX <= background.x + background.width &&
            mouseY >= background.y && mouseY <= background.y + background.height)
        {
            // 鼠标悬停效果
            background.color = FlxColor.fromRGB(230, 230, 255);
            
            // 检查鼠标点击
            if (FlxG.mouse.justPressed)
            {
                callback(name, isDirectory);
            }
        }
        else
        {
            // 恢复正常颜色
            background.color = FlxColor.WHITE;
        }
    }
}