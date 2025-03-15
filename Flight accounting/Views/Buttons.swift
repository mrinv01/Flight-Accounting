//
//  Buttons.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 19.11.2024.
//

import SwiftUI

struct Buttons: View {
    @State private var showAddFlight = false
    @State private var showEditFlight = false
    @State private var showRegisterPassenger = false
    @State private var showCleanUp = false
    @State private var showAircraftView = false
    @State private var showSearchView = false
    
    @ObservedObject var flight: FlightModel
    @ObservedObject var aircraft: AircraftModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showAddFlight = true
                }) {
                    VStack {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Добавить рейс")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.top, 5)
                    }
                    .padding()
                }
                .sheet(isPresented: $showAddFlight) {
                    AddFlightView(flightModel: flight, aircraftModel: aircraft)
                }
                
                Button(action: {
                    showEditFlight = true
                }) {
                    VStack {
                        Image(systemName: "pencil.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Изменить рейс")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.top, 5)
                    }
                    .padding()
                }
                .sheet(isPresented: $showEditFlight) {
                    EditFlightView(flightModel: flight)
                }
            }
            
            HStack {
                Button(action: {
                    showRegisterPassenger = true
                }) {
                    VStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Регистрация пассажира")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.top, 5)
                    }
                    .frame(width: 309)
                    .padding()
                }
                .sheet(isPresented: $showRegisterPassenger) {
                    RegisterPassengerView(flightModel: flight)
                }
            }
            
            HStack {
                Button(action: {
                    showAircraftView = true
                }) {
                    VStack {
                        Image(systemName: "airplane.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Cамолет")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.top, 5)
                    }
                    .padding()
                }
                .sheet(isPresented: $showAircraftView) {
                    AddAircraftView()
                }
                
                Button(action: {
                    showSearchView = true
                }) {
                    VStack {
                        Image(systemName: "list.bullet.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        Text("Отчет по пассажирам")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.top, 5)
                    }
                    .padding()
                }
                .sheet(isPresented: $showSearchView) {
                    PassengersView()
                }
            }
            .frame(width: 360)
            
            
            
            Spacer().frame(height: 100)
            Button(action: {
                showCleanUp = true
            }) {
                Text("Очистка данных")
            }
            .cornerRadius(50)
            .padding()
            .sheet(isPresented: $showCleanUp) {
                ClearDataView(flight: flight)
            }
        }
        .padding()
        
    }
}

#Preview {
    Buttons(flight: FlightModel(), aircraft: AircraftModel())
}
