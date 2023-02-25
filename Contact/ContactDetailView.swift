//
//  ContactDetailView.swift
//  Contact
//
//  Created by 레드 on 2023/02/24.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: Contact
    
    var body: some View {
        List {
            Section("General") {
                LabeledContent(content: {
                    Text(contact.email)
                }, label: {
                    Text("Email")
                })
                
                LabeledContent(content: {
                    Text(contact.phoneNumber)
                }, label: {
                    Text("Phone Number")
                })
                
                LabeledContent(content: {
                    Text(contact.dob, style: .date)
                }, label: {
                    Text("Birthday")
                })
            }
            
            Section("Notes") {
                Text(contact.notes)
            }
        }
        .navigationTitle(contact.formattedName)
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContactDetailView(contact: .preview())
        }
    }
}
