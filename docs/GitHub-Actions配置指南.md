# GitHub Actions 自动化构建配置指南

本指南详细介绍如何配置 GitHub Actions，实现 Flutter 项目的自动化构建和多平台发布。

## 目录

1. [基础概念](#基础概念)
2. [工作流文件详解](#工作流文件详解)
3. [Android 平台配置](#android-平台配置)
4. [Windows 平台配置](#windows-平台配置)
5. [Linux 平台配置](#linux-平台配置)
6. [macOS 平台配置](#macos-平台配置)
7. [高级配置](#高级配置)
8. [故障排除](#故障排除)

## 基础概念

### 什么是 GitHub Actions？

GitHub Actions 是 GitHub 提供的 CI/CD（持续集成/持续部署）服务，可以自动执行构建、测试和部署任务。

### 工作流程文件

GitHub Actions 的配置文件位于 `.github/workflows/` 目录下，使用 YAML 格式编写。我们的工作流文件名为 `release.yml`。

### 基本结构

```yaml
name: 工作流名称
on:  # 触发条件
  # ... 触发器配置
permissions:  # 权限设置
  # ... 权限配置
jobs:  # 任务列表
  job-name:
    runs-on: 运行环境
    steps:  # 步骤列表
      - name: 步骤名称
        # ... 步骤配置
```

## 工作流文件详解

### 1. 触发条件配置

```yaml
on:
  push:
    tags:
      - "v*"  # 匹配所有以 v 开头的标签，如 v1.0.0
  workflow_dispatch:  # 允许在 GitHub Actions 页面手动触发
```

**说明：**
- `push.tags`：当推送匹配模式的标签时触发
- `workflow_dispatch`：允许在 GitHub 界面手动运行工作流

### 2. 权限设置

```yaml
permissions:
  contents: write  # 必须有写权限才能创建 Release
```

**说明：**
- `contents: write`：允许向仓库写入内容（创建 Release）
- 其他权限选项：
  - `actions: read/write`：读取/写入 Actions
  - `checks: read/write`：读取/写入检查
  - `packages: read/write`：读取/写入包

### 3. 任务并行执行

默认情况下，所有 `jobs` 是并行执行的，这样可以加快构建速度。如果需要顺序执行，可以使用 `needs` 关键字：

```yaml
jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      # ... 测试步骤

  build-android:
    needs: build-test  # 依赖 build-test 任务完成
    runs-on: ubuntu-latest
    steps:
      # ... 构建步骤
```

## Android 平台配置

### 关键配置点

```yaml
build-android:
  runs-on: ubuntu-latest  # 使用 Ubuntu 环境
```

### 详细步骤说明

#### 1. 检出代码
```yaml
- name: Checkout repository
  uses: actions/checkout@v3
```
- 获取仓库源代码到工作目录
- `@v3` 是 Action 的版本号，建议使用具体版本确保稳定性

#### 2. 设置 Java 环境
```yaml
- name: Setup Java environment
  uses: actions/setup-java@v3
  with:
    distribution: 'temurin'  # Eclipse Temurin JDK（推荐）
    java-version: '17'       # Flutter 3.x 需要 Java 17
```
- Android 构建需要 Java 环境
- Flutter 3.0+ 要求 Java 17

#### 3. 设置 Flutter 环境
```yaml
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'  # 可选：stable、beta、dev、master
    # cache: true      # 可选：启用缓存加速构建
```
- 自动安装 Flutter SDK
- 支持指定 Flutter 频道

#### 4. 获取依赖
```yaml
- name: Get Flutter dependencies
  run: flutter pub get
```
- 下载 `pubspec.yaml` 中定义的依赖包

#### 5. [可选] Android 应用签名

如果需要发布签名的 APK：

```yaml
- name: Decode Android keystore (if configured)
  run: |
    if [ "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" != "" ]; then
      echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks
      echo "storePassword=${{ secrets.KEY_PASSWORD }}" > android/key.properties
      echo "keyPassword=${{ secrets.ALIAS_PASSWORD }}" >> android/key.properties
      echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
      echo "storeFile=upload-keystore.jks" >> android/key.properties
    fi
```

**配置 GitHub Secrets：**
1. 进入仓库 Settings → Secrets and variables → Actions
2. 添加以下 Secrets：
   - `ANDROID_KEYSTORE_BASE64`：keystore 文件的 base64 编码
   - `KEY_PASSWORD`：keystore 密码
   - `ALIAS_PASSWORD`：别名密码
   - `KEY_ALIAS`：密钥别名

#### 6. 构建 APK
```yaml
- name: Build Android APK
  run: flutter build apk --release
```

**其他构建选项：**
- `flutter build apk --release`：普通 APK
- `flutter build appbundle --release`：Android App Bundle（推荐用于 Google Play）
- `flutter build apk --split-per-abi --release`：按 ABI 分离的 APK

#### 7. 上传到 Release
```yaml
- name: Upload APK to GitHub Release
  uses: ncipollo/release-action@v1
  with:
    allowUpdates: true  # 允许更新已存在的 Release
    artifacts: "build/app/outputs/flutter-apk/app-release.apk"
    token: ${{ secrets.GITHUB_TOKEN }}
    tag: ${{ github.ref_name }}
    name: Release ${{ github.ref_name }}
    body: "Auto-generated release for Android platform.\n\nVersion: ${{ github.ref_name }}"
```

### Android 构建优化技巧

1. **启用 Gradle 缓存**
```yaml
- name: Cache Gradle dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

2. **并行构建 ABI**
```yaml
- name: Build APK for all ABIs
  run: |
    flutter build apk --release --split-per-abi
    ls -la build/app/outputs/flutter-apk/
```

## Windows 平台配置

### 关键配置点

```yaml
build-windows:
  runs-on: windows-latest  # 必须使用 Windows 环境
```

### 详细步骤说明

#### 1. 构建环境
Windows 平台构建需要：
- Windows Server 2019 或更新版本
- Visual Studio 2019 或更新版本（已预装在 GitHub Runner 中）
- MSVC 编译器

#### 2. 构建步骤

```yaml
# 1. 检出代码
- name: Checkout repository
  uses: actions/checkout@v3

# 2. 设置 Flutter
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'

# 3. 获取依赖
- name: Get Flutter dependencies
  run: flutter pub get

# 4. 构建 Windows 应用
- name: Build Windows application
  run: flutter build windows --release
```

#### 3. 打包和上传

```yaml
# 5. 打包成 ZIP
- name: Archive Windows release
  uses: thedoctor0/zip-release@0.7.1
  with:
    type: 'zip'
    filename: 'flutter-2048-windows.zip'
    directory: 'build/windows/x64/runner/Release'

# 6. 上传
- name: Upload Windows ZIP to GitHub Release
  uses: ncipollo/release-action@v1
  with:
    allowUpdates: true
    artifacts: "build/windows/x64/runner/Release/flutter-2048-windows.zip"
    token: ${{ secrets.GITHUB_TOKEN }}
    tag: ${{ github.ref_name }}
```

### Windows 构建输出目录结构

```
build/windows/x64/runner/Release/
├── your_app.exe          # 主程序
├── your_app.pdb          # 调试符号文件
├── flutter_windows.dll   # Flutter Windows DLL
├── ...                   # 其他依赖 DLL
└── data/                 # 应用资源目录
    └── flutter_assets/   # Flutter 资源文件
```

### Windows 构建优化

1. **增量构建**
```yaml
- name: Enable incremental builds
  run: |
    flutter config --enable-windows-desktop
    flutter build windows --release -v
```

2. **压缩优化**
```yaml
- name: Create optimized ZIP
  run: |
    cd build/windows/x64/runner/Release
    7z a -tzip -mx=9 ../../../../flutter-2048-windows.zip *
```

## Linux 平台配置

### 关键配置点

```yaml
build-linux:
  runs-on: ubuntu-latest  # 使用 Ubuntu 环境
```

### 系统依赖安装

Linux 桌面应用需要安装特定的系统库：

```yaml
- name: Install Linux build dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y \
      clang \              # C++ 编译器
      cmake \              # 构建系统
      ninja-build \        # 快速构建工具
      pkg-config \         # 包配置工具
      libgtk-3-dev \       # GTK 3 开发库
      libglib2.0-dev \     # GLib 库
      libpango1.0-dev \    # Pango 文本布局库
      libatk1.0-dev \      # ATK 可访问性工具包
      libcairo-gobject2 \  # Cairo 图形库
      libgdk-pixbuf2.0-dev \  # GDK Pixbuf 库
      libgraphene-1.0-dev \   # Graphene 图形库
      libharfbuzz-dev      # HarfBuzz 文本整形库
```

### 启用 Linux 桌面支持

```yaml
- name: Enable Linux desktop support
  run: flutter config --enable-linux-desktop
```

### 构建步骤

```yaml
- name: Build Linux application
  run: flutter build linux --release
```

### Linux 构建输出目录

```
build/linux/x64/release/bundle/
├── your_app             # 可执行文件
├── lib/                 # 共享库目录
│   ├── libflutter_linux_gtk.so
│   └── ...              # 其他 .so 文件
├── data/                # 应用资源
│   └── flutter_assets/
└── your_app.desktop     # 桌面入口文件
```

### 创建 AppImage（可选）

```yaml
- name: Create AppImage
  run: |
    # 下载 linuxdeploy
    wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    chmod +x linuxdeploy-x86_64.AppImage

    # 创建 AppDir
    ./linuxdeploy-x86_64.AppImage --appdir AppDir --executable build/linux/x64/release/bundle/your_app --create-desktop-file --icon-file your_icon.png

    # 创建 AppImage
    ./linuxdeploy-x86_64.AppImage --appdir AppDir --output appimage
```

## macOS 平台配置

### 关键配置点

```yaml
build-macos:
  runs-on: macos-latest  # 必须使用 macOS 环境
```

### 构建步骤

```yaml
# 1. 检出代码
- name: Checkout repository
  uses: actions/checkout@v3

# 2. 设置 Flutter
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'

# 3. 获取依赖
- name: Get Flutter dependencies
  run: flutter pub get

# 4. 启用 macOS 桌面支持
- name: Enable macOS desktop support
  run: flutter config --enable-macos-desktop

# 5. 构建 macOS 应用
- name: Build macOS application
  run: flutter build macos --release
```

### macOS 构建输出目录

```
build/macos/Build/Products/Release/
└── YourApp.app/         # 应用程序包
    ├── Contents/
    │   ├── Info.plist
    │   ├── MacOS/
    │   │   └── YourApp       # 可执行文件
    │   ├── Frameworks/       # 框架目录
    │   └── Resources/        # 资源目录
    │       └── flutter_assets/
```

### 代码签名（可选）

如需代码签名，需要配置开发者证书：

```yaml
- name: Import Code-Signing Certificates
  uses: Apple-Actions/import-codesign-certs@v1
  with:
    p12-file-base64: ${{ secrets.CERTIFICATES_BASE64 }}
    p12-password: ${{ secrets.CERTIFICATES_PASSWORD }}

- name: Install the Provisioning Profile
  uses: Apple-Actions/install-provisioning-profile@v1
  with:
    provisioning-profile-base64: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
    provisioning-profile-path: ${{ runner.home }}/Library/MobileDevice/Provisioning\ Profiles
```

## 高级配置

### 1. 缓存优化

```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      /opt/hostedtoolcache/Flutter
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-flutter-
```

### 2. 构建矩阵

同时构建多个 Flutter 版本：

```yaml
strategy:
  matrix:
    flutter-channel: ['stable', 'beta']
    include:
      - flutter-channel: 'stable'
        flutter-version: '3.16.0'
      - flutter-channel: 'beta'
        flutter-version: '3.19.0'

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(env.matrix) }}
    steps:
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: ${{ matrix.flutter-channel }}
          version: ${{ matrix.flutter-version }}
```

### 3. 条件执行

根据平台选择执行特定任务：

```yaml
- name: Platform-specific task
  if: matrix.platform == 'android'
  run: |
    echo "Running Android-specific task"
```

### 4. 通知配置

构建完成后发送通知：

```yaml
- name: Notify on success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    channel: '#releases'
    text: '✅ Build succeeded for ${{ github.repository }} ${{ github.ref_name }}'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    channel: '#releases'
    text: '❌ Build failed for ${{ github.repository }} ${{ github.ref_name }}'
```

## 故障排除

### 常见问题

#### 1. 构建超时

增加超时时间：

```yaml
- name: Build with timeout
  timeout-minutes: 30
  run: flutter build apk --release
```

#### 2. 内存不足

增加内存资源：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      FLUTTER_CACHE_DIR: ${{ runner.temp }}/flutter-cache
```

#### 3. 网络问题

使用国内镜像：

```yaml
- name: Configure Flutter for China
  run: |
    export PUB_HOSTED_URL=https://pub.flutter-io.cn
    export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
    flutter doctor
```

### 调试技巧

1. **启用详细日志**
```yaml
- name: Build with verbose output
  run: flutter build apk --release -v
```

2. **上传构建日志**
```yaml
- name: Upload build logs
  uses: actions/upload-artifact@v3
  if: failure()
  with:
    name: build-logs
    path: |
      flutter_*.log
      build/**/*.log
```

3. **调试构建环境**
```yaml
- name: Debug environment
  run: |
    echo "Flutter version:"
    flutter --version
    echo "Java version:"
    java -version
    echo "Android SDK location:"
    echo $ANDROID_HOME
```

### 最佳实践

1. **使用具体版本的 Actions**
   - 使用 `@v3` 而不是 `@latest`，确保构建稳定性

2. **合理使用缓存**
   - 缓存依赖可以显著加速构建

3. **定期更新依赖**
   - 定期检查并更新 Actions 版本

4. **安全的密钥管理**
   - 使用 GitHub Secrets 存储敏感信息

5. **清晰的命名**
   - 为步骤和文件使用描述性名称

## 总结

通过这个 GitHub Actions 配置，你可以实现：

1. **自动化多平台构建**
2. **自动创建 GitHub Releases**
3. **并行构建提高效率**
4. **灵活的配置选项**

记得根据项目需求调整配置，并定期更新 Actions 版本以获得最新功能和安全更新。