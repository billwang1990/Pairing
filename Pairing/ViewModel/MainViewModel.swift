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

class PersonName: Object {
    dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class PersonSort: Object {
    let sortList = List<PersonName>()
    dynamic var personSortKey: String = "sortList"
    
    override static func primaryKey() -> String? {
        return "personSortKey"
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
    
    func updatePerson(personName: String, isActive: Bool = true) {
        let person = Person()
        person.isActive = isActive
        person.name = personName
        
        try! sharedRealm.write {
            sharedRealm.add(person, update: true)
        }
    }
    
    func updateSort(CurrentSort: Array<String>) {
        let personSort = PersonSort()
        for personName in CurrentSort {
            let person = PersonName()
            person.name = personName
            personSort.sortList.append(person)
        }
        
        try! sharedRealm.write {
            sharedRealm.add(personSort, update: true)
        }
    }
    
    func deletePerson(personName: String)  {
        let db = sharedRealm
        
        let result = db.objects(Person.self).filter("name = %@", personName)
        
        try! sharedRealm.write {
            sharedRealm.delete(result)
        }
    }
    
    
    func retrieveAllPersons() -> [Person] {
        return sharedRealm.objects(Person.self).map{$0}
    }
    
    func retrieveLastSort() -> PersonSort {
        return sharedRealm.objects(PersonSort.self).last!
    }
    
    private func retrievePersons(includeInactivePerson: Bool) -> [(name: String, isActive: Bool)] {
        let personsName = retrieveAllPersons().flatMap { p -> (name: String, isActive: Bool)? in
            if includeInactivePerson {
                return (name: p.name, isActive: p.isActive)
            } else {
                return p.isActive ? (name: p.name, isActive: p.isActive) : nil
            }
            
        }
        
        return personsName
    }
    
    @discardableResult func generatePairs(includeInactivePerson: Bool = true) -> [Pairing] {

        let defaultPersonsName = retrievePersons(includeInactivePerson: true)
        let activePersonsName = retrievePersons(includeInactivePerson: false)
        var lastPersonsSortList = [String]()
        for personInList in retrieveLastSort().sortList {
            lastPersonsSortList.append(personInList.name)
        }
        
       let newPersonList = getNewPerson(activePersonsName: activePersonsName, lastPersonsSortList: lastPersonsSortList)

        let (lastPersonsSortListWithoutInActivePerson, pairInActivePersonList) = getPairInActivePerson(defaultPersonsName:defaultPersonsName, lastPersonsSortList: lastPersonsSortList)
        
        let personsWillSortList = getSortedPersonList(pairInActivePersonList:pairInActivePersonList, newPersonList:newPersonList, lastPersonsSortListWithoutInActivePerson: lastPersonsSortListWithoutInActivePerson)
       
        let personOrderIndexList = getUnRepeatPairOrder(numberOfPerson: personsWillSortList.count)
        
        var currentSort = [String]()
        for index in personOrderIndexList {
            currentSort.append(personsWillSortList[index])
        }
        
        var startIndex = 0
        var result: [Pairing] = []
        
       
        while startIndex < currentSort.count {
            let firstGuy = currentSort[startIndex]
            let secondGuy = startIndex+1 < currentSort.count ? currentSort[startIndex+1] : nil
            result.append(Pairing(firstPersonName: firstGuy, secondPersonName: secondGuy))
            startIndex += 2
        }
        
        updateSort(CurrentSort: currentSort)
        
        pairs.value = result
        return result
    }
    
    func getSortedPersonList(pairInActivePersonList:Array<String>, newPersonList: Array<String>, lastPersonsSortListWithoutInActivePerson: Array<String>) -> Array<String> {
        var personsWillSortList = [String]()
        
        for person in lastPersonsSortListWithoutInActivePerson {
            personsWillSortList.append(person)
        }
        
        for person in pairInActivePersonList {
            personsWillSortList.append(person)
        }
        
        for person in newPersonList {
            personsWillSortList.append(person)
        }
        
        return personsWillSortList
    }
    
    func getPairInActivePerson(defaultPersonsName: [(name: String, isActive: Bool)], lastPersonsSortList: [String]) -> (Array<String>, Array<String>) {
        var lastPersonsSortListWithoutInActivePerson = lastPersonsSortList
         var pairInActivePersonList = [String]()
        for (index, personTuple) in defaultPersonsName.enumerated() {
            var userPair: String = ""
            let (name, isActive) = personTuple
            
            let userIndexInLastSort = lastPersonsSortList.index(of: name)
            if !isActive && (userIndexInLastSort != nil) {
                
                if (userIndexInLastSort! % 2 == 0) {
                    userPair = lastPersonsSortList[userIndexInLastSort!+1]
                    lastPersonsSortListWithoutInActivePerson.remove(at: userIndexInLastSort!+1)
                    lastPersonsSortListWithoutInActivePerson.remove(at: userIndexInLastSort!)
                } else {
                    userPair = lastPersonsSortList[userIndexInLastSort!-1]
                    lastPersonsSortListWithoutInActivePerson.remove(at: userIndexInLastSort!)
                    lastPersonsSortListWithoutInActivePerson.remove(at: userIndexInLastSort!-1)
                }
                
                pairInActivePersonList.append(userPair)
            }
        }
        
        return (lastPersonsSortListWithoutInActivePerson, pairInActivePersonList)
    }
    
    func getNewPerson(activePersonsName: [(name: String, isActive: Bool)], lastPersonsSortList: [String]) -> Array<String> {
        var newPersonList = [String]()
        for (index, personTuple) in activePersonsName.enumerated() {
            let (name, isActive) = personTuple
            let userIndexInLastSort = lastPersonsSortList.index(of: name)
            if (userIndexInLastSort != nil) {
                continue
            } else {
                newPersonList.append(name)
            }
        }
        return newPersonList
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
            ["李宇", "李文", "王昕", "张鑫", "曾杨", "司机", "唐真", "杨洁", "凤凤", "yaqing"].forEach({
                print($0)
                self.updatePerson(personName: $0)
            })
        }
        
        self.updateSort(CurrentSort: ["李宇", "李文", "王昕", "张鑫", "曾杨", "司机", "唐真", "杨洁", "凤凤", "yaqing"])
        alreadyAppendDefaultPerson = true
    }
}

func getUnRepeatPairOrder(numberOfPerson: Int) -> Array<Int> {
    // TODO: refactor the whole algorithm
    var OCCUPIED = -1
    var FREE = 0
    var width = numberOfPerson
    var lastRow = numberOfPerson - 1
    var numberOfDiagonals = 2 * numberOfPerson - 1
    var columns = Array(repeating: -1, count: numberOfPerson)
    var leftDiagonals = Array(repeating: 0, count: numberOfDiagonals)
    var rightDiagonals = Array(repeating: 0, count: numberOfDiagonals)
    var solutions = Array<Array<Int>>()
    
    func calculate(raw: Int = 0) {
        for column in 0..<width {
            let ixDiag1 = column + raw
            let ixDiag2 = width - 1 - raw + column
            
            if columns[column] >= 0 {
                continue
            }
            
            if leftDiagonals[ixDiag1] == OCCUPIED {
                continue
            }
            
            if rightDiagonals[ixDiag2] == OCCUPIED {
                continue
            }
            
            columns[column] = raw
            leftDiagonals[ixDiag1] = OCCUPIED
            rightDiagonals[ixDiag2] = OCCUPIED
            
            
            if raw == lastRow {
                solutions.append(columns)
            } else {
                calculate(raw: raw + 1)
            }
            
            columns[column] = -1
            leftDiagonals[ixDiag1] = FREE
            rightDiagonals[ixDiag2] = FREE
        }
    }
    calculate()
    let numberOfSolution = solutions.count
    
    let randomOrder = Int(arc4random_uniform(UInt32(numberOfSolution)))
    return solutions[randomOrder]
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
