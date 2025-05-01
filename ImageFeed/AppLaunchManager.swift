//
//  AppLaunchManager.swift
//  ImageFeed
//
//  Created by User on 01.05.2025.
//

import Foundation
import Foundation
import SwiftKeychainWrapper

/// Отвечает за детект первого запуска после "чистой" установки и чистит Keychain, если нужно
final class AppLaunchManager {

    /// Ключ-флаг в UserDefaults, говорящий, что мы уже запустились хотя бы один раз
    private static let hasLaunchedBeforeKey = "hasLaunchedBefore"

    /// Выполнить проверку/чистку при старте
    static func handleFirstLaunchIfNeeded() {
        let defaults = UserDefaults.standard

        // Смотрим, был ли уже первый запуск
        let hasLaunchedBefore = defaults.bool(forKey: hasLaunchedBeforeKey)

        // Если флага нет — значит это ПЕРВЫЙ запуск после установки
        guard hasLaunchedBefore == false else {
            return
        }

        // Чистим Keychain (весь или конкретные ключи)
        clearKeychain()

        // Ставим флаг, больше не чистим
        defaults.set(true, forKey: hasLaunchedBeforeKey)
        defaults.synchronize()
    }

    /// Удалить из Keychain все наши сохранённые значения
    private static func clearKeychain() {
        // 1) Если вы знаете, какие именно ключи использовали, можно удалить по каждому:
        KeychainWrapper.standard.removeObject(forKey: "authorizationToken")
        // ... если есть ещё какие-то, например refreshToken и т.д. – удалить их тоже

        // 2) Либо полностью сбросить ВСЕ записи Keychain для вашего приложения:
//        let secItemClasses = [
//            kSecClassGenericPassword,
//            kSecClassInternetPassword,
//            kSecClassCertificate,
//            kSecClassKey,
//            kSecClassIdentity
//        ]
//
//        for itemClass in secItemClasses {
//            let query = [kSecClass: itemClass] as CFDictionary
//            SecItemDelete(query)
//        }
    }
}
