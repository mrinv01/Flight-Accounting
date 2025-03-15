//
//  GuestView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 19.11.2024.
//

import SwiftUI

struct GuestView: View {
    enum Tab {
      case departure, arrival, settings
     }
    
    @State private var selectedTab: Tab = .departure
    @Binding var isGuest: Bool
    @StateObject private var flights = FlightModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DepartureView(flights: flights, isGuest: $isGuest)
                .tabItem {
                    Label("Вылет", systemImage: "house")
                }
                .tag(Tab.departure)
            ArrivalView(flights: flights, isGuest: $isGuest)
                .tabItem {
                    Label("Прилёт", systemImage: "house")
                }
                .tag(Tab.arrival)
        }
    }
    
}

#Preview {
    @Previewable @State var isGuest: Bool = true
    GuestView(isGuest: $isGuest)
}
