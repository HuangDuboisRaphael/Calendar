//
//  LocaleHelper.swift
//  Calendar
//
//  Created by Raphaël Huang-Dubois on 08/10/2023.
//

import Foundation

struct LocaleHelper {
    static var preferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
