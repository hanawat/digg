//
//  Collection+ShuffleSpec.swift
//  Digg
//
//  Created by Hanawa Takuro on 2017/01/15.
//  Copyright © 2017年 Hanawa Takuro. All rights reserved.
//

import Quick
import Nimble
@testable import Digg

class Collection_ShuffleSpec: QuickSpec {
    override func spec() {
        describe("a collection") {
            var array = [Int]()
            beforeEach {
                array = [1, 2, 3, 4, 5]
            }

            describe("shuffled") {
                it("makes new shuffled collection") {
                    expect(array.shuffled()).toNot(equal(array))
                }

                it("not makes shuffled original collection") {
                    expect(array).to(equal(array))
                }
            }

            describe("shuffle") {
                it("makes shuffle original collection") {
                    let originalArray = array
                    array.shuffle()
                    expect(array).toNot(equal(originalArray))
                }
            }
        }
    }
}
