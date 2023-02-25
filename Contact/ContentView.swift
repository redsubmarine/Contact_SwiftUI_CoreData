//
//  ContentView.swift
//  Contact
//
//  Created by 레드 on 2023/02/24.
//

import SwiftUI

struct SearchConfig: Equatable {
    enum Filter {
        case all, favourite
    }
    
    var query = ""
    var filter: Filter = .all
}

enum Sort {
    case asc, desc
}

struct ContentView: View {
    
    @FetchRequest(fetchRequest: Contact.all())
    private var contacts
    
    @State private var contactToEdit: Contact?
    @State private var searchConfig = SearchConfig()
    @State private var sort = Sort.asc
    
    var provider = ContactsProvider.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if contacts.isEmpty {
                    NoContactsView()
                } else {
                    List {
                        ForEach(contacts) { contact in
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: ContactDetailView(contact: contact), label: {
                                    EmptyView()
                                })
                                
                                .opacity(0)
                                
                                ContactRowView(contact: contact, provider: provider)
                                    .swipeActions(allowsFullSwipe: true) {
                                        Button(role: .destructive, action: {
                                            do {
                                                try provider.delete(contact, in: provider.newContext)
                                            } catch {
                                                print(error)
                                            }
                                        }, label: {
                                            Label("Delete", systemImage: "trash")
                                        })
                                        .tint(.red)
                                        
                                        Button(action: {
                                            contactToEdit = contact
                                        }, label: {
                                            Label("Edit", systemImage: "pencil")
                                        })
                                        .tint(.orange)
                                    }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchConfig.query)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        contactToEdit = .empty(context: provider.newContext)
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Section {
                            Text("Filter")
                            Picker(selection: $searchConfig.filter, content: {
                                Text("All").tag(SearchConfig.Filter.all)
                                Text("Favourites").tag(SearchConfig.Filter.favourite)
                            }, label: {
                                Text("Filter Favourites")
                            })
                            
                            Text("Sort")
                            Picker(selection: $sort, content: {
                                Label("Asc", systemImage: "arrow.up").tag(Sort.asc)
                                Label("Desc", systemImage: "arrow.down").tag(Sort.desc)
                            }, label: {
                                Text("Sort by")
                            })
                        }
                    }, label: {
                        Image(systemName: "ellipsis")
                            .symbolVariant(.circle)
                            .font(.title2)
                    })
                }
            }
            .sheet(item: $contactToEdit, onDismiss: {
                contactToEdit = nil
            }, content: { contact in
                NavigationStack {
                    CreateContactView(viewModel: .init(provider: provider, contact: contact))
                }
            })
            .navigationTitle("Contacts")
            .onChange(of: searchConfig) { newConfig in
                contacts.nsPredicate = Contact.filter(with: newConfig)
            }
            .onChange(of: sort) { newSort in
                contacts.nsSortDescriptors = Contact.sort(order: newSort)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = ContactsProvider.shared
        ContentView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .previewDisplayName("Contacts With Data")
            .onAppear {
                Contact.makePreview(count: 10, in: preview.viewContext)
            }
            
        let emptyPreview = ContactsProvider.shared
        ContentView(provider: emptyPreview)
            .environment(\.managedObjectContext, emptyPreview.viewContext)
            .previewDisplayName("Contacts With No Data")
    }
}
