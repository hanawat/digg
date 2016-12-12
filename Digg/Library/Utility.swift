//
//  Utility.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/12/12.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation

enum Utility {

    static var isJapanese: Bool {

        guard let language = Locale.preferredLanguages.first else { return false }
        return language.hasPrefix("ja-")
    }
}
