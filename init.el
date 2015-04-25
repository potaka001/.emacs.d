;; WEB+DB PRESS plusシリーズ
;; Emacs実践入門―思考を直感的にコード化し、開発を加速する
;; サンプルinit.el

;;; 注意事項 - まずはこちらをお読みください

;; このサンプルコードは、書籍『Emacs実践入門』に登場する設定
;; コードをまとめたものです。一部の設定では、拡張機能のインス
;; トールが必須となっているため、このファイルに書かれている内
;; 容の一部はそのまま利用することはできません。
;; 本書を読み進めながら、必要な設定をあなたのinit.elへコピー
;; してご利用ください。
;; なお、拡張機能のインストールが必要な設定については、下記の
;; ような目印を付けております。
;; 拡張機能のインストール方法については、該当ページに詳しく記
;; 述していますので、ぜひ参考にしてください。

;; ▼要拡張機能インストール▼


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.2 Emacsの起動と終了                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P30 デバッグモードでの起動
;; おまじない
(require 'cl)
;; Emacsからの質問をy/nで回答する
;; (fset 'yes-or-no-p 'y-or-n-p)
;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.1 効率的な設定ファイルの作り方と管理方法             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P60-61 Elisp配置用のディレクトリを作成
;; Emacs 23より前のバージョンを利用している方は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf" "public_repos")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.2 環境に応じた設定の分岐                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P65 CUIとGUIによる分岐
;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.2 キーバインドの設定                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P80 C-hをバックスペースにする
;; 入力されるキーシーケンスを置き換える
;; ?\C-?はDELのキーシケンス
;; (keyboard-translate ?\C-h ?\C-?)

;;; P79-81 お勧めのキー操作
;; C-mにnewline-and-indentを割り当てる。
;; 先ほどとは異なりglobal-set-keyを利用
(global-set-key (kbd "C-m") 'newline-and-indent)
;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
(define-key global-map (kbd "C-t") 'other-window)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.3 環境変数の設定                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P82-83 パスの設定
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "~/bin")

;;; P85 文字コードを指定する
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

;;; P86 ファイル名の扱い
;; Mac OS Xの場合のファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; Windowsの場合のファイル名の設定
(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
  (setq locale-coding-system 'cp932))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.4 フレームに関する設定                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P87-89 モードラインに関する設定
;; カラム番号も表示
(column-number-mode t)
;; ファイルサイズを表示
(size-indication-mode t)
;; 時計を表示（好みに応じてフォーマットを変更可能）
;; (setq display-time-day-and-date t) ; 曜日・月・日を表示
;; (setq display-time-24hr-format t) ; 24時表示
(display-time-mode t)
;; バッテリー残量を表示
(display-battery-mode t)
;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
;; http://d.hatena.ne.jp/sonota88/20110224/1298557375
(defun count-lines-and-chars ()
  (if mark-active
      (format "%d lines,%d chars "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
      ;; これだとエコーエリアがチラつく
      ;;(count-lines-region (region-beginning) (region-end))
    ""))

(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;;; P90 タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")
;; 行番号を常に表示する
(global-linum-mode t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.5インデントの設定                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P92-94 タブ文字の表示幅
;; TABの表示幅。初期値は8
(setq-default tab-width 4)
;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)
;; php-modeのみタブを利用しない
;; (add-hook 'php-mode-hook
;;           '(lambda ()
;;             (setq indent-tabs-mode nil)))

;; C、C++、JAVA、PHPなどのインデント
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "bsd")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.7 ハイライトの設定                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P100 現在行のハイライト
(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;; P101 括弧の対応関係のハイライト
;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "yellow")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.8 バックアップとオートセーブ                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P102-103 バックアップとオートセーブの設定
;; バックアップファイルを作成しない
;; (setq make-backup-files nil) ; 初期値はt
;; オートセーブファイルを作らない
;; (setq auto-save-default nil) ; 初期値はt

;; バックアップファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq backup-directory-alist
;;       `((".*" . ,temporary-file-directory)))
;; オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq auto-save-file-name-transforms
;;       `((".*" ,temporary-file-directory t)))

;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの秒間隔
(setq auto-save-timeout 15)
;; オートセーブファイル作成までのタイプ間隔
(setq auto-save-interval 60)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.9 フック                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ファイルが #! から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; emacs-lisp-mode-hook用の関数を定義
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))

;; emacs-lisp-modeのフックをセット
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.8 特殊な範囲の編集                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P151 矩形編集──cua-mode
;; cua-modeの設定
(cua-mode t) ; cua-modeをオン
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効にする



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.6 差分とマージ                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P206 同一フレーム内にコントロールパネルを表示する
;; ediffコントロールパネルを別フレームにしない
(setq ediff-window-setup-function 'ediff-setup-windows-plain)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.7 Emacsからデータベースを操作                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P210-211 MySQLへ接続する──sql-interactive-mode
;; SQLサーバへ接続するためのデフォルト情報
;; (setq sql-user "root" ; デフォルトユーザ名
;;       sql-database "database_name" ;  データベース名
;;       sql-server "localhost" ; ホスト名
;;       sql-product 'mysql) ; データベースの種類


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.10 TRAMPによるサーバ接続                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P225 バックアップファイルを作成しない
;; TRAMPでバックアップファイルを作成しない
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            オマケ                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; カーソル位置のファイルパスやアドレスを "C-x C-f" で開く
(ffap-bindings)


;;; 筆者のキーバインド設定
;; Mac の Command + f と C-x b で anything-for-files
(define-key global-map (kbd "s-f") 'anything-for-files)
(define-key global-map (kbd "C-x b") 'anything-for-files)
;; M-k でカレントバッファを閉じる
(define-key global-map (kbd "M-k") 'kill-this-buffer)
;; Mac の command + 3 でウィンドウを左右に分割
(define-key global-map (kbd "s-3") 'split-window-horizontally)
;; Mac の Command + 2 でウィンドウを上下に分割
(define-key global-map (kbd "s-2") 'split-window-vertically)
;; Mac の Command + 1 で現在のウィンドウ以外を閉じる
(define-key global-map (kbd "s-1") 'delete-other-windows)
;; Mac の Command + 0 で現在のウィンドウを閉じる
(define-key global-map (kbd "s-0") 'delete-window)
;; バッファを全体をインデント
(defun indent-whole-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))
;; C-<f8> でバッファ全体をインデント
(define-key global-map (kbd "C-<f8>") 'indent-whole-buffer)


;;; 改行やタブを可視化する whitespace-mode
(setq whitespace-display-mappings
      '((space-mark ?\x3000 [?\□]) ; zenkaku space
        (newline-mark 10 [8629 10]) ; newlne
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        )
      whitespace-style
      '(spaces
        ;; tabs
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))
;; whitespace-modeで全角スペース文字を可視化　
(setq whitespace-space-regexp "\\(\x3000+\\)")
;; whitespace-mode をオン
(global-whitespace-mode t)
;; F5 で whitespace-mode をトグル
(define-key global-map (kbd "<f5>") 'global-whitespace-mode)


;;; Mac でファイルを開いたときに、新たなフレームを作らない
(setq ns-pop-up-frames nil)


;;; 最近閉じたバッファを復元
;; http://d.hatena.ne.jp/kitokitoki/20100608/p2
(defvar my-killed-file-name-list nil)

(defun my-push-killed-file-name-list ()
  (when (buffer-file-name)
    (push (expand-file-name (buffer-file-name)) my-killed-file-name-list)))

(defun my-pop-killed-file-name-list ()
  (interactive)
  (unless (null my-killed-file-name-list)
    (find-file (pop my-killed-file-name-list))))
;; kill-buffer-hook (バッファを消去するときのフック) に関数を追加
(add-hook 'kill-buffer-hook 'my-push-killed-file-name-list)
;; Mac の Command + z で閉じたバッファを復元する
(define-key global-map (kbd "s-z") 'my-pop-killed-file-name-list)
