FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Instala Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Instala Android SDK (command line tools)
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm sdk.zip

# Da permisos al usuario vscode
RUN chown -R vscode:vscode $FLUTTER_HOME $ANDROID_SDK_ROOT

# Cambia a usuario normal
USER vscode

# Configura git y flutter + acepta licencias
RUN git config --global --add safe.directory /opt/flutter && \
    flutter config --android-sdk $ANDROID_SDK_ROOT && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"
