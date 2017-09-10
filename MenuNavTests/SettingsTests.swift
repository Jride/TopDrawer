//
//  SettingsTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class SettingsTests: XCTestCase {
   
    // MARK: - Mock Types
    
    class MockKeyValueStore: KeyValueStore {
        
        var dictionary = [String:KeyValueStorable]()
        
        func value(forKey key: String) -> KeyValueStorable? {
            return dictionary[key]
        }
        
        func set(bool: Bool, forKey key: String) {
            dictionary[key] = bool
        }
        
        func bool(forKey key: String) -> Bool? {
            return dictionary[key] as? Bool
        }
        
        func set(string: String, forKey key: String) {
            dictionary[key] = string
        }
        
        func string(forKey key: String) -> String? {
            return dictionary[key] as? String
        }
        
        func set(int: Int, forKey key: String) {
            dictionary[key] = int
        }
        
        func int(forKey key: String) -> Int? {
            return dictionary[key] as? Int
        }
    }
    
    class MockSettingObserver {
        
        var numCallbacks = 0
        var handler: () -> () = {}
        
        init(setting: Setting<Int>) {
            setting.add(changeObserver: self, selector: #selector(callBack))
        }
        
        @objc func callBack() {
            numCallbacks += 1
            handler()
        }
    }
    
    // MARK: - Set / Get value
    
    func testSettingSetsValueInKeyValueStore() {
        
        let keyValueStore = MockKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 0)
        setting.value = 99
        XCTAssertEqual(keyValueStore.dictionary["key"] as? Int, 99)
    }
    
    func testSettingDoesSetDefaultValueInKeyValueStore() {
        
        let keyValueStore = MockKeyValueStore()
        let _ = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 100)
        XCTAssertNil(keyValueStore.dictionary["key"])
    }
    
    func testSettingReturnsDefaultValue() {
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 100)
        XCTAssertEqual(setting.value, 100)
    }
    
    func testSettingReturnsPreviouslySetValue() {
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 100)
        setting.value = 99
        XCTAssertEqual(setting.value, 99)
    }
    
    // MARK: - Observers
    
    func testSettingNotifiesObserverWhenValueSet() {
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 0)
        let observer = MockSettingObserver(setting: setting)
        setting.value = 99
        XCTAssertEqual(observer.numCallbacks, 1)
    }
    
    func testSettingNotifiesObserverWhenValueSetMultipleTimes() {
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 0)
        let observer = MockSettingObserver(setting: setting)
        setting.value = 99
        setting.value = 3
        setting.value = 42
        XCTAssertEqual(observer.numCallbacks, 3)
    }
    
    func testSettingNotifiesMultipleObservers() {
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 0)
        
        let observers = (0..<3).map{ _ in return MockSettingObserver(setting: setting) }
        setting.value = 99
        setting.value = 2
        XCTAssertEqual(observers.map{ $0.numCallbacks }, [2,2,2])
    }
    
    func testSettingDoesNotRetainObserver() {
        
        var receivedCallback = false
        
        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 0)
        var observer: MockSettingObserver? = MockSettingObserver(setting: setting)
        observer!.handler = {
            receivedCallback = true
        }
        observer = nil
        XCTAssertEqual(receivedCallback, false)
    }
    
    func testSettingWillCallLivingObserverButNotDeallocatedObserver() {
        
        var livingObserverReceivedCallback = false
        var deallocatedObserverReceivedCallback = false

        let setting = Setting(keyValueStore: MockKeyValueStore(), key: "key", defaultValue: 0)
        
        let livingObserver = MockSettingObserver(setting: setting)
        livingObserver.handler = {
            livingObserverReceivedCallback = true
        }
        
        var deallocatedObserver: MockSettingObserver? = MockSettingObserver(setting: setting)
        deallocatedObserver?.handler = {
            deallocatedObserverReceivedCallback = true
        }
        deallocatedObserver = nil
        
        setting.value = 99
        
        XCTAssertEqual(livingObserverReceivedCallback, true)
        XCTAssertEqual(deallocatedObserverReceivedCallback, false)
    }
    

}
