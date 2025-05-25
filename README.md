# 📱 Setting Up Flutter for Android Development on Fedora Linux

This guide walks you through installing and configuring Flutter for Android development on **Fedora Linux**. It includes common errors and their solutions.

---

## ✅ Prerequisites

Before installing Flutter, ensure your system has the following:

### Install development tools and libraries:

```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install curl git unzip xz zip clang cmake ninja-build pkgconfig gtk3 gtk3-devel libblkid-devel liblzma-devel
```

### Install Java (required for Android builds):

```bash
sudo dnf install java-17-openjdk
```

---

## 📦 Install Flutter SDK

### 1. Download Flutter SDK:

Visit [Flutter Linux installation page](https://docs.flutter.dev/get-started/install/linux) or run:

```bash
cd ~
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.0-stable.tar.xz
tar xf flutter_linux_3.32.0-stable.tar.xz
```

### 2. Add Flutter to your PATH:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

> Use `~/.zshrc` instead if you're using Zsh.

### 3. Verify installation:

```bash
flutter doctor
```

---

## 📱 Set Up Android Development Environment

### 1. Install Android Studio (Recommended)

* Download from: [https://developer.android.com/studio](https://developer.android.com/studio)
* Extract and run:

```bash
tar -xvzf android-studio-*.tar.gz
cd android-studio/bin
./studio.sh
```

* During setup, make sure to install:

  * Android SDK
  * Android SDK Platform Tools
  * Android SDK Command-line Tools

### 2. Accept Android Licenses:

```bash
flutter doctor --android-licenses
```

> Press `y` to accept all.

### 3. Connect Android Device:

* Enable **Developer Options** on the phone
* Enable **USB Debugging**
* Connect via USB and run:

```bash
flutter devices
```

---

## 🛠️ Fixing Common Errors

### ❌ Error: `cmdline-tools component is missing`

**Solution:**

* Open Android Studio > SDK Manager > SDK Tools
* Enable **Android SDK Command-line Tools (latest)**

**OR manually:**

```bash
cd ~/Android
mkdir -p cmdline-tools/latest
cd cmdline-tools
curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip -d latest
```

Add to your `~/.bashrc`:

```bash
export ANDROID_HOME=$HOME/Android
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
```

### ❌ Error: `Android license status unknown`

**Solution:**

```bash
flutter doctor --android-licenses
```

### ❌ Error: `Linux toolchain - clang++, cmake, ninja missing`

**Solution:**

```bash
sudo dnf install clang cmake ninja-build
```

### ❌ Error: `Unable to access driver information using 'eglinfo'`

**Solution (Fedora-specific):**

```bash
sudo dnf install egl-utils
```

### ❌ Error: `VS Code version unknown`

**Solution:**
Ensure VS Code is in your PATH:

```bash
export PATH="/usr/share/code/bin:$PATH"
```

---

## 🧪 Create and Run a Flutter App

```bash
flutter create my_app
cd my_app
flutter run
```

---

## 🎉 You're Ready!
 Happy coding! 🚀
