//
//  ContentView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView{
                
                Tab("Home", systemImage: "house.fill"){
                    HomeView()
                }
                Tab("Reminder", systemImage: "bell.fill"){
                    ReminderView()
                }
                
                
                Tab("Calender", systemImage: "calendar"){
                    HomeView()
                }
                
                
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
