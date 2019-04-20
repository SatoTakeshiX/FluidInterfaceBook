<p align="left">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
</p>

# FluidInterfaceBook

地図アプリでよく見るハーフモーダルを解説した「[ハーフモーダルで理解するFluid Interface](https://personal-factory.booth.pm/items/1316137)」のサンプルコードです。

## 本書の内容
Apple純正の地図アプリのマップやGoogleのGoogle Mapsでよく見かけるようになったハーフモーダルビュー。
ごく自然に使っているこの画面、自分のアプリにも取り入れたいと思いませんか？
ユーザーが使いやすくなるなら導入してみるのもありでしょう。
しかし、ただ導入することが目的になってしまったらユーザー体験は損なわれてしまいます。
自分のアプリにどのように採用できるかを判断するにはハーフモーダルビューがどのような考えをもとに作られているかを知る必要があります。
本書ではハーフモーダルビューを題材にAppleが考える使いやすいユーザーインターフェース「Fluid Interface」について解説します。
ハーフモーダルビューはもちろん、使いやすいユーザーインターフェースについても考察していくので、他の画面を作る参考にもなるはずです。

## 動作環境

* Xcode10.2
* Swift5


## 対象読者

* ハーフモーダルを自分のアプリに組み込みたい方
* ハーフモーダルを取り入れる判断基準を知りたい方
* 「Fluid Interface」の概要を理解したい方
* ユーザーにとって使いやすいアプリを追求したい方

## 目次


第1章 モーダルビューとハーフモーダルビュー

* 1.1 モーダルビュー
* 1.2 ナビゲーション
* 1.3 「見せる」と「させる」 
* 1.4 近年のユーザーインターフェースの流行
* 1.5 スマートフォンのスクリーンサイズの大型化
* 1.6 画面下部で操作が完結するユーザーインターフェースの増加
* 1.7 モーダルビューと画面下部インターフェースとしてのハーフモーダルビュー

第2章 Designing Fluid Interfaces

* 2.1 Atoolthatfeelslikeanextensionofyourmind
* 2.2 ソフトウェアインターフェースの歴史
* 2.3 FluidInterfaceとなるための4つの要素
* 2.4 引き返せるユーザーインターフェース
* 2.5 思考と操作のパラレルな関係
* 2.6 ハーフモーダルビューとFluidInterface
* 2.6.1 ハーフモーダルビューの地図以外の導入例
* 2.7 まとめ

第3章 マップアプリをクローンする

* 3.1 アプリ概要
* 3.2 UIViewAnimating
   * 3.2.1 アニメーションの状態
   * 3.2.2 UIViewAnimatingのプロパティ
* 3.3 アプリの設計概要
* 3.4 Map View Controller と Search View Controller を作成
  * 3.4.1 * PanGestureの開始
  * 3.4.2 PanGestureが変更中
  * 3.4.3 PanGestureが終了
* 3.5 まとめ

第4章 まとめ

* 4.1 後書き

第5章 参考文献

* 5.1 参考サンプルコード
* 5.2 画像リソース

第6章 謝辞

付録A 写真アプリをクローンする
* A.1 アプリ概要
* A.2 Animator,UITransitonContext
* A.3 animateZoomInTransition(context: transitionContext)
* A.4 UINavigationControllerDelegate の代入
* A.5 UIIntaractiveTransition
* A.6 まとめ

# ライセンス
このサンプルコードはMITライセンスもと公開いたします。詳しくはLICENSEファイルをご確認ください。

