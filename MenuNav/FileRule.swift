//
//  FileType.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

struct FileRule {
    
    // MARK: - Types
    
    enum Condition {
        case name(StringMatcher)
        case ext(StringMatcher)
        case fullName(StringMatcher)
        
        func matches(file: File) -> Bool {
            
            switch self {
            case let .name(stringMatcher):
                return stringMatcher.matches(string: file.name)
            case let .ext(stringMatcher):
                return stringMatcher.matches(string: file.ext)
            case let .fullName(stringMatcher):
                return stringMatcher.matches(string: file.fullName)
            }
        }
        
        static func ==(lhs: Condition, rhs: Condition) -> Bool {
            switch (lhs, rhs) {
            case let (.name(sm1), .name(sm2)):
                return sm1 == sm2
            case let (.ext(sm1), .ext(sm2)):
                return sm1 == sm2
            case let (.fullName(sm1), .fullName(sm2)):
                return sm1 == sm2
            default:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    fileprivate let conditions: [Condition]
    
    // MARK: - Init
    
    init(conditions: [Condition]) {
        self.conditions = conditions
    }
    
    // MARK: - Matching
    
    func includes(file: File) -> Bool {
        
        for condition in conditions {
            if !condition.matches(file: file) {
                return false
            }
        }
        
        return true
    }
}

// MARK: - DictionaryRepresentable

extension FileRule.Condition: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "Case"
        struct Case {
            static let Name = "Name"
            static let Ext = "Ext"
            static let FullName = "FullName"
        }
        static let AssociatedValue = "AssociatedValue"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FileRule.Condition?

        switch caseType {
        case Keys.Case.Name:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .name(stringMatcher)
            }
            
        case Keys.Case.Ext:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .ext(stringMatcher)
            }

        case Keys.Case.FullName:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .fullName(stringMatcher)
            }
        default:
            break
        }
        
        if let result = result {
            self = result
        }
        else {
            return nil
        }
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        
        switch self {
        case let .name(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.Name
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
            
        case let .ext(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.Ext
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation

        case let .fullName(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.FullName
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation

        }
        
        return dictionary
    }
}

extension FileRule: DictionaryRepresentable {
    
    struct Keys {
        static let Conditions = "Conditions"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let conditionsArray = dictionary[Keys.Conditions] as? Array<Dictionary<String, Any>> else {
            return nil
        }

        let conditions = conditionsArray.flatMap{ Condition(dictionaryRepresentation: $0) }
        self.init(conditions: conditions)
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
     
        var dictionary = Dictionary<String, Any>()
        let conditionsArray = conditions.map{ $0.dictionaryRepresentation }
        dictionary[Keys.Conditions] = conditionsArray
        return dictionary
    }
}

