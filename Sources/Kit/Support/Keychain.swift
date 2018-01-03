/// This is a generated file, do not edit

import Foundation
import Security

public class Keychain {

    private static var _shared: Keychain?

    public static var shared: Keychain {
        get {
            if _shared == nil {
                DispatchQueue.global().sync(flags: .barrier) {
                    if _shared == nil {
                        _shared = Keychain()
                    }
                }
            }
            return _shared!
        }
    }

    public subscript(key: String) -> String? {
        get { return load(withKey: key) }
        set {
            DispatchQueue.global().sync(flags: .barrier) {
                self.save(newValue, forKey: key)
            }
        }
    }

    private init() {}

    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                print("Keychain Update Status: ", status)
            } else {
                let status = SecItemDelete(query)
                print("Keychain Delete Status: ", status)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                print("Keychain Update Status: ", status)
            }
        }
    }

    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)

        guard let resultsDict = result as? NSDictionary else {
            return nil
        }
        guard let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data else {
            return nil
        }
        guard status == noErr else {
            return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }

    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAlwaysThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
}

