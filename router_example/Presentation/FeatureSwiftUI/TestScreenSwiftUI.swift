//
//  TestScreenSwiftUI.swift
//  router_example
//
//  Created by Алексей Попков on 25.07.2024.
//

import SwiftUI

struct TestScreenSwiftUI: View, OnRouteProtocol {
    let isModal: Bool
    var onRoute: ((Route) -> Void)?
    
    var body: some View {
        List(content: {
                Button {
                    onRoute?(.onPushAnotherTestScreen)
                } label: {
                    Text("Push Another Test Screen")
                }
                Button {
                    onRoute?(.onPresentAnotherTestScreen)
                } label: {
                    Text("Present Another Test Screen")
                }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Test Screen (SwiftUI)"))
            .toolbar(content: {
                if (isModal)
                {
                    HStack {
                        Spacer()
                        Button {
                            onRoute?(.onBack)
                        } label: {
                            Text("Close")
                        }
                    }
                }
            })
    }
}

extension TestScreenSwiftUI {
    enum Route: String, Identifiable {
        case onPushAnotherTestScreen
        case onPresentAnotherTestScreen
        case onBack
    }
}

extension TestScreenSwiftUI.Route {
    var id: String {
        return rawValue
    }
}

#Preview {
    TestScreenSwiftUI(isModal: true)
}
