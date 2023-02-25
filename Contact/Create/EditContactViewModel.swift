//
//  EditContactViewModel.swift
//  Contact
//
//  Created by 레드 on 2023/02/25.
//

import Foundation
import CoreData

final class EditContactViewModel: ObservableObject {
    
    @Published var contact: Contact
    let isNew: Bool
    private let provider: ContactsProvider
    private let context: NSManagedObjectContext
    
    init(provider: ContactsProvider, contact: Contact? = nil) {
        self.provider = provider
        context = provider.newContext
        
        if let contact,
           let existingCopy = provider.exists(contact, in: context) {
            self.contact = existingCopy
            isNew = false
        } else {
            self.contact = Contact(context: context)
            isNew = true
        }
    }
    
    func save() throws {
        try provider.persist(in: context)
    }
}
