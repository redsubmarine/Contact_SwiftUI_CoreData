//
//  ContactRowView.swift
//  Contact
//
//  Created by 레드 on 2023/02/24.
//

import SwiftUI

struct ContactRowView: View {
    @Environment(\.managedObjectContext)
    private var managedObjectContext
    
    @ObservedObject var contact: Contact
    let provider: ContactsProvider
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(contact.formattedName)
                .font(.system(size: 26, design: .rounded).bold())
            Text(contact.email)
                .font(.callout.bold())
            Text(contact.phoneNumber)
                .font(.callout.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button(action: {
                toggleFavourite()
            }, label: {
                Image(systemName: "star")
                    .font(.title3)
                    .symbolVariant(.fill)
                    .foregroundColor(contact.isFavourite ? .yellow : .gray.opacity(0.3))
            })
            .buttonStyle(.plain)
        }
    }
}

private extension ContactRowView {
    func toggleFavourite() {
        contact.isFavourite.toggle()
        
        do {
            try provider.persist(in: managedObjectContext)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewProvider = ContactsProvider.shared
        ContactRowView(contact: .preview(context: previewProvider.viewContext), provider: previewProvider)
    }
}
