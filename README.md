# Flutter 2048 游戏 🎮

这是一个使用 Flutter 框架开发的 2048 游戏，非常适合 Flutter 初学者学习和参考。

## 🌟 项目特色

- **学习友好**：单文件实现，代码结构清晰，适合 Flutter 入门学习
- **功能完整**：实现了 2048 游戏的所有核心功能
- **多平台支持**：一套代码，支持 Windows、Android、iOS、Linux、macOS 和 Web
- **自动化构建**：配置了 GitHub Actions，一键构建所有平台版本

## 📖 快速开始

### 🚀 对于初学者

如果你是 Flutter 新手，请先按照以下步骤配置开发环境：

1. **阅读环境配置指南**
   - 详细配置步骤请查看：[Flutter 环境配置指南](docs/Flutter环境配置指南.md)
   - 该指南包含 Windows 系统下完整的 Flutter 环境搭建步骤

2. **必要组件**
   - Flutter SDK
   - Visual Studio 2022（用于 Windows 桌面开发）
   - Android Studio（用于 Android 开发和模拟器）

3. **验证环境**
   ```bash
   flutter doctor
   ```

### 📦 运行项目

1. 克隆项目到本地
   ```bash
   git clone https://github.com/your-username/FirstFlutterAPP.git
   cd FirstFlutterAPP
   ```

2. 安装依赖
   ```bash
   flutter pub get
   ```

3. 运行项目
   - Windows 桌面版：`flutter run -d windows`
   - Android 模拟器：`flutter run`

## 🎯 游戏功能

- ⌨️ 支持键盘方向键控制
- 📱 支持触摸滑动手势
- 🏆 分数统计和最高分记录
- 🎨 响应式设计，适配不同屏幕尺寸

## 🛠️ 项目结构

```
lib/
├── main.dart          # 完整游戏逻辑（600行代码实现所有功能）
android/               # Android 平台相关配置
ios/                   # iOS 平台相关配置
windows/               # Windows 平台相关配置
linux/                 # Linux 平台相关配置
macos/                 # macOS 平台相关配置
web/                   # Web 平台相关配置
docs/                  # 文档目录
```

## 📚 学习资源

### 环境配置
- [Flutter 环境配置指南](docs/Flutter环境配置指南.md) - Windows 环境详细配置步骤

### 自动化部署
- [GitHub Actions 配置指南](docs/GitHub-Actions配置指南.md) - 多平台自动构建和发布配置

### 官方文档
- [Flutter 官方文档](https://flutter.dev/docs)
- [Flutter 中文网](https://flutter.cn/docs)
- [Dart 语言指南](https://dart.dev/guides)

## 🎮 游戏玩法

- **目标**：通过移动和合并数字方块，最终得到 2048 这个数字
- **操作方式**：
  - 键盘：使用方向键（↑↓←→）移动方块
  - 触摸：在屏幕上滑动手指
- **规则**：
  - 相同数字的方块碰撞时会合并成一个
  - 每次成功合并会获得相应的分数
  - 当无法移动且没有空格时游戏结束

## 📝 代码特点

这个项目特别适合学习 Flutter，因为：

1. **单文件实现**：所有游戏逻辑都在 `main.dart` 中，便于理解整体结构
2. **状态管理**：使用基础的 `setState` 方法，适合初学者理解 Flutter 的状态更新机制
3. **响应式布局**：展示了如何创建适应不同屏幕尺寸的 UI
4. **事件处理**：包含键盘事件和触摸手势的处理示例
5. **游戏逻辑**：完整的游戏算法实现，包括移动、合并、胜负判断

## 🚀 构建和发布

### 本地构建

```bash
# Android APK
flutter build apk --release

# Windows 应用
flutter build windows --release

# Web 应用
flutter build web
```

### 自动化构建

项目已配置 GitHub Actions，可以自动构建所有平台：

1. 推送版本标签（如 `v1.0.0`）
2. GitHub Actions 会自动构建所有平台
3. 构建产物会自动上传到 Releases

详细配置请参考：[GitHub Actions 配置指南](docs/GitHub-Actions配置指南.md)

## 💡 学习建议

1. **先运行项目**：体验游戏功能，了解整体实现
2. **阅读代码**：从 `main.dart` 开始，理解游戏逻辑
3. **尝试修改**：改变游戏规则、界面样式等
4. **学习 Flutter**：通过实际代码学习 Flutter 概念

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License