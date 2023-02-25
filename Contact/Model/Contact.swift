//
//  Contact.swift
//  Contact
//
//  Created by 레드 on 2023/02/24.
//

import Foundation
import CoreData

enum ContactError: Error {
    case contactIsNotValid
}

final class Contact: NSManagedObject, Identifiable {
    @NSManaged var dob: Date
    @NSManaged var name: String
    @NSManaged var notes: String
    @NSManaged var phoneNumber: String
    @NSManaged var email: String
    @NSManaged var isFavourite: Bool
    
    var isValid: Bool {
        !name.isEmpty && !phoneNumber.isEmpty && !email.isEmpty
    }
    
    override func validateForInsert() throws {
        try super.validateForInsert()
        
        if !isValid {
            throw ContactError.contactIsNotValid
        }
    }
    
    override func validateForUpdate() throws {
        try super.validateForUpdate()
        if !isValid {
            throw ContactError.contactIsNotValid
        }
    }
    
    var isBirthday: Bool {
        Calendar.current.isDateInToday(dob)
    }
    
    var formattedName: String {
        "\(isBirthday ? "🎈" : "")\(name)"
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(Date.now, forKey: "dob")
        setPrimitiveValue(false, forKey: "isFavourite")
    }
    
}

extension Contact {
    private static var contactsFetchRequest: NSFetchRequest<Contact> {
        NSFetchRequest(entityName: "Contact")
    }
    
    static func all() -> NSFetchRequest<Contact> {
        let request = contactsFetchRequest
        request.sortDescriptors = [
            .init(keyPath: \Contact.name, ascending: true)
        ]
        return request
    }
    
    static func filter(with config: SearchConfig) -> NSPredicate {
        let query = config.query
        switch config.filter {
        case .all:
            return query.isEmpty ? .init(value: true) : .init(format: "name CONTAINS[cd] %@", query)
        case .favourite:
            return query.isEmpty ? .init(format: "isFavourite == %@", NSNumber(value: true)) : .init(format: "name CONTAINS[cd] %@ AND isFavourite == %@", query, NSNumber(value: true))
        }
    }
    
    static func sort(order: Sort) -> [NSSortDescriptor] {
        [.init(keyPath: \Contact.name, ascending: order == .asc)]
    }
}

extension Contact {
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [Contact] {
        var contacts = [Contact]()
        for i in 0 ..< count {
            let contact = Contact(context: context)
            contact.name = "item \(i)"
            contact.email = "test_\(i)@mail.com"
            contact.isFavourite = Bool.random()
            contact.phoneNumber = "0100000000\(i)"
            contact.dob = Calendar.current.date(byAdding : .day,
                                                value: -i,
                                                to: .now) ?? .now
            contact.notes = "This is a preview for item \(i)"
            contacts.append(contact)
        }
        return contacts
    }
    
    static func preview(context: NSManagedObjectContext = ContactsProvider.shared.viewContext) -> Contact {
        makePreview(count: 1, in: context)[0]
    }
    
    static func empty(context: NSManagedObjectContext = ContactsProvider.shared.viewContext) -> Contact {
        Contact(context: context)
    }
}
