;;; japanese-menu.el --- Japanese menu translation -*- lexical-binding: t; -*-

;; Author: yt-emacs-ja
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience, i18n, gui
;; URL: https://github.com/yt-emacs-ja/emacs-japanese-menu

;;; Commentary:
;; Translate Emacs GUI menu labels into Japanese by rewriting menu keymaps.
;; Also translates popup menus (x-popup-menu / popup-menu) using a translated
;; deep copy so originals are not mutated.
;;
;; Usage:
;;   (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/"))
;;   (require 'japanese-menu)
;;   (japanese-menu-setup)

;;; Code:

(require 'subr-x) ;; string-trim

;; =========================================================
;; Dictionary: English label -> Japanese label
;; - ここに無いラベルは英語のまま
;; =========================================================
(defvar japanese-menu-label->jp
  '(
    ;; ---- Menubar headings ----
    ("File"    . "ファイル")
    ("Edit"    . "編集")
    ("Options" . "オプション")
    ("Buffers" . "バッファ")
    ("Tools"   . "ツール")
    ("Help"    . "ヘルプ")

    ;; ---- Info ----
    ;;  ("Info" . "インフォ")                    ;; 好みで「情報」でもOK
    ;;  ("Clone Info Buffer" . "Infoバッファを複製")

    ;; Go to submenu
    ("Table of Contents..." . "目次へ…")

    ;; Index submenu
    ("Lookup a String..." . "文字列を検索…")

    ("Clone Info buffer" . "Infoバッファを複製") ; b が小文字の環境があるかもなので保険
    ("Lookup a string..." . "文字列を検索…")     ; a string の小文字版保険

    ;; ---- File / Print ----

    ;; ---- File (additions) ----
    ("Visit New File..." . "新規ファイルを訪問…")
    ("Open File..." . "ファイルを開く…")
    ("Open File In Project..." . "プロジェクト内のファイルを開く…")
    ("Open Directory..." . "ディレクトリを開く…")
    ("Open Project Directory" . "プロジェクトディレクトリを開く")
    ("Insert File..." . "ファイルを挿入…")
    ("Close" . "閉じる")
    ("Save" . "保存")
    ("Save As..." . "名前を付けて保存…")
    ("Revert Buffer" . "バッファを再読み込み")
    ("Recover Crashed Session" . "クラッシュしたセッションを復元")

    ("New Window Below" . "下に新しいウィンドウ")
    ("New Window on Right" . "右に新しいウィンドウ")
    ("Remove Other Windows" . "他のウィンドウを閉じる")

    ("New Frame" . "新しいフレーム")
    ("New Frame on Display Server..." . "表示サーバ上に新しいフレーム…")
    ("New Frame on Monitor..." . "モニター上に新しいフレーム…")
    ("Delete Frame" . "フレームを削除")
    ("Undelete Frame" . "フレーム削除を取り消す")
    ("Allow Undeleting Frames" . "フレーム削除の取り消しを許可")

    ("New Tab" . "新しいタブ")
    ("Close Tab" . "タブを閉じる")

    ("Quit" . "終了")

    ("Print" . "印刷")
    ("Print Buffer" . "バッファを印刷")
    ("Print Region" . "選択範囲を印刷")
    ("Print Buffer..." . "バッファを印刷…")
    ("Print Region..." . "選択範囲を印刷…")
    ("PostScript Print Buffer" . "PostScriptでバッファを印刷")
    ("PostScript Print Region" . "PostScriptで選択範囲を印刷")
    ("PostScript Print Buffer..." . "PostScriptでバッファを印刷…")
    ("PostScript Print Region..." . "PostScriptで選択範囲を印刷…")
    ("PostScript Print Buffer (B+W)" . "PostScriptでバッファを印刷（白黒）")
    ("PostScript Print Region (B+W)" . "PostScriptで選択範囲を印刷（白黒）")

    ;; ---- Edit ----
    ("Undo" . "元に戻す")
    ("Redo" . "やり直し")
    ("Cut" . "切り取り")
    ("Copy" . "コピー")
    ("Paste" . "貼り付け")
    ("Paste from Kill Menu" . "貼り付け履歴…")
    ("Clear" . "消去")
    ("Select All" . "すべて選択")
    ("Fill" . "整形")
    ("Execute Command" . "コマンド実行")

    ;; ---- Search / Replace / Go To ----
    ("Search" . "検索")
    ("Search Tagged Files..." . "タグ付けファイルを検索…")
    ("Continue Tags Search" . "タグ検索を続行")
    ("Incremental Search" . "インクリメンタル検索")
    ("Replace" . "置換")
    ("Replace in Tagged Files..." . "タグ付けファイルで置換…")
    ("Continue Replace" . "置換を続行")
    ("Go To" . "移動")
    ("Find Definition..." . "定義へ移動…")
    ("Find Definition in Other Window..." . "別ウィンドウで定義へ…")
    ("Find Apropos..." . "定義を検索…")

    ("String Forward..." . "文字列検索（前方）…")
    ("String Backwards..." . "文字列検索（後方）…")
    ("Regexp Forward..." . "正規表現検索（前方）…")
    ("Regexp Backwards..." . "正規表現検索（後方）…")
    ("Repeat Forward" . "繰り返し（前方）")
    ("Repeat Backwards" . "繰り返し（後方）")
    ("Search in Project Files..." . "プロジェクト内を検索…")
    ("Replace in Project Files..." . "プロジェクト内で置換…")

    ("Forward String..." . "文字列（前方）…")
    ("Backward String..." . "文字列（後方）…")
    ("Forward Regexp..." . "正規表現（前方）…")
    ("Backward Regexp..." . "正規表現（後方）…")
    ("Forward Word..." . "単語（前方）…")
    ("Forward Symbol..." . "シンボル（前方）…")
    ("Forward Symbol at Point..." . "ポイント上のシンボル（前方）…")

    ("Replace String..." . "文字列を置換…")
    ("Replace Regexp..." . "正規表現で置換…")

    ("Goto Line..." . "指定行へ…")
    ("Goto Buffer Position..." . "バッファ位置へ移動…")
    ("Goto Beginning of Buffer" . "バッファ先頭へ")
    ("Goto End of Buffer" . "バッファ末尾へ")

    ;; ---- Bookmarks ----
    ("Bookmarks" . "ブックマーク")
    ("Jump to Bookmark..." . "ブックマークへ移動…")
    ("Set Bookmark..." . "ブックマークを設定…")
    ("Insert Contents..." . "内容を挿入…")
    ("Insert Location..." . "位置を挿入…")
    ("Rename Bookmark..." . "ブックマーク名を変更…")
    ("Delete Bookmark..." . "ブックマークを削除…")
    ("Delete all Bookmarks..." . "すべてのブックマークを削除…")
    ("Edit Bookmark List" . "ブックマーク一覧を編集")
    ("Save Bookmarks" . "ブックマークを保存")
    ;; Emacsの表記ゆれ両対応
    ("Save Bookmarks As ..." . "名前を付けて保存…")
    ("Save Bookmarks As..."  . "名前を付けて保存…")
    ("Load a Bookmark File..." . "ブックマークファイルを読み込み…")

    ;; ---- Options (よく出る階層名だけ) ----
    ("Customize" . "カスタマイズ")
    ("Customize Emacs" . "Emacsをカスタマイズ")
    ("Save Options" . "オプションを保存")
    ("Set Default Font..." . "既定フォントを設定…")
    ("Show/Hide" . "表示/非表示")
    ("Menu Bar" . "メニューバー")
    ("Tool Bar" . "ツールバー")
    ("Scroll Bar" . "スクロールバー")
    ("Tab Bar" . "タブバー")
    ("Tooltips" . "ツールチップ")
    ("Context Menus" . "コンテキストメニュー")
    ("Fringe" . "フリンジ")
    ("Window Divider" . "ウィンドウ区切り")
    ("Line Numbers for All Lines" . "全行に行番号")
    ;; ---- Options (追加分) ----
    ("Highlight Active Region" . "選択範囲をハイライト")
    ("Highlight Matching Parentheses" . "対応する括弧をハイライト")
    ("Line Wrapping in This Buffer" . "このバッファで行を折り返す")
    ("Default Search Options" . "検索の既定オプション")

    ("Cut/Paste with C-x/C-c/C-v (CUA Mode)" . "C-x/C-c/C-vで切り取り/コピー/貼り付け（CUAモード）")

    ("Use Directory Names in Buffer Names" . "バッファ名にディレクトリ名を含める")
    ("Save Place in Files between Sessions" . "前回位置をファイルごとに保存（セッション間）")
    ("Save State between Sessions" . "状態を保存（セッション間）")

    ("Blink Cursor" . "カーソル点滅")

    ("Enter Debugger on Error" . "エラー時にデバッガへ入る")
    ("Enter Debugger on Quit/C-g" . "Quit/C-g時にデバッガへ入る")

    ("Multilingual Environment" . "多言語環境")
    ("Use System Font" . "システムフォントを使用")

    ("Manage Emacs Packages" . "Emacsパッケージを管理")

    ;; =========================================================
    ;; Options submenus (追加)
    ;; =========================================================

    ;; ---- Line Wrapping in This Buffer ----
    ("Wrap at Window Edge" . "ウィンドウ端で折り返す")
    ("Truncate Long Lines" . "長い行を折り返さない")
    ("Word Wrap (Visual Line mode)" . "単語単位で折り返す（Visual Lineモード）")
    ("Visual Wrap Prefix mode" . "折り返しプレフィックスを表示（Visual Wrap Prefixモード）")

    ;; ---- Default Search Options ----
    ("Ignore Case" . "大文字小文字を無視")
    ("Literal Search" . "リテラル検索（そのまま検索）")
    ("Regular Expression" . "正規表現")
    ("Whole Words" . "単語全体のみ")
    ("Whole Symbols" . "シンボル全体のみ")
    ("Fold Characters" . "文字の同一視（Fold）")

    ;; ---- Multilingual Environment ----
    ("Set Language Environment" . "言語環境を設定")
    ("Toggle Input Method" . "入力メソッドを切替")
    ("Select Input Method..." . "入力メソッドを選択…")
    ("Transient Input Method" . "一時入力メソッド")
    ("Set Coding Systems" . "文字コード体系を設定")
    ("Show Multilingual Sample Text" . "多言語サンプルテキストを表示")
    ("Describe Language Environment" . "言語環境を説明")
    ("Describe Input Method" . "入力メソッドを説明")
    ("Describe Coding System..." . "文字コードを説明…")
    ("List Character Sets" . "文字集合一覧")
    ("Show All Multilingual Settings" . "多言語設定をすべて表示")

    ;; ---- Show/Hide ----
    ("Window Tab Line" . "ウィンドウのタブ行")
    ("Speedbar" . "スピードバー")
    ("Time, Load and Mail" . "時刻・負荷・メール")
    ("Battery Status" . "バッテリー状態")
    ("Size Indication" . "サイズ表示")
    ("Line Numbers in Mode Line" . "モードラインに行番号")
    ("Column Numbers in Mode Line" . "モードラインに桁番号")

    ;; ---- Customize Emacs ----
    ("Custom Themes" . "カスタムテーマ")
    ("Top-level Emacs Customization Group" . "最上位のカスタマイズグループ")
    ("Browse Customization Groups" . "カスタマイズグループを参照")
    ("Saved Options" . "保存済みオプション")
    ("New Options..." . "新しいオプション…")
    ("Specific Option..." . "特定のオプション…")
    ("Specific Face..." . "特定のフェイス…")
    ("Specific Group..." . "特定のグループ…")
    ("All Settings Matching..." . "一致する設定（全体）…")
    ("Options Matching..." . "一致するオプション…")
    ("Faces Matching..." . "一致するフェイス…")

    ;; =========================================================
    ;; Options deeper submenus (追加)
    ;; =========================================================

    ;; ---- Multilingual Environment / Set Coding Systems ----
    ("For Next Command" . "次のコマンドに対して")
    ("For Saving This Buffer" . "このバッファの保存に対して")
    ("For Reverting This File Now" . "このファイルを今すぐ再読み込みする時")
    ("For File Name" . "ファイル名に対して")
    ("For Keyboard" . "キーボードに対して")
    ("For Terminal" . "端末に対して")
    ("For X Selections/Clipboard" . "X の選択/クリップボードに対して")
    ("For Next X Selection" . "次の X 選択に対して")
    ("For I/O with Subprocess" . "サブプロセスとの I/O に対して")

    ;; ---- Show/Hide / Tool Bar ----
    ("None" . "なし")
    ("On the Top" . "上")
    ("On the Bottom" . "下")
    ("On the Right" . "右")
    ("On the Left" . "左")

    ;; ---- Show/Hide / Scroll Bar ----
    ("No Vertical Scroll Bar" . "縦スクロールバーなし")
    ("Horizontal" . "横")

    ;; ---- Show/Hide / Fringe ----
    ("Default" . "既定")
    ("Customize Fringe" . "フリンジをカスタマイズ…")
    ("Empty Line Indicators" . "空行インジケータ")
    ("Buffer Boundaries" . "バッファ境界")

    ;; ---- Show/Hide / Fringe / Buffer Boundaries ----
    ("No Indicators" . "表示しない")
    ("In Left Fringe" . "左フリンジに表示")
    ("In Right Fringe" . "右フリンジに表示")
    ("Opposite, No Arrows" . "反対側（矢印なし）")
    ("Opposite, Arrows Right" . "反対側（矢印は右）")
    ("Other (Customize)" . "その他（カスタマイズ）")

    ;; ---- Show/Hide / Window Divider ----
    ("Bottom Only" . "下のみ")
    ("Right Only" . "右のみ")
    ("Bottom and Right" . "下と右")

    ;; ---- Show/Hide / Line Numbers for All Lines ----
    ("Global Line Numbers Mode" . "全体の行番号モード")
    ("No Line Numbers" . "行番号なし")
    ("Absolute Line Numbers" . "絶対行番号")
    ("Relative Line Numbers" . "相対行番号")
    ("Visual Line Numbers" . "表示行の行番号")

    ;; ---- Customize Emacs (typo variant in menu) ----
    ("Browse Customization Geoups" . "カスタマイズグループを参照")

    ;; ---- Buffers ----
    ("List All Buffers" . "全バッファ一覧")
    ("Next Buffer" . "次のバッファ")
    ("Previous Buffer" . "前のバッファ")
    ;; ---- Buffers (追加) ----
    ("Select Named Buffer..." . "名前でバッファを選択…")
    ("Select Buffer In Project..." . "プロジェクト内のバッファを選択…")
    ("List Buffers In Project..." . "プロジェクト内のバッファ一覧…")

    ;; ---- Tools ----
    ("Compile..." . "コンパイル…")
    ("Spell Checking" . "スペルチェック")
    ("Version Control" . "バージョン管理")
    ("Calendar" . "カレンダー")
    ;; ---- Tools (追加) ----
    ("Search Files (Grep)..." . "ファイルを検索（Grep）…")
    ("Recursive Grep..." . "再帰的にGrep…")
    ("Shell Commands" . "シェルコマンド")
    ("Compile Project..." . "プロジェクトをコンパイル…")
    ("Debugger (GDB)..." . "デバッガ（GDB）")
    ("Project Support (EDE)" . "プロジェクト支援（EDE）")
    ("Project" . "プロジェクト")
    ("Language Server Support (Eglot)" . "言語サーバ支援（Eglot）")
    ("Source Code Parsers (Semantic)" . "ソース解析（Semantic）")
    ("Compare (Ediff)" . "比較（Ediff）")
    ("Merge" . "マージ")
    ("Apply Patch" . "パッチを適用")
    ("Read Net News" . "ネットニュースを読む")
    ("Read Mail" . "メールを読む")
    ("Compose New Mail" . "新規メールを作成")
    ("Directory Servers" . "ディレクトリサーバ")
    ("Browse the Web..." . "Webを閲覧…")
    ("Programmable Calculator" . "プログラム電卓")
    ("Simple Calculator" . "簡易電卓")
    ("Encryption/Decryption" . "暗号化/復号")
    ("Games" . "ゲーム")

    ;; =========================================================
    ;; Tools submenus (追加)
    ;; =========================================================

    ;; ---- Shell Commands submenu ----
    ("Shell Command..." . "シェルコマンド…")
    ("Shell Command on Region..." . "選択範囲にシェルコマンド")
    ("Async Shell Command..." . "非同期シェルコマンド…")
    ("Run Shell" . "シェルを起動")
    ("Run Shell In Project" . "プロジェクト内でシェルを起動")

    ;; ---- Project submenu ----
    ("Open File Including External Roots..." . "外部ルートも含めてファイルを開く…")
    ("Open Project Root" . "プロジェクトルートを開く")
    ("VC Dir" . "VCディレクトリ")
    ("Switch Project..." . "プロジェクトを切り替え…")
    ("Run Eshell" . "Eshellを起動")
    ("Shell Command..." . "シェルコマンド…")             ;; Shell Commands と共通
    ("Async Shell Command..." . "非同期シェルコマンド…")   ;; 同上
    ("Switch To Buffer..." . "バッファへ切り替え…")
    ("List Buffers" . "バッファ一覧")
    ("Kill Buffers..." . "バッファを終了…")
    ("Find Regexp..." . "正規表現を検索…")
    ("Find Regexp Including External Roots..." . "外部ルートも含めて正規表現を検索…")
    ("Query Replace Regexp..." . "正規表現で問い合わせ置換…")
    ("Execute Extended Command..." . "拡張コマンドを実行…")

    ;; ---- Spell Checking submenu ----
    ("Spell-Check Buffer" . "バッファをスペルチェック")
    ("Spell-Check Region" . "選択範囲をスペルチェック")
    ("Spell-Check Comments" . "コメントをスペルチェック")
    ("Spell-Check Word" . "単語をスペルチェック")
    ("Complete Word Fragment" . "単語断片を補完")
    ("Complete Word" . "単語を補完")
    ("Automatic spell checking (Flyspell)" . "自動スペルチェック（Flyspell）")
    ("Customize..." . "カスタマイズ…")
    ("Change Dictionary..." . "辞書を変更…")
    ("Select American Dict" . "米語辞書を選択")
    ("Select British Dict" . "ブリティッシュ辞書を選択")
    ("Select Canadian Dict" . "カナダ英語辞書を選択")
    ("Select English Dict" . "英語辞書を選択")

    ;; ---- Compare (Ediff) submenu ----
    ("Two Files..." . "2つのファイル…")
    ("Two Buffers..." . "2つのバッファ…")
    ("Three Files..." . "3つのファイル…")
    ("Three Buffers..." . "3つのバッファ…")
    ("Two Directories..." . "2つのディレクトリ…")
    ("Three Directories..." . "3つのディレクトリ…")
    ("File with Revision..." . "ファイルとリビジョン…")
    ("Directory Revisions..." . "ディレクトリのリビジョン…")
    ("Regions Word-by-word..." . "領域を単語単位で…")
    ("Regions Line-by-line..." . "領域を行単位で…")
    ("Windows Word-by-word..." . "ウィンドウを単語単位で…")
    ("Windows Line-by-line..." . "ウィンドウを行単位で…")
    ("This Window and Next Window" . "このウィンドウと次のウィンドウ")
    ("Ediff Miscellanea" . "Ediffその他")

    ;; ---- Merge submenu ----
    ("Files..." . "ファイル…")
    ("Files with Ancestor..." . "祖先付きファイル…")
    ("Buffers..." . "バッファ…")
    ("Buffers with Ancestor..." . "祖先付きバッファ…")
    ("Directories..." . "ディレクトリー")
    ("Directories with Ancestor..." . "祖先付きディレクトリー")

    ("Revisions..." . "リビジョン…")
    ("Revisions with Ancestor..." . "祖先付きリビジョン…")
    ("Directory Revisions..." . "ディレクトリのリビジョン…")
    ("Directory Revisions with Ancestor..." . "祖先付きディレクトリリビジョン…")

    ;; ---- Apply Patch submenu ----
    ("To a File..." . "ファイルへ…")
    ("To a Buffer..." . "バッファへ…")

    ;; ---- Version Control submenu ----
    ("Ignore File..." . "ファイルを無視…")
    ("Register" . "登録")
    ("Check In/Out" . "チェックイン/アウト")
    ("Update to Latest Version" . "最新版へ更新")
    ("Push Changes" . "変更をプッシュ")
    ("Revert to Base Version" . "ベース版へ戻す")
    ("Insert Header" . "ヘッダーを挿入")
    ("Show Top of the Tree History" . "ツリー最上位の履歴を表示")
    ("Show History" . "履歴を表示")
    ("Show Incoming Log" . "受信ログを表示")
    ("Show Outgoing Log" . "送信ログを表示")
    ("Update ChangeLog" . "ChangeLogを更新")
    ("Compare Tree with Base Version" . "ツリーをベース版と比較")
    ("Compare with Base Version" . "ベース版と比較")
    ("Show Other Version" . "別バージョンを表示")
    ("Rename File" . "ファイル名を変更")
    ("Annotate" . "注釈（annotate）")
    ("Create Branch..." . "ブランチを作成…")
    ("Switch Branch..." . "ブランチを切り替え…")
    ("Show Branch History..." . "ブランチ履歴を表示…")
    ("Create Tag" . "タグを作成")
    ("Retrieve Tag" . "タグを取得")

    ;; ---- Directory Servers submenu ----
    ("Load Hotlist of Servers" . "サーバのホットリストを読み込む")
    ("New Server" . "新しいサーバ")
    ("Query with Form" . "フォームで問い合わせ")
    ("Expand Inline Query" . "インライン問い合わせを展開")
    ("Get Email" . "メールアドレスを取得")
    ("Get Phone" . "電話番号を取得")

    ;; ---- Encryption/Decryption submenu ----
    ("Decrypt File..." . "ファイルを復号…")
    ("Encrypt File..." . "ファイルを暗号化…")
    ("Verify File..." . "ファイルを検証…")
    ("Sign File..." . "ファイルに署名…")
    ("Decrypt Region" . "選択範囲を復号")
    ("Encrypt Region" . "選択範囲を暗号化")
    ("Verify Region" . "選択範囲を検証")
    ("Sign Region" . "選択範囲に署名")
    ("List Keys" . "鍵一覧")
    ("Import Keys from File..." . "ファイルから鍵をインポート…")
    ("Import Keys from Region" . "選択範囲から鍵をインポート")
    ("Export Keys" . "鍵をエクスポート")
    ("Insert Keys" . "鍵を挿入")

    ;; ---- Ediff Miscellanea submenu ----
    ("Ediff Manual" . "Ediffマニュアル")
    ("Customize Ediff" . "Ediffをカスタマイズ")
    ("List Ediff Sessions" . "Ediffセッション一覧")
    ("Use separate control buffer frame" . "制御バッファを別フレームで使う")
    ;; ※ユーザー文の綴り保険
    ("Use separete control buffer frame" . "制御バッファを別フレームで使う")

    ;; ---- Help ----
    ("Emacs Tutorial" . "Emacsチュートリアル")
    ("Emacs Tutorial (choose language)..." . "Emacsチュートリアル（言語選択）…")
    ("Read the Emacs Manual" . "Emacsマニュアルを読む")
    ("Read the Emacs Manual..." . "Emacsマニュアルを読む…")
    ("Describe" . "説明")
    ("Describe Command..." . "コマンドを説明…")
    ("Describe Function..." . "関数を説明…")
    ("Describe Variable..." . "変数を説明…")
    ("About Emacs" . "Emacsについて")
    ("About GNU" . "GNUについて")
    ("More Manuals" . "他のマニュアル")

    ("Emacs FAQ" . "Emacs FAQ")
    ("Emacs News" . "Emacs ニュース")
    ("Emacs Known Problems" . "既知の問題")
    ("How to Report a Bug" . "バグの報告方法")
    ("Send Bug Report..." . "バグ報告を送信…")
    ("Emacs Psychotherapist" . "Emacs 心理療法士")
    ("Search Documentation" . "ドキュメントを検索")
    ("Search Built-in Packages" . "組み込みパッケージを検索")
    ("Finding Extra Packages" . "追加パッケージを探す")
    ("Getting New Versions" . "新しいバージョンを入手")
    ("Copying Conditions" . "複製条件")
    ("(Non)Warranty" . "保証（なし）")

    ;; ---- Help / Search Documentation ----
    ("Emacs Terminology" . "Emacs 用語集")
    ("Look Up Subject in User Manual..." . "ユーザーマニュアルで項目を調べる…")
    ("Look Up Subject in Elisp Manual..." . "Elispマニュアルで項目を調べる…")
    ("Look Up Key in User Manual..." . "ユーザーマニュアルで鍵を調べる…")
    ("Look Up Command in User Manual..." . "ユーザーマニュアルでコマンドを調べる…")
    ("Look Up Symbol in Manual..." . "マニュアルでシンボルを調べる…")
    ("Find Commands by Name..." . "名前でコマンドを検索…")
    ("Find Options by Name..." . "名前でオプションを検索…")
    ("Find Options by Value..." . "値でオプションを検索…")
    ("Find Any Object by Name..." . "名前で任意のオブジェクトを検索…")
    ("Search Documentation Strings..." . "ドキュメント文字列を検索…")

    ;; ---- Help / Describe ----
    ("Describe Buffer Modes" . "バッファのモードを説明")
    ("Describe Key or Mouse Operation..." . "キー／マウス操作を説明…")
    ("Describe Face..." . "フェイスを説明…")
    ("Describe Package..." . "パッケージを説明…")
    ("Describe Display Table" . "表示テーブルを説明")
    ("Show Recent Inputs" . "最近の入力を表示")
    ("Lint Key Bindings" . "キーバインドを検査")
    ("Describe Input Method..." . "入力メソッドを説明…")
    ("Describe Coding System (Briefly)" . "文字コードを簡潔に説明")
    ("Show All of Mule Status" . "Mule の状態をすべて表示")

    ;; ---- Help / More Manuals ----
    ("Introduction to Emacs Lisp" . "Emacs Lisp 入門")
    ("Emacs Lisp Reference" . "Emacs Lisp リファレンス")
    ("All Other Manuals (Info)" . "その他すべてのマニュアル（Info）")
    ("Lookup Subject in all Manuals..." . "すべてのマニュアルで項目を検索…")
    ("Ordering Manuals" . "マニュアルの注文方法")
    ("Read Man Page..." . "man ページを読む…")

    ("Function Group Overview..." . "関数グループ概要…")
    ("List Key Bindings" . "キーバインド一覧")

    ;; ---- Help / Search Documentation ----
    ("Look Up Subject in Elisp Manual..." . "Elispマニュアルで項目を調べる…")
    ("Look Up Subject in ELisp Manual..." . "Elispマニュアルで項目を調べる…") ; 綴り揺れ対策
    ("Look Up Key in User Manual..." . "ユーザーマニュアルでキーを調べる…")

    ;; =========================================================
    ;; Info menu
    ;; =========================================================
    ("Up" . "上へ")
    ("Next" . "次へ")
    ("Previous" . "前へ")
    ("Backward" . "戻る")
    ("Forward" . "進む")
    ("Beginning" . "先頭へ")
    ("Top" . "トップ")
    ("Final Node" . "最終ノード")

    ("Menu Item" . "メニュー項目")
    ("Reference" . "参照")
    ("Search..." . "検索…")
    ("Search Next" . "次を検索")

    ("History" . "履歴")
    ("Go to" . "移動")
    ("Index" . "索引")

    ("Copy Node Name" . "ノード名をコピー")
    ("Clone Info Buffer" . "Infoバッファを複製")
    ("Exit" . "終了")

    ;; ---------------------------------------------------------
    ;; Menu Item submenu
    ;; ---------------------------------------------------------
    ("sed" . "sed")
    ("grep" . "grep")
    ("Diffutils" . "Diffutils")
    ("Info stand-alone" . "Infoスタンドアロン")
    ("Speech Dispatcher" . "音声ディスパッチャ")
    ("Say for Speech Dispatcher" . "音声ディスパッチャで読み上げ")
    ("SSIP" . "SSIP")
    ("Wget" . "Wget")
    ("dt" . "dt")
    ("Other..." . "その他…")

    ;; ---------------------------------------------------------
    ;; History submenu
    ;; ---------------------------------------------------------
    ("Back in History" . "履歴を戻る")
    ("Forward in History" . "履歴を進む")
    ("Show History" . "履歴を表示")

    ;; ---------------------------------------------------------
    ;; Go to submenu
    ;; ---------------------------------------------------------
    ("Go to Node..." . "ノードへ移動…")
    ("Table of Contents..." . "目次…")
    ("Go to Directory" . "ディレクトリへ移動")

    ;; ---------------------------------------------------------
    ;; Index submenu
    ;; ---------------------------------------------------------
    ("Lookup String..." . "文字列を検索…")
    ("Next Matching Item" . "次の一致項目")
    ("Lookup a string and display index of results..." . "文字列を検索して索引結果を表示…")
    ("Lookup a string in all indices..." . "すべての索引で文字列を検索…")

    ;; ---- Info / Go to ----
    ("Table of Contents" . "目次…")
    ("Table of Contents..." . "目次…")   ;; 既にあるなら上書きor統一

    ;; ---- Info / Menu Item ----
    ("Info stand-alone" . "Infoスタンドアロン")
    ("info stand-alone" . "Infoスタンドアロン")
    ("Info Stand-alone" . "Infoスタンドアロン")
    ("info Stand-alone" . "Infoスタンドアロン")

    ;; ---- Emacs Lisp ----
    ("Indent Line" . "行をインデント")
    ("Indent Region" . "領域をインデント")
    ("Comment Out Region" . "領域をコメントアウト")
    ("Evaluate Region" . "領域を評価")
    ("Evaluate Buffer" . "バッファを評価")

    ("Evaluate Last S-expression" . "直前のS式を評価")
    ("Evaluate Last" . "直前を評価")

    ("Interactive Expression Evaluation" . "対話的に式を評価")

    ("Byte-compile This File" . "このファイルをバイトコンパイル")
    ("Byte-compile and Load" . "バイトコンパイルして読み込み")
    ("Byte-recompile Directory..." . "ディレクトリを再バイトコンパイル…")

    ("Native-compile This File" . "このファイルをネイティブコンパイル")
    ("Native-compile and Load" . "ネイティブコンパイルして読み込み")

    ("Disassemble Byte Compiled Object..." . "バイトコンパイル済みオブジェクトを逆アセンブル…")

    ("Instrument Function for Debugging" . "デバッグ用に関数を計測")

    ("Navigation" . "ナビゲーション")
    ("Linting" . "Lint")
    ("Profiling" . "プロファイリング")
    ("Tracing" . "トレース")

    ("Construct Regexp" . "正規表現を構築")
    ("Check Documentation Strings" . "ドキュメント文字列を検査")
    ("Auto-Display Documentation Strings" . "ドキュメント文字列を自動表示")

    ;; typo 対策（実物にあったため）
    ("Ingent Line" . "行をインデント")
    ("Auti-Display Documentation Strings" . "ドキュメント文字列を自動表示")
    ("Direvtory" . "ディレクトリ")

    ;; ---- Emacs Lisp / Navigation ----
    ("Forward Sexp" . "次のS式へ")
    ("Backward Sexp" . "前のS式へ")
    ("Beginning Of Defun" . "定義の先頭へ")
    ("Up List" . "リストを一段上へ")

    ;; ---- Emacs Lisp / Linting ----
    ("Lint Defun" . "定義をLint")
    ("Lint Buffer" . "バッファをLint")
    ("Lint File..." . "ファイルをLint…")
    ("Lint Directory..." . "ディレクトリをLint…")

    ;; ---- Emacs Lisp / Profiling ----
    ("Start Native Profiler..." . "ネイティブプロファイラを開始…")
    ("Show Profiler Report" . "プロファイラレポートを表示")
    ("Stop Native Profiler" . "ネイティブプロファイラを停止")

    ("Instrument Function..." . "関数を計測…")
    ("Instrument Package..." . "パッケージを計測…")

    ("Show Profiling Results" . "プロファイル結果を表示")

    ("Reset Counters for Function..." . "関数のカウンタをリセット…")
    ("Reset Counters for All Functions" . "全関数のカウンタをリセット")

    ("Remove Instrumentation for All Functions" . "全関数の計測を解除")
    ("Remove Instrumentation for Function..." . "関数の計測を解除…")

    ;; ---- Emacs Lisp / Tracing ----
    ("Trace Function..." . "関数をトレース…")
    ("Trace Function Quietly..." . "関数を静かにトレース…")
    ("Untrace All" . "すべてのトレースを解除")
    ("Untrace Function..." . "関数のトレースを解除…")

    ;; ---- Minibuffer ----
    ("Minibuffer" . "ミニバッファ")
    ("MiniBuffer" . "ミニバッファ")
    ("Minibuf" . "ミニバッファ")

    ;; ---- Minibuffer items ----
    ("Complete" . "補完")
    ("List Completions" . "補完候補一覧")
    ("Previous History Item" . "前の履歴項目")
    ("Next History Item" . "次の履歴項目")
    ("Isearch History Backward" . "履歴をインクリメンタル検索（後方）")
    ("Isearch History Forward" . "履歴をインクリメンタル検索（前方）")
    ("Enter" . "確定")
    ("Quit" . "終了")

    ;; ---- Debugger ----
    ("Debugger" . "デバッガ")
    ("Debug" . "デバッガ")

    ;; ---- Debugger items ----
    ("Step through" . "ステップ実行")
    ("Continue" . "続行")
    ("Jump" . "ジャンプ")
    ("Eval Expression..." . "式を評価…")
    ("Display and Record Expression" . "式を表示して記録")
    ("Return value..." . "戻り値を指定…")
    ("Debug frame" . "フレームをデバッグ")
    ("Cancel debug frame" . "デバッグフレームをキャンセル")
    ("List debug on entry functions" . "関数エントリ時デバッグを検査")
    ("Next Line" . "次の行")
    ("Help for Symbol" . "シンボルのヘルプ")
    ("Describe Debugger Mode" . "デバッガモードを説明")
    ("Quit" . "終了")

    ;; =========================================================
    ;; Backtrace menu
    ;; =========================================================
    ("Backtrace" . "バックトレース")
    ("Next Frame" . "次のフレーム")
    ("Previous Frame" . "前のフレーム")
    ("Show Variables" . "変数を表示")
    ("Show Circular Structures" . "循環構造を表示")
    ("Show Uninterned Symbols" . "未登録シンボルを表示")
    ("Expand \"...\"s" . "「…」を展開")
    ("Show on Multiple Lines" . "複数行で表示")
    ("Show on Single Line" . "1行で表示")
    ("Go to Source" . "ソースへ移動")
    ("Help for Symbol" . "シンボルのヘルプ")
    ("Describe Backtrace Mode" . "バックトレースモードを説明")

    ;; =========================================================
    ;; Lisp-Interaction menu
    ;; =========================================================
    ("Lisp-Interaction" . "Lisp-対話")
    ("Complete Lisp Symbol" . "Lispシンボルを補完")
    ("Indent or Pretty-Print" . "インデント／整形表示")
    ("Instrument Function for Debugging" . "デバッグ用に関数を計測")
    ("Evaluate and Print" . "評価して表示")
    ("Evaluate Defun" . "関数定義を評価")
    )
  "English menu label -> Japanese label.")

;; =========================================================
;; Normalizer / lookup
;; =========================================================
(defun japanese-menu--norm-label (s)
  "Normalize label so '...' and '…' differences don't matter."
  (when (stringp s)
    (let ((x (string-trim s)))
      (setq x (replace-regexp-in-string "…" "..." x t t))
      (setq x (replace-regexp-in-string "[ \t]+" " " x t t))
      x)))

(defun japanese-menu--jp-label (label)
  "Translate LABEL if present in dictionary."
  (let* ((k  (japanese-menu--norm-label label))
         (jp (and k (cdr (assoc k japanese-menu-label->jp)))))
    (when (and (stringp jp) (string-match "\\.\\.\\.$" jp))
      (setq jp (replace-regexp-in-string "\\.\\.\\.$" "…" jp)))
    (or jp label)))

;; =========================================================
;; Keymap utilities
;; =========================================================
(defun japanese-menu--as-keymap (x)
  "Return a keymap from X if possible, else nil."
  (cond
   ((keymapp x) x)
   ((and (symbolp x) (boundp x) (keymapp (symbol-value x)))
    (symbol-value x))
   ((and (consp x) (eq (car x) 'keymap) (keymapp x)) x)
   (t nil)))

;; =========================================================
;; Walker (mutates keymaps)
;; =========================================================
(defun japanese-menu--walk-keymap (km)
  "Rewrite menu labels in keymap KM recursively."
  (let ((k (japanese-menu--as-keymap km)))
    (when k
      (map-keymap
       (lambda (_evt binding)
         (cond
          ;; (menu-item "Label" ITEM . PROPS)
          ((and (consp binding) (eq (car binding) 'menu-item))
           (let* ((label (nth 1 binding))
                  (item  (nth 2 binding))
                  (maybe (nth 3 binding))
                  (sub1  (japanese-menu--as-keymap item))
                  (sub2  (japanese-menu--as-keymap maybe)))
             (when (stringp label)
               (setcar (cdr binding) (japanese-menu--jp-label label)))
             (when sub1 (japanese-menu--walk-keymap sub1))
             (when sub2 (japanese-menu--walk-keymap sub2))))

          ;; binding itself is a keymap-like
          ((japanese-menu--as-keymap binding)
           (japanese-menu--walk-keymap binding))

          ;; ("Title" . COMMAND) / ("Title" . KEYMAP)
          ((and (consp binding) (stringp (car binding)))
           (setcar binding (japanese-menu--jp-label (car binding)))
           (let ((sub (japanese-menu--as-keymap (cdr binding))))
             (when sub (japanese-menu--walk-keymap sub))))

          (t nil)))
       k))))

;; =========================================================
;; Translate global + local menubars
;; =========================================================
(defun japanese-menu-translate-global-menubar (&optional frame)
  "Translate global menu-bar keymap."
  (with-selected-frame (or frame (selected-frame))
    (let ((mb (lookup-key global-map [menu-bar])))
      (when (japanese-menu--as-keymap mb)
        (japanese-menu--walk-keymap mb)))))

(defun japanese-menu-translate-current-menubar (&optional frame)
  "Translate global + current buffer's local menu bar."
  (with-selected-frame (or frame (selected-frame))
    (ignore-errors (japanese-menu-translate-global-menubar))
    (let* ((lm (current-local-map))
           (mb (and (keymapp lm) (lookup-key lm [menu-bar]))))
      (when (japanese-menu--as-keymap mb)
        (ignore-errors (japanese-menu--walk-keymap mb))))))

;; =========================================================
;; Popup menu translation (does NOT mutate originals)
;; =========================================================
(defun japanese-menu--translate-menu-obj (obj)
  "Translate menu OBJ recursively (lists/vectors/menu-item)."
  (cond
   ((japanese-menu--as-keymap obj)
    (japanese-menu--walk-keymap obj) obj)

   ((and (consp obj) (eq (car obj) 'menu-item))
    (let ((label (nth 1 obj)))
      (when (stringp label)
        (setcar (cdr obj) (japanese-menu--jp-label label))))
    obj)

   ((vectorp obj)
    (when (and (> (length obj) 0) (stringp (aref obj 0)))
      (aset obj 0 (japanese-menu--jp-label (aref obj 0))))
    obj)

   ((consp obj)
    (when (stringp (car obj))
      (setcar obj (japanese-menu--jp-label (car obj))))
    (when (listp (cdr obj))
      (dolist (e (cdr obj))
        (japanese-menu--translate-menu-obj e)))
    obj)

   (t obj)))

(defun japanese-menu--translate-menu-copy (menu)
  "Return translated deep copy of MENU."
  (let ((m (copy-tree menu t)))
    (ignore-errors (japanese-menu--translate-menu-obj m))
    m))

(defvar japanese-menu--advice-installed nil)

;; =========================================================
;; Setup
;; =========================================================
(defun japanese-menu-setup ()
  "Install hooks/advice to translate menus."
  (with-eval-after-load 'menu-bar
    ;; グローバル側のトップ \"Info\" を消して、Info-mode側だけにする
    (when (lookup-key global-map [menu-bar info])
      (define-key global-map [menu-bar info] nil))

    ;; 起動時
    (add-hook 'after-init-hook #'japanese-menu-translate-current-menubar)

    ;; 更新時（動的メニュー追随：GUIではここが肝）
    (add-hook 'menu-bar-update-hook #'japanese-menu-translate-current-menubar)

    ;; 新フレーム時（英語戻り対策）
    (add-hook 'after-make-frame-functions #'japanese-menu-translate-current-menubar)

    ;; popup-menu / x-popup-menu は「表示直前のコピー」を翻訳
    (unless japanese-menu--advice-installed
      (setq japanese-menu--advice-installed t)

      (when (fboundp 'x-popup-menu)
        (advice-add
         'x-popup-menu :around
         (lambda (orig event menu &rest args)
           (apply orig event (japanese-menu--translate-menu-copy menu) args))))

      (when (fboundp 'popup-menu)
        (advice-add
         'popup-menu :around
         (lambda (orig menu &rest args)
           (apply orig (japanese-menu--translate-menu-copy menu) args))))))

  ;; Info-mode はローカルメニューが多いので入った瞬間にも一回
  (with-eval-after-load 'info
    (add-hook 'Info-mode-hook #'japanese-menu-translate-current-menubar)))

(provide 'japanese-menu)
;;; japanese-menu.el ends here
