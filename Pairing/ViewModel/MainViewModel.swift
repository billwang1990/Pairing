//
//  MainViewModel.swift
//  Pairing
//
//  Created by Yaqing Wang on 28/09/2017.
//  Copyright © 2017 Yaqing Wang. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

struct Pairing {
    let firstPersonName: String
    let secondPersonName: String? // Solo
}

class Person: Object {
    dynamic var name: String = ""
    dynamic var isActive: Bool = false
    
    override static func primaryKey() -> String? {
        return "name"
    }
}


struct MainViewModel {
    let pairs: Variable<[Pairing]> = Variable([])
    init() {
        generateDefaultData()
    }
    
    private var sharedRealm: Realm {
        var config = Realm.Configuration()
        
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("Pair.realm")
        config.schemaVersion = 1
        config.migrationBlock = { migration, oldSchemaVersion in
            
        }
        
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    func retrieveAllPersons() -> [Person] {
        return sharedRealm.objects(Person.self).map{$0}
    }
    
    private func retrievePersons(includeInactivePerson: Bool = true) -> [String] {
        let personsName = retrieveAllPersons().flatMap { p -> String? in
            if includeInactivePerson {
                return p.name
            } else {
                return p.isActive ? p.name : nil
            }
        }
        
        return personsName
    }
    
    @discardableResult func generatePairs(includeInactivePerson: Bool = true) -> [Pairing] {
        let personsName = retrievePersons(includeInactivePerson: includeInactivePerson).sorted { _ in
            return Int(arc4random_uniform(100)) > 50
        }
        
        var startIndex = 0
        var result: [Pairing] = []
        
        while startIndex < personsName.count {
            let firstGuy = personsName[startIndex]
            let secondGuy = startIndex+1 < personsName.count ? personsName[startIndex+1] : nil
            result.append(Pairing(firstPersonName: firstGuy, secondPersonName: secondGuy))
            startIndex += 2
        }
        pairs.value = result
        return result
    }
    
    func updatePerson(personName: String, isActive: Bool = true) {
        let person = Person()
        person.isActive = isActive
        person.name = personName
        
        try! sharedRealm.write {
            sharedRealm.add(person, update: true)
        }
    }
    
    func deletePerson(personName: String)  {
        let db = sharedRealm
        
        let result = db.objects(Person.self).filter("name = %@", personName)
        
        try! sharedRealm.write {
            sharedRealm.delete(result)
        }
    }
    
    private var alreadyAppendDefaultPerson: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "alreadyAppendDefaultPerson")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "alreadyAppendDefaultPerson")
        }
    }
    
    private mutating func generateDefaultData() {
        if !alreadyAppendDefaultPerson {
            [].forEach({
                self.updatePerson(personName: $0)
            })
        }
        alreadyAppendDefaultPerson = true
    }
}

extension Array {
    func randomElement() -> Element {
        let randomValue = Int(arc4random_uniform(UInt32(self.count)))
        return self[randomValue]
    }
}

extension Set {
    public func randomObject() -> Element? {
        let n = Int(arc4random_uniform(UInt32(self.count)))
        let index = self.index(self.startIndex, offsetBy: n)
        return self.count > 0 ? self[index] : nil
    }
}
