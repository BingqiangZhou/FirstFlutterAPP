# GitHub Actions 自动化构建配置指南

本指南将帮助你配置 GitHub Actions，实现 Flutter 项目的自动化构建和多平台发布。

## 前置要求

1. 已有 GitHub 账号
2. 已将 Flutter 项目推送到 GitHub 仓库
3. 了解基本的 Git 操作

## 1. GitHub Actions 工作流程文件

创建 `.github/workflows/release.yml` 文件：

```yaml
name: Build and Release App

# 触发条件：当你推送 v* 标签时 (例如 v1.0.0)
on:
  push:
    tags:
      - "v*"
  workflow_dispatch:  # 允许手动触发

# 必须授予权限才能创建 Release
permissions:
  contents: write

jobs:
  # Android 构建任务
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Get Dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK to Release
        uses: ncipollo/release-action@v1
        with:
          allowUpdates: true
          artifacts: "build/app/outputs/flutter-apk/app-release.apk"
          token: ${{ secrets.GITHUB_TOKEN }}
          tag: ${{ github.ref_name }}
          name: Release ${{ github.ref_name }}

  # Windows 构建任务
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Get Dependencies
        run: flutter pub get

      - name: Build Windows
        run: flutter build windows --release

      - name: Archive Windows Release
        uses: thedoctor0/zip-release@0.7.1
        with:
          type: 'zip'
          filename: 'windows-release.zip'
          directory: 'build/windows/x64/runner/Release'

      - name: Upload Windows Zip to Release
        uses: ncipollo/release-action@v1
        with:
          allowUpdates: true
          artifacts: "build/windows/x64/runner/Release/windows-release.zip"
          token: ${{ secrets.GITHUB_TOKEN }}
          tag: ${{ github.ref_name }}

  # Linux 构建任务
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Linux Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Get Dependencies
        run: flutter pub get

      - name: Enable Linux Desktop
        run: flutter config --enable-linux-desktop

      - name: Build Linux
        run: flutter build linux --release

      - name: Archive Linux Release
        uses: thedoctor0/zip-release@0.7.1
        with:
          type: 'zip'
          filename: 'linux-release.zip'
          directory: 'build/linux/x64/release/bundle'

      - name: Upload Linux to Release
        uses: ncipollo/release-action@v1
        with:
          allowUpdates: true
          artifacts: "build/linux/x64/release/bundle/linux-release.zip"
          token: ${{ secrets.GITHUB_TOKEN }}
          tag: ${{ github.ref_name }}

  # macOS 构建任务
  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Get Dependencies
        run: flutter pub get

      - name: Enable macOS Desktop
        run: flutter config --enable-macos-desktop

      - name: Build macOS
        run: flutter build macos --release

      - name: Archive macOS Release
        uses: thedoctor0/zip-release@0.7.1
        with:
          type: 'zip'
          filename: 'macos-release.zip'
          directory: 'build/macos/Build/Products/Release'

      - name: Upload macOS to Release
        uses: ncipollo/release-action@v1
        with:
          allowUpdates: true
          artifacts: "build/macos/Build/Products/Release/macos-release.zip"
          token: ${{ secrets.GITHUB_TOKEN }}
          tag: ${{ github.ref_name }}
```

## 2. Android 应用签名（可选）

如果你需要发布签名的 Android APK，需要配置签名密钥。

### 2.1 生成签名密钥

在本地运行：

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2.2 配置 GitHub Secrets

在 GitHub 仓库中添加以下 Secrets：

1. 进入 GitHub 仓库页面
2. 点击 Settings → Secrets and variables → Actions
3. 点击 "New repository secret"，添加以下内容：

#### ANDROID_KEYSTORE_BASE64
将你的 keystore 文件转换为 base64：
```bash
base64 -i upload-keystore.jks | tr -d '\n'
```
复制输出结果作为 secret 值。

#### KEY_PASSWORD
你的 keystore 密码

#### ALIAS_PASSWORD
你的 alias 密码（通常和 keystore 密码相同）

#### KEY_ALIAS
你的 alias 名称（通常是 "upload"）

### 2.3 修改 Android 构建任务

在 `build-android` 任务中添加签名步骤：

```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.KEY_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.ALIAS_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=upload-keystore.jks" >> android/key.properties
```

### 2.4 配置 Android 项目

在 `android/app/build.gradle` 中添加签名配置：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('app/key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 3. 触发构建

### 3.1 通过标签触发

推送一个带版本标签的提交：

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 3.2 手动触发

1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build and Release App" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支并点击 "Run workflow"

## 4. 下载构建产物

构建完成后：

1. 进入仓库的 Releases 页面
2. 找到对应版本的 Release
3. 下载所需的构建产物：
   - `app-release.apk` - Android 安装包
   - `windows-release.zip` - Windows 应用
   - `linux-release.zip` - Linux 应用
   - `macos-release.zip` - macOS 应用

## 5. 高级配置

### 5.1 添加缓存加速构建

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

### 5.2 添加构建通知

通过邮件或 Slack 发送构建通知：

```yaml
- name: Notify on success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    channel: '#releases'
    text: '✅ ${{ github.repository }} ${{ github.ref_name }} 构建成功！'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### 5.3 多环境构建

为开发环境和生产环境创建不同的构建配置：

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - name: Set environment
        run: |
          if [[ $GITHUB_REF == 'refs/heads/main' ]]; then
            echo "FLUTTER_ENV=production" >> $GITHUB_ENV
          else
            echo "FLUTTER_ENV=development" >> $GITHUB_ENV
          fi
```

## 6. 故障排除

### 6.1 构建失败

1. 检查 Actions 日志中的错误信息
2. 确保所有依赖都在 `pubspec.yaml` 中正确配置
3. 验证 Flutter 版本兼容性

### 6.2 权限错误

确保 `permissions` 设置正确：
```yaml
permissions:
  contents: write
```

### 6.3 内存不足

对于大型项目，可能需要增加内存：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      FLUTTER_STORAGE_BASE_URL: https://storage.googleapis.com
```

## 7. 最佳实践

1. **版本管理**：使用语义化版本号（如 v1.0.0）
2. **环境分离**：为不同环境配置不同的构建流程
3. **依赖锁定**：锁定 Flutter 和依赖版本以避免构建不一致
4. **安全**：不要在代码中暴露敏感信息，使用 GitHub Secrets
5. **文档**：维护清晰的构建和部署文档

## 8. 相关资源

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [Flutter 构建和发布](https://flutter.dev/docs/deployment)
- [GitHub Actions 市场](https://github.com/marketplace?type=actions)

这样配置后，每次推送版本标签或手动触发，GitHub Actions 都会自动构建所有平台的应用并创建 Release。