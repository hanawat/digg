//
//  CountrySpec.swift
//  Digg
//
//  Created by Hanawa Takuro on 2017/01/15.
//  Copyright © 2017年 Hanawa Takuro. All rights reserved.
//

import Quick
import Nimble
@testable import Digg

class CountrySpec: QuickSpec {
    override func spec() {
        var countries = [Country]()
        beforeEach {
            countries = CountriesPlistManager.countries()
        }

        describe("countries read from plist") {
            it("contain some countries data") {
                expect(countries).notTo(beEmpty())
            }
        }
    }
}
