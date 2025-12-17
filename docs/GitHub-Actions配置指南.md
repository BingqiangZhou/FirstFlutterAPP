# GitHub Actions 自动化构建配置指南

本指南详细介绍如何配置 GitHub Actions，实现 Flutter 项目的自动化构建和多平台发布。

## 目录

1. [基础概念](#基础概念)
2. [工作流文件详解](#工作流文件详解)
3. [Flutter 版本管理](#flutter-版本管理)
4. [Android 平台配置](#android-平台配置)
5. [Windows 平台配置](#windows-平台配置)
6. [Linux 平台配置](#linux-平台配置)
7. [macOS 平台配置](#macos-平台配置)
8. [Release 管理策略](#release-管理策略)
9. [高级配置](#高级配置)
10. [最佳实践](#最佳实践)
11. [故障排除](#故障排除)

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
- 注意：新版本的 GitHub Actions 不再需要 `releases: write` 权限
- 其他权限选项：
  - `actions: read/write`：读取/写入 Actions
  - `checks: read/write`：读取/写入检查
  - `packages: read/write`：读取/写入包

### 3. Flutter 版本管理

#### 使用 Channel 自动获取最新版本（推荐）

```yaml
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'  # 自动使用最新稳定版本
```

**优点：**
- 自动获取最新的稳定版本，无需手动维护版本号
- 安全更新，自动包含最新的 bug 修复和安全补丁
- 减少配置复杂度

#### 指定特定版本（不推荐）

```yaml
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'
    version: '3.19.6'  # 指定特定版本
```

**缺点：**
- 需要手动更新版本号
- 可能错过重要的安全更新
- 增加维护成本

#### Flutter Channels 说明

1. **stable**：稳定版本，推荐用于生产环境
2. **beta**：预览版本，包含新功能但可能不稳定
3. **dev**：开发版本，包含最新功能但可能有 bug
4. **master**：主线开发版本，功能最全但最不稳定

#### 版本兼容性

- Flutter 3.x 需要 Java 17
- 建议使用 `channel: 'stable'` 而不是固定版本号
- 对于关键项目，可以考虑锁定版本

### 4. 任务并行执行

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

#### 6. 缓存优化（推荐）

为了加速构建，建议添加以下缓存配置：

```yaml
# Gradle 缓存
- name: Cache Gradle dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-

# Flutter 缓存
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      /opt/hostedtoolcache/Flutter  # Linux/macOS
      # Windows 使用: C:\Users\runneradmin\.pub-cache 和 D:\a\_tool\Flutter
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-flutter-
```

#### 7. 构建 APK

**其他构建选项：**
- `flutter build apk --release`：普通 APK
- `flutter build appbundle --release`：Android App Bundle（推荐用于 Google Play）
- `flutter build apk --split-per-abi --release`：按 ABI 分离的 APK

#### 8. 上传到 Release
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

## Release 管理策略

### Build First, Release Last 策略（推荐）

我们采用"先构建，后发布"的策略，这是现代 CI/CD 的最佳实践：

```yaml
# 1. 并行构建所有平台
jobs:
  build-android:
    # ... 构建 Android APK
    steps:
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-windows:
    # ... 构建 Windows 应用
    steps:
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: windows-zip
          path: build/windows/x64/runner/Release/flutter-2048-windows.zip

  # 2. 所有构建完成后，创建 Release
  create-release:
    needs: [build-android, build-windows, build-linux, build-macos]
    runs-on: ubuntu-latest
    steps:
      # 下载所有构建产物
      - name: Download all artifacts
        uses: actions/download-artifact@v3

      # 创建 Release 并上传所有资产
      - name: Create Release and Upload Assets
        uses: softprops/action-gh-release@v1
        with:
          files: |
            android-apk/*.apk
            windows-zip/*.zip
            linux-zip/*.zip
            macos-zip/*.zip
```

**优势：**
- ✅ 构建失败时不会创建空 Release
- ✅ 可以重试 Release 步骤而无需重新构建
- ✅ 更好的错误隔离和调试
- ✅ 支持 Draft Release 和预发布

### Artifact vs Release Asset

#### Artifacts（构建产物）
- **用途**：临时存储构建结果
- **生命周期**：默认保留 30 天
- **访问权限**：仅项目成员
- **典型用途**：在 CI/CD 流水线中传递文件

```yaml
# 上传构建产物
- name: Upload build artifacts
  uses: actions/upload-artifact@v3
  with:
    name: android-apk
    path: build/app/outputs/flutter-apk/app-release.apk
    retention-days: 7  # 可配置保留天数
```

#### Release Assets（发布资产）
- **用途**：正式发布给用户下载
- **生命周期**：永久保留（除非手动删除）
- **访问权限**：公开或根据仓库设置
- **典型用途**：版本发布、用户下载

```yaml
# 上传到 Release
- name: Create Release and Upload Assets
  uses: softprops/action-gh-release@v1
  with:
    files: |
      android-apk/*.apk
      windows-zip/*.zip
```

### 版本号管理

#### 语义化版本（Semantic Versioning）
推荐使用 `v主版本.次版本.修订版本` 格式：
- `v1.0.0` - 首次正式发布
- `v1.1.0` - 新功能发布
- `v1.1.1` - Bug 修复发布

#### 创建版本标签

```bash
# 本地创建标签
git tag v1.0.0

# 推送标签到远程（会触发 GitHub Actions）
git push origin v1.0.0

# 批量推送所有标签
git push origin --tags
```

### 自动化 Release Notes

GitHub Actions 可以自动生成基于提交历史的 Release Notes：

```yaml
- name: Create Release and Upload Assets
  uses: softprops/action-gh-release@v1
  with:
    generate_release_notes: true  # 自动生成 Release Notes
```

## 高级配置

### 1. 缓存优化

缓存可以显著减少构建时间，特别是对于频繁构建的项目。

#### Flutter 缓存

```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache                              # Pub 依赖缓存
      /opt/hostedtoolcache/Flutter             # Flutter SDK 缓存（Linux/macOS）
      # Windows 路径:
      # C:\Users\runneradmin\.pub-cache
      # D:\a\_tool\Flutter
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-flutter-
```

#### Gradle 缓存（Android）

```yaml
- name: Cache Gradle dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-
```

#### 启用 Flutter 内置缓存

```yaml
- name: Setup Flutter environment
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'
    cache: true  # 启用 Flutter 内置缓存
```

#### 缓存最佳实践

1. **合理的缓存键**：
   - 使用 `hashFiles` 确保依赖变更时缓存失效
   - 包含操作系统信息 `${{ runner.os }}`

2. **多级回退**：
   - 使用 `restore-keys` 提供部分匹配的缓存
   - 允许使用旧版本缓存作为基础

3. **缓存路径选择**：
   - 只缓存必要的目录
   - 避免缓存临时文件和日志

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

#### 1. Release 创建失败（Error 422）

**问题**：Release 已存在或验证失败

**解决方案**：
- 使用 `allowUpdates: true` 允许更新已存在的 Release
- 采用 "Build First, Release Last" 策略避免重复创建
- 确保标签名唯一

```yaml
- name: Create Release and Upload Assets
  uses: softprops/action-gh-release@v1
  with:
    allowUpdates: true
    tag_name: ${{ github.ref_name }}
```

#### 2. 构建超时

**问题**：构建过程超过默认时间限制

**解决方案**：
```yaml
- name: Build with timeout
  timeout-minutes: 30
  run: flutter build apk --release
```

#### 3. Actions 已弃用

**问题**：使用了已弃用的 Actions 如 `actions/create-release`

**解决方案**：
- 使用 `softprops/action-gh-release@v1` 替代
- 定期检查 Actions 的更新状态

```yaml
# 旧版本（已弃用）
- uses: actions/create-release@v1

# 新版本（推荐）
- uses: softprops/action-gh-release@v1
```

#### 4. Flutter 版本问题

**问题**：固定版本号导致构建失败

**解决方案**：
```yaml
# 不推荐
- uses: subosito/flutter-action@v2
  with:
    version: '3.19.6'  # 固定版本

# 推荐
- uses: subosito/flutter-action@v2
  with:
    channel: 'stable'  # 自动使用最新稳定版本
```

#### 5. 内存不足

**问题**：构建过程中内存溢出

**解决方案**：
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      FLUTTER_CACHE_DIR: ${{ runner.temp }}/flutter-cache
```

#### 6. 网络问题

**问题**：依赖下载失败

**解决方案**：
```yaml
- name: Configure Flutter for China
  run: |
    export PUB_HOSTED_URL=https://pub.flutter-io.cn
    export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
    flutter doctor
```

#### 7. Artifact 下载失败

**问题**：Release 任务找不到构建产物

**解决方案**：
- 确保 `retention-days` 足够长
- 使用正确的 artifact 名称
- 添加 `if: always()` 确保上传执行

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v3
  if: always()  # 即使构建失败也尝试上传日志
  with:
    name: android-apk
    path: build/app/outputs/flutter-apk/app-release.apk
    retention-days: 7
```

#### 8. YAML 语法错误

**问题**：GitHub Actions 配置文件语法错误

**常见错误和解决方案**：

1. **权限配置错误**
   ```yaml
   # 错误（旧版本）
   permissions:
     contents: write
     releases: write  # 不再需要

   # 正确（新版本）
   permissions:
     contents: write
   ```

2. **条件语句中无法使用secrets**

   GitHub Actions不支持在`if`条件中直接使用secrets。解决方案：

   ```yaml
   # 错误（不支持）
   - name: Step with secret condition
     if: ${{ secrets.MY_SECRET != '' }}

   # 正确的解决方案1：使用环境变量
   - name: Check configuration
     run: |
       if [ "${{ secrets.MY_SECRET }}" != "" ]; then
         echo "CONFIG_ENABLED=true" >> $GITHUB_ENV
       else
         echo "CONFIG_ENABLED=false" >> $GITHUB_ENV

   - name: Conditional step
     if: env.CONFIG_ENABLED == 'true'
     run: echo "Secret is configured"

   # 正确的解决方案2：在脚本内部检查
   - name: Step with internal check
     run: |
       if [ "${{ secrets.MY_SECRET }}" != "" ]; then
         echo "Secret exists, proceeding..."
         # 使用secret的逻辑
       else
         echo "No secret, skipping..."
       fi
   ```

   **说明**：GitHub Actions限制secrets只能在`run`步骤和action的`with`参数中使用，不能在`if`条件中直接使用。

3. **空的环境变量块**
   ```yaml
   # 错误
   env:
     # 注释不能作为唯一内容

   # 正确（如果不需要全局环境变量，可以删除整个块）
   # 或者删除 env 块
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
   - 避免使用已弃用的 Actions（如 `actions/create-release`）

2. **Flutter 版本管理**
   - 使用 `channel: 'stable'` 而不是固定版本号
   - 这确保自动获取最新的稳定版本和安全更新
   - 减少手动维护成本

3. **采用"Build First, Release Last"策略**
   - 先并行构建所有平台，最后创建 Release
   - 使用 Artifacts 传递构建结果
   - 避免构建失败时创建空 Release

4. **合理使用缓存**
   - 缓存 Flutter 依赖和构建工具
   - 缓存 Gradle、CMake 等构建系统依赖
   - 可以显著减少构建时间

5. **安全的密钥管理**
   - 使用 GitHub Secrets 存储敏感信息
   - 不要在代码中硬编码密钥或证书
   - 定期轮换签名证书

6. **平台特定的构建环境**
   - Android: 使用 `ubuntu-latest`
   - Windows: 必须使用 `windows-latest`
   - macOS: 必须使用 `macos-latest`
   - Linux: 使用 `ubuntu-latest` 并安装必要的系统依赖

7. **错误处理和调试**
   - 添加详细的日志输出
   - 使用 `if: always()` 确保清理步骤执行
   - 上传构建日志以便调试

8. **清晰的命名和文档**
   - 为步骤和文件使用描述性名称
   - 在工作流文件中添加详细注释
   - 维护详细的配置文档

## 总结

通过这个优化的 GitHub Actions 配置，你可以实现：

1. **现代化 CI/CD 流程**
   - 使用最新的稳定版 Flutter
   - 采用 "Build First, Release Last" 最佳实践
   - 使用现代 GitHub Actions（避免已弃用的 Actions）

2. **自动化多平台构建**
   - Android、Windows、Linux、macOS 并行构建
   - 平台特定的优化配置
   - 自动依赖管理和缓存

3. **智能 Release 管理**
   - 避免重复创建 Release
   - 自动生成 Release Notes
   - 支持更新已存在的 Release

4. **高效的构建策略**
   - 并行构建节省时间
   - 智能缓存加速构建
   - 详细的错误处理和日志

5. **安全性和可维护性**
   - 安全的密钥管理
   - 清晰的文档和注释
   - 易于调试和故障排除

### 关键改进点

- ✅ **Flutter 版本管理**：使用 `channel: 'stable'` 自动获取最新稳定版本
- ✅ **Release 策略**：采用 "Build First, Release Last" 避免 Release 冲突
- ✅ **现代化 Actions**：替换所有已弃用的 Actions
- ✅ **错误处理**：增强的错误处理和调试能力
- ✅ **文档完善**：详细的配置说明和最佳实践

记得根据项目需求调整配置，定期更新 Actions 版本，并关注 Flutter 的版本更新以获得最新功能和安全改进。