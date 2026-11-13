# msys2-compat

A small suite of scripts and utilities to improve runtime behaviour when using MSYS2 shells on Windows. It also resolves conflicts when running select MSYS2 tools in native Windows shells (such as CMD or PowerShell), and vice versa.

## Prerequisites

Make sure you have the following ready before installing:

* **A sudo provider**
  * **Windows 11 (Build 26045+):** You can use the native **Sudo for Windows** (enable it in *Developer Settings*, fold the setting open and select `inline`.).
  * **Windows 10 or as alternative:** [Gerardo Grignoli's **gsudo**](https://gerardog.github.io/gsudo/).
* **Enable Developer Mode**
  * Required for enabling Windows SSH services and relaxes symbolic link creation restrictions without administrator rights (enable it in *Developer Settings*).
    * <details>
      <summary><b>Conditional step for some environments (corporate/enterprise, etc.)</b></summary>

        The domain/local security policy may have been configured to override certain *Developer Mode* settings. You can explicitly grant rights for symbolic links via the Local Security Policy tool (`secpol.msc`).

        Navigate to `Local Policies/User Rights Assignment` and edit the `Create symbolic links` setting. Either add your user or the `Users`* group and log out/log back in (or reboot).

        > :warning: **IMPORTANT**
        >
        > <sup>✱</sup>If your Windows was installed in a different language than English, the `User` group will most likely have a translated name. <br/>
        > Use `whoami /groups` in a CMD shell to check the `BUILTIN\Users` translation name (for example `BUILTIN\Gebruikers` in Dutch).
      </details>

* **MSYS2 git**
  * e.g. `pacman -Sy --noconfirm pactoys && pacboy -S --noconfirm git`

## Installation

Run the command below to install the repository to `<MSYS2 root>/opt/msys2-compat` and execute the setup and registration scripts:

```shell
/usr/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DeltaRazero/msys2-compat/HEAD/install.sh)"
```

To update the repository and trigger the automatic post-merge hook, simply pull the latest changes:

```shell
git -C /opt/msys2-compat pull
```

## Overview

### Added features

* **sudo**

  A new wrapper script around existing sudo providers. Improves compatibility and adds extra functionality relevant in MSYS2 shells.

  * Shell scripts can be executed with sudo.
  * A MSYS2 shell session can be elevated with `sudo -i` or `sudo -s`.

  Only the following sudo providers are supported:

  * [Microsoft Sudo on Windows](https://learn.microsoft.com/en-us/windows/advanced-settings/sudo/)
  * [Gerardo Grignoli's gsudo](https://gerardog.github.io/gsudo/)

### Behavioural changes

* **Symlink support**

  * MSYS2 shells and related tools are now forced to operate with the `winsymlinks:nativestrict` flag and support symbolic links.

### Fixed problems when using MSYS2 tools in native Windows shells[^1]

  * **git**
    * Calling MSYS2 git builds in native Windows shells would cause mismatches in SSH configurations. This is now unified (see *OpenSSH*).

  * **OpenSSH**
    * MSYS2 shells would use its own OpenSSH tools, causing a mismatch in SSH configurations between MSYS2 shells and native Windows shells.
      * Windows' native OpenSSH tools are now always called instead of those from MSYS2.
      * All SSH credentials are now stored in `$USERPROFILE/.ssh`. `$HOME/.ssh` will symlink to `$USERPROFILE/.ssh` and its contents are moved over, without ownership problems.

### Fixed problems when using native Windows tools in MSYS2 shells

  * **chezmoi**
    * When using a native Windows chezmoi build (e.g. sourced from winget) in a MSYS2 shell, the data would still be stored in the Windows user profile instead of the MSYS2 user home.

  * **winget**
    * When using winget in a MSYS2 shell would cache install packages in the MSYS2 `/tmp` directory instead of the Windows' temp directory. Windows Disk Cleanup or Storage Sense would not be able to clean this up.

## Troubleshooting

* **When doing a git clone/checkout, files which should be symlinks are regular files/deep copies instead.**

  If you used git to clone a repository before installing msys2-compat, git will set the `core.symlinks` setting to `false` within every repository locally upon creation/clone.

  For every existing repository cloned beforehand, execute `git config --unset core.symlinks`.

[^1]: e.g. CMD or PowerShell
