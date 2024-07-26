//
//  FeatureSwiftUI.swift
//  router_example
//
//  Created by Алексей Попков on 25.07.2024.
//

import SwiftUI

struct FeatureSwiftUI: View, OnRouteProtocol {
    let isModal: Bool
    var onRoute: ((Route) -> Void)?
    
    var body: some View {
        List(content: {
                Button {
                    onRoute?(.onPushSomthing)
                } label: {
                    Text("Push somthing")
                }
                Button {
                    onRoute?(.onPresentSomthing)
                } label: {
                    Text("Present somthing")
                }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Feature (SwiftUI)"))
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

extension FeatureSwiftUI {
    enum Route: String, Identifiable {
        case onPushSomthing
        case onPresentSomthing
        case onBack
    }
}

extension FeatureSwiftUI.Route {
    var id: String {
        return rawValue
    }
}

#Preview {
    FeatureSwiftUI(isModal: true)
}
