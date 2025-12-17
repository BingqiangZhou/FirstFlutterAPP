# Flutter 环境配置指南（Windows）

本指南将帮助你在 Windows 系统上配置完整的 Flutter 开发环境，适合初学者。

## 1. 安装 Flutter SDK

### 方法一：通过官方网站下载（推荐）

1. 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install/windows)
2. 下载 Flutter SDK zip 文件
3. 解压到你想安装的目录（例如 `D:\flutter`）
4. 将 Flutter 的 `bin` 目录添加到系统环境变量 PATH 中：
   - 打开 "系统属性" → "高级" → "环境变量"
   - 在 "用户变量" 或 "系统变量" 中找到 PATH
   - 点击 "新建" 或 "编辑"，添加 `D:\flutter\bin`
5. 重新打开命令提示符（CMD）或 PowerShell 使环境变量生效

### 方法二：使用 Git 克隆

```bash
git clone https://github.com/flutter/flutter.git -b stable
```

克隆完成后，同样需要将 Flutter 的 `bin` 目录添加到 PATH 环境变量。

### 方法三：使用 Chocolatey 包管理器

如果你已安装 Chocolatey，可以运行：

```bash
choco install flutter
```

## 2. 验证 Flutter 安装

打开新的命令提示符（CMD）或 PowerShell，运行：

```bash
flutter --version
```

如果显示 Flutter 版本信息，说明安装成功。

然后运行：

```bash
flutter doctor
```

这个命令会检查你的环境配置，显示需要安装的组件。初学者可能会看到一些警告或错误，这是正常的，我们接下来会逐一解决。

## 3. 安装 Visual Studio（用于 Windows 桌面应用开发）

### 下载和安装

1. 访问 [Visual Studio 官网](https://visualstudio.microsoft.com/zh-hans/downloads/)
2. 下载 **Visual Studio 2022 Community**（免费版本）
3. 运行安装程序

### 选择工作负载

在安装程序界面：
1. 选择 **"使用 C++ 的桌面开发"** (Desktop development with C++)
2. 在右侧面板中确保勾选以下组件：
   - ✅ MSVC v143 - VS 2022 C++ x64/x86 生成工具
   - ✅ Windows 10/11 SDK（选择最新版本）
   - ✅ CMake tools（可选，用于高级构建）
3. 点击 "安装" 开始安装

安装可能需要较长时间，请耐心等待。

## 4. 安装 Android Studio（用于 Android 应用开发）

### 下载和安装

1. 访问 [Android Studio 官网](https://developer.android.com/studio)
2. 下载适用于 Windows 的安装包
3. 运行安装程序，按照提示完成安装

### 初始配置

首次启动 Android Studio 时：
1. 选择 **"Standard"**（标准）安装类型
2. 等待以下组件下载完成：
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Virtual Device（模拟器）

### 安装 Flutter 插件

1. 启动 Android Studio
2. 点击 **File** → **Settings**（Windows）或 **Android Studio** → **Preferences**（macOS）
3. 在左侧面板选择 **Plugins**
4. 点击搜索图标，输入 "Flutter"
5. 找到 **Flutter** 插件，点击 **Install**
6. 系统会提示安装 Dart 插件，点击 **Yes** 安装
7. 安装完成后，点击 **Restart IDE** 重启 Android Studio

## 5. 配置 Android 模拟器

### 创建虚拟设备

1. 在 Android Studio 中，点击 **Tools** → **AVD Manager**
2. 点击 **Create Virtual Device**
3. 选择设备型号：
   - 推荐选择：Pixel 6 或其他较新的设备
   - 点击 "Next"
4. 选择系统镜像：
   - 选择最新的 Android 版本（如 Android 13.0）
   - 如果显示 "Download" 旁有箭头图标，点击下载
   - 下载完成后，点击 "Next"
5. 配置 AVD：
   - 可以保持默认设置
   - 给 AVD 起一个名字（如 "Pixel_6_API_33"）
   - 点击 "Finish"

### 启动模拟器

在 AVD Manager 列表中，点击你创建的虚拟设备右侧的播放图标（▶）启动模拟器。

## 6. 验证完整环境

### 检查所有组件

再次运行 Flutter Doctor：

```bash
flutter doctor
```

理想情况下，你应该看到：

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Windows Version (Installed version of Windows)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows desktop
[✓] Android Studio (version 2022.x)
[✓] Connected device (1 available)
```

### 常见问题处理

#### 1. Android licenses not accepted

运行：
```bash
flutter doctor --android-licenses
```
按提示输入 'y' 接受所有许可协议。

#### 2. Chrome 未找到

下载并安装 [Google Chrome](https://www.google.com/chrome/)。

#### 3. "Unable to locate adb"

将 Android SDK 的 platform-tools 目录添加到 PATH 环境变量中：
```
C:\Users\你的用户名\AppData\Local\Android\Sdk\platform-tools
```

## 7. 测试环境

### 创建测试项目

1. 打开命令提示符，进入你想创建项目的目录
2. 运行：
```bash
flutter create test_app
cd test_app
```

### 在 Windows 上运行

```bash
flutter run -d windows
```

### 在 Android 模拟器上运行

确保模拟器已启动，然后运行：

```bash
flutter run
```

## 8. 开发工具推荐

### 代码编辑器选择

1. **Android Studio** - 功能最全面的 IDE，适合大型项目
2. **Visual Studio Code** - 轻量级，丰富的插件生态

### VS Code 配置（可选）

如果你选择 VS Code：

1. 下载并安装 [VS Code](https://code.visualstudio.com/)
2. 安装 Flutter 插件：
   - 打开 VS Code
   - 按 `Ctrl+Shift+X` 打开扩展面板
   - 搜索 "Flutter"
   - 安装 Flutter 扩展（会自动安装 Dart 扩展）
3. 按 `Ctrl+Shift+P`，输入 "Flutter: New Project" 创建项目

## 9. 环境变量管理（进阶）

为了更好地管理 Flutter 相关的环境变量，建议添加以下路径到系统 PATH：

1. Flutter SDK: `D:\flutter\bin`
2. Android SDK Platform-Tools: `C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools`
3. Android SDK Tools: `C:\Users\%USERNAME%\AppData\Local\Android\Sdk\tools`
4. Java（如果单独安装）: `C:\Program Files\Java\jdk-17.x.x_x\bin`

## 10. 下一步

环境配置完成后，你可以：

1. 阅读 [Flutter 官方文档](https://flutter.dev/docs)
2. 查看 [Flutter 中文文档](https://flutter.cn/docs)
3. 尝试运行示例项目
4. 开始学习 Dart 语言基础

## 常用 Flutter 命令速查

```bash
# 检查环境
flutter doctor

# 创建新项目
flutter create 项目名

# 获取依赖
flutter pub get

# 运行项目
flutter run

# 列出可用设备
flutter devices

# 构建 Android APK
flutter build apk

# 构建 Windows 应用
flutter build windows

# 升级 Flutter
flutter upgrade

# 清理项目
flutter clean
```

## 获取帮助

如果遇到问题，可以：

1. 查看 [Flutter 官方文档](https://flutter.dev/docs)
2. 访问 [Flutter 中文社区](https://flutter.cn/)
3. 在 Stack Overflow 搜索相关问题
4. 加入 Flutter 相关的 QQ 群或微信群

祝你学习愉快！🎉