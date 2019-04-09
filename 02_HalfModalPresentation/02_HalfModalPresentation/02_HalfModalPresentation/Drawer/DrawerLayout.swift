//
//  DrawerLayout.swift
//  02_HalfModalPresentation
//
//  Created by satoutakeshi on 2019/03/28.
//  Copyright © 2019 Personal Factory. All rights reserved.
//

import UIKit

public enum DrawerPositionType: Int {
    case full //最大限表示
    case half //半分
    case tip //検索フィールドのみ出ている

    /// PanGestureを始めたポジションにとどまったかどうか。trueなら同じポジションだった
    func isBeginningArea(fractionPoint: CGFloat, velocity: CGPoint, middleAreaBorderPoint: CGFloat) -> Bool {
        switch self {
        case .tip:
            // ..<0.2 ~= fractionPointは fractionPointが0.2未満ならという意味になる。
            return velocity.y > 300 || ..<0.2 ~= fractionPoint && velocity.y >= 0.0 || middleAreaBorderPoint >= fractionPoint && velocity.y > 0
        case .full:
            return velocity.y < 0.0 || ..<0.35 ~= fractionPoint && velocity.y <= 0.0 || middleAreaBorderPoint >= fractionPoint && velocity.y < 0.0
        case .half:
            fatalError()
        }
    }

    /// 何を判断するメソッドなんだろう？End Areaにいるかどうか？->端っこまで行ったかどうか。
    func isEndArea(fractionPoint: CGFloat, velocity: CGPoint, middleAreaBorderPoint: CGFloat) -> Bool {
        switch self {
        case .tip:
            // velocityが-30０より下ということは、し下から上に思いっきり引っ張ったということ
            return velocity.y < -300 || 0.65... ~= fractionPoint && velocity.y <= 0 || middleAreaBorderPoint <= fractionPoint && velocity.y < 0
        case .full:
            // velocityが300より上ということは上から下にｐ思いっきり引っ張ったということ
            return velocity.y > 300 || 0.8... ~= fractionPoint && velocity.y >= 0 || middleAreaBorderPoint <= fractionPoint && velocity.y > 0
        case .half:
            fatalError()
        }
    }
}
