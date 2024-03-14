FROM ubuntu:22.04 as installer

WORKDIR /Android

RUN apt update -y
RUN apt install -y \
            wget \
            unzip \
            libc6-dev-i386 \
            lib32z1 \
            openjdk-21-jdk

RUN mkdir -p Sdk/cmdline-tools/latest
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip -d tmp-cmd-lt commandlinetools-linux-11076708_latest.zip
RUN mv tmp-cmd-lt/cmdline-tools/* Sdk/cmdline-tools/latest/

RUN rm commandlinetools-linux-11076708_latest.zip
RUN rm -rf tmp-cmd-lt

ENV ANDROID_HOME="/Android/Sdk"
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"

RUN yes | sdkmanager --licenses 
RUN sdkmanager "system-images;android-34;default;x86_64" "platforms;android-34" "platform-tools" "build-tools;34.0.0"

FROM installer AS emulator

# Check that KVM acceleration can be used
RUN apt install cpu-checker -y

RUN sdkmanager "emulator"

ENV PATH="${PATH}:${ANDROID_HOME}/emulator"

RUN apt install -y \
            libpulse0

RUN echo "no" | avdmanager create avd --name android34 --package "system-images;android-34;default;x86_64"

FROM installer AS flutter

RUN apt install -y \
            xz-utils \
            git \
            curl \
            file \
            zip \
            clang \
            cmake \
            ninja-build \
            pkg-config \
            libgtk-3-dev \
            liblzma-dev \
            libstdc++-12-dev \
            ibcanberra-gtk-module \
            libcanberra-gtk3-module

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.3-stable.tar.xz
RUN tar xf flutter_linux_3.19.3-stable.tar.xz
RUN rm flutter_linux_3.19.3-stable.tar.xz

RUN git config --global --add safe.directory /Android/flutter

ENV PATH="${PATH}:/Android/flutter/bin"
ENV NO_AT_BRIDGE=1

WORKDIR /app

CMD ["flutter", "run"]
