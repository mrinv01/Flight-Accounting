//
//  LoginView.swift
//  Flight accounting
//
//  Created by Никита Ильютченко on 18.10.2024.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var user: FlightModel
    @Environment(\.openWindow) private var openWindow
    @Binding var isAuthenticated: Bool
    @Binding var isGuest: Bool
    var windowController: WindowController? // Добавляем ссылку на контроллер окна
    
    
    @State var login: String = ""
    @State var password: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(Color(.blue))
                    .padding(.top, 30)
                
                Text("Вход в Аккаунт")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 15)
                
                Text("Войдите в аккаунт, чтобы получить доступ ко всем возможностям системы.")
                    .padding(.top)
                
                VStack {
                    TextField("Логин", text: $login)
                    SecureField("Пароль", text: $password)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .transition(.opacity)
                        
                    }
                }
                .frame(width: 300)
                .padding(.top)
                
                Button("Войти") {
                    if user.checkUser(login: login, password: password) {
                        user.getUserName(for: login)
                        print(user.userName)
                        isAuthenticated = true
                        
                        
                        
                    } else {
                        withAnimation {
                            errorMessage = "Неверный логин или пароль"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                errorMessage = nil
                            }
                        }
                    }
                }
                .padding(.top, 10)
                
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            Button("Войти как гость") {
                isGuest.toggle()
            }
            .buttonStyle(.link)
            
            Button("Сведения о программе") {
                openWindow(id: "about")
            }
            .buttonStyle(.link)
            .padding(.top)
            .padding(.bottom, 12)
        }
        .padding()
    }
}


#Preview {
    @Previewable @State var isAuthenticated = false
    @Previewable @State var isGuest = true
    LoginView(user: FlightModel(), isAuthenticated: $isAuthenticated, isGuest: $isGuest)
}


