//
//  Country.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/10/20.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import Foundation

/// Country code with itunes store identifier model.
struct Country {

    let countryCode: String
    let storefrontIdentifier: String
}

class CountriesPlistManager {
    
    /// Return Country models from Country plist.
    class func countries() -> [Country] {

        guard let url = Bundle.main.url(forResource: "Country", withExtension: "plist"),
            let data = NSDictionary(contentsOf: url) as? [String: String] else { fatalError() }

        let countries = data.map { country -> Country in
            return Country(countryCode: country.value, storefrontIdentifier: country.key)
        }

        return countries
    }
}
