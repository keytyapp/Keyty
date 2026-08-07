<h1 align="center">
  <a href="https://keyty.app/ja">
    <img src="../Assets/Application/AppIcon/AppIcon.png" alt="Keyty アプリのロゴ" width="128">
    <br />
    <strong>Keyty</strong>
  </a>
  <br>
</h1>

<div align="center">
   <img src="https://img.shields.io/github/v/release/keytyapp/Keyty?style=flat-square" alt="リリース">
   <img src="https://img.shields.io/github/downloads/keytyapp/Keyty/total?style=flat-square" alt="ダウンロード数">
   <img src="https://img.shields.io/github/stars/keytyapp/Keyty?style=flat-square" alt="スター">
   <img src="https://img.shields.io/github/license/keytyapp/Keyty?style=flat-square" alt="ライセンス">
   <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square" alt="対応プラットフォーム">
</div>

Keyty は、キーボードやマウスの操作をリアルタイムで可視化する無料のオープンソースアプリです。
  デモ、プレゼンテーション、チュートリアル、ライブ配信での操作を見やすくし、視聴者が内容を追いやすくします。
  すべてのショートカット、クリック、入力を明確に表示することで、画面上での説明をより効果的に行えます。

## 機能

### キーボード

![キーボードデモ](Resources/demo.gif)

- キーボードショートカット、特殊キー、入力文字をリアルタイムで表示
- オーバーレイのスタイル、テーマ、サイズ、レイアウト、フェード時間をカスタマイズ可能
- 修飾キー付き入力、特殊キー、メディアキー、マウスイベントのフィルターに対応

### マウス

<p>
  <img src="Resources/ring_demo.gif" alt="ポインターリングのデモ" width="49%">
  <img src="Resources/pointer_icon_demo.gif" alt="ポインターアイコンのデモ" width="49%">
</p>

- キーボード入力とあわせてマウスクリックやスクロール操作を可視化
- 形状、色、サイズ、太さを設定できるポインター強調リング
- 位置、サイズ、背景、色味を調整できるポインターアイコンのオーバーレイ

## カスタマイズ

Keyty は設定画面から、ワークフローやプレゼンテーションのスタイルに合わせて調整できます。

- **外観:** キーボードオーバーレイのスタイル、テーマ、色、サイズを選択できます。
- **履歴:** 最近の入力を視覚的な履歴として表示できます。
- **フィルター:** 修飾キー付き入力、特殊キー、メディアキー、マウスイベントを表示するかどうかを制御できます。
- **マウス:** ポインターリングやポインターアイコンの表示、形状、色、サイズ、オフセット、背景、色味を設定できます。
- **配置:** 表示するディスプレイ、画面上のアンカー位置、余白、積み重ね方向を選択できます。

## インストール

### GitHub

[GitHub](https://github.com/keytyapp/Keyty/releases) から最新リリースをダウンロードしてください

### Homebrew

```bash
brew install --cask keytyapp/tap/keyty
```

### ソースからビルド

ローカルで Keyty をソースからビルドする方法は [BUILD.md](BUILD.md) を参照してください。

## 権限

Keyty がキーストロークやマウスクリックを表示するには、macOS からイベントを受け取るための許可が必要です。設定方法とトラブルシューティングについては [PERMISSIONS.md](PERMISSIONS.md) を参照してください。

## プライバシー

入力イベントはお使いの Mac 上でローカルに処理されます。Keyty はキーストローク、入力した文字、マウスクリック、ポインター操作を記録、保存、アップロードしません。Sparkle によるアップデート確認を含む詳細は [PRIVACY.md](PRIVACY.md) を参照してください。

## サポート

Keyty が役に立った場合は、GitHub で ⭐ を付けてください。より多くの人にプロジェクトを知ってもらう助けになり、開発を支える最も簡単な方法です。
