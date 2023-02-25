//
//  ContactsProvider.swift
//  Contact
//
//  Created by 레드 on 2023/02/24.
//

import Foundation
import CoreData

final class ContactsProvider {
    static let shared = ContactsProvider()
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    private init() {
        persistentContainer = .init(name: "ContactsDataModel")
        if EnvironmentValues.isPreview || Thread.current.isRunningXCTest {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(filePath: "/dev/null")
        }
        viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }
    
    func exists(_ contact: Contact, in context: NSManagedObjectContext) -> Contact? {
        try? context.existingObject(with: contact.objectID) as? Contact
    }
    
    func delete(_ contact: Contact, in context: NSManagedObjectContext) throws {
        if let existingContact = exists(contact, in: context) {
            context.delete(existingContact)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }
    
    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

import SwiftUI

extension EnvironmentValues {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

extension Thread {
    var isRunningXCTest: Bool {
        for key in threadDictionary.allKeys {
            guard let keyString = key as? String else { continue }
            
            if keyString.split(separator: ".").contains("xctest") {
                return true
            }
        }
        return false
    }
}
