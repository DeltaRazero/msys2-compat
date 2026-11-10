# msys2-compat

A small suite of scripts and utilities to improve runtime behaviour when using MSYS2 shells on Windows. It also resolves conflicts when running select MSYS2 tools in native Windows shells (such as CMD or PowerShell), and vice versa.

## Prerequisites

Make sure you have the following ready before installing:

- **A Sudo Provider**
  - **Windows 11 (Build 26045+):** You can use the native **Sudo for Windows** (enable it in *Developer Settings*, fold the setting open and select `inline`.).
  - **Windows 10 or as alternative:** [Gerardo Grignoli's **gsudo**](https://gerardog.github.io/gsudo/).
- **MSYS2 git**
  - e.g. `pacman -Sy --noconfirm pactoys && pacboy -S --noconfirm git`

## Installation

Run the command below to install the repository to `<MSYS2 root>/opt/msys2-compat` and execute the setup and registration scripts:

```shell
/usr/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DeltaRazero/msys2-compat/HEAD/install.sh)"
```

To update the repository and trigger the automatic post-merge hook, simply pull the latest changes:

```shell
git -C /opt/msys2-compat pull
```
