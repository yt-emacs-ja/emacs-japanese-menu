# japanese-menu.el (Emacs GUI menu Japanese translation)

EmacsのGUIメニュー（メニューバー / プルダウン / 右クリック等）を、
英語ラベル → 日本語ラベルの辞書で置換します。  
Debian / Ubuntu の Emacs（GUI）を主対象としています。

---

## 使い方

### 1) ファイル配置（例）

~/.emacs.d/lisp/japanese-menu.el


### 2) init.el に追記

```elisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(require 'japanese-menu)
(japanese-menu-setup)

##3) 反映

## Emacs を再起動
## または

## init.el を M-x eval-buffer

動作確認環境

本パッケージは、以下の 実環境 で動作確認を行っています。

Host OS: macOS Tahoe 26.2

Virtualization: VMware Fusion Professional 25H2 (VMware20,1)

Guest OS: Ubuntu 25.10 (aarch64)

Kernel: Linux 6.17.0-8-generic

Desktop Environment: GNOME 49.0

Display Server: Wayland (Mutter)

Emacs:

GNU Emacs 30.1

aarch64-unknown-linux-gnu

GTK+ 3.24.50

cairo 1.18.4

Debian build (2025-08-28)

確認済み内容

メニューバー（File / Edit / Options / Tools / Help）

プルダウンメニュー

モード固有メニュー（Info-mode 等）

右クリックメニュー（popup-menu / x-popup-menu）

注意

端末版 Emacs（emacs -nw）は GUI メニューが存在しないため対象外です

メニューラベルは Emacs / パッケージのバージョンにより表記揺れがあります
必要に応じて辞書を追加してください








