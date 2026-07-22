//
//  ReminderView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI
import SwiftData


struct ReminderView: View {
    @Query private var reminderData: [ReminderData]
    @Environment(\.modelContext) private var context
    
    @State var showingAddReminder: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 250),spacing: 0)
    ]
    
    var body: some View {
        VStack {
            Text("Reminder").font(Font.body.bold())
            
            Divider()
                .padding()
            
        HStack {
                Button("Edit"){
            }
            Button("Add"){
                showingAddReminder.toggle()
            } .sheet(isPresented: $showingAddReminder) {
                AddReminder()
                    
            }
            
           
            }
            
            if reminderData.isEmpty {
                            Spacer()
                            ContentUnavailableView("Belum ada Reminder", systemImage: "bell.slash")
                            Spacer()
            } else {
                List(reminderData, id: \.id) { reminder in
                    VStack(){
                        Text(reminder.ReminderName)
                            .font(.headline)
                        
                        
                    }
                }}
            
            
            
        }
       
        }

        
    }
    
    


#Preview {
    ReminderView()
}
