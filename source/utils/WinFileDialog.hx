package utils;

/**
 * 此类已被弃用，请直接使用lime.ui.FileDialog
 * @deprecated
 */
class WinFileDialog
{
    /**
     * 打开文件对话框
     * @param title 对话框标题
     * @param filter 文件过滤器，格式为"描述|*.扩展名"，如"JSON文件|*.json"
     * @param defaultPath 默认路径
     * @return 选择的文件路径，如果取消则返回null
     * @deprecated 请使用lime.ui.FileDialog
     */
    public static function openFile(title:String = "Open File", filter:String = "All Files|*.*", defaultPath:String = ""):String
    {
        trace("WinFileDialog is deprecated. Please use lime.ui.FileDialog instead.");
        return null;
    }
    
    /**
     * 保存文件对话框
     * @param title 对话框标题
     * @param filter 文件过滤器，格式为"描述|*.扩展名"，如"JSON文件|*.json"
     * @param defaultPath 默认路径
     * @param defaultFileName 默认文件名
     * @return 选择的文件路径，如果取消则返回null
     * @deprecated 请使用lime.ui.FileDialog
     */
    public static function saveFile(title:String = "Save File", filter:String = "All Files|*.*", defaultPath:String = "", defaultFileName:String = ""):String
    {
        trace("WinFileDialog is deprecated. Please use lime.ui.FileDialog instead.");
        return null;
    }
}