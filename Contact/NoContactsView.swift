//
//  NoContactsView.swift
//  Contact
//
//  Created by 레드 on 2023/02/25.
//

import SwiftUI

struct NoContactsView: View {
    var body: some View {
        VStack {
            Text("👀 No Contacts")
            .font(.largeTitle.bold())
            
            Text("It's seems a lil empty here create some contacts ☝🏻")
            . font(.callout)
        }
    }
}

struct NoContactView_Previews: PreviewProvider {
    static var previews: some View {
        NoContactsView()
    }
}
