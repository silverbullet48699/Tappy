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
            }
            
            }
            
            LazyVGrid(columns: columns, spacing: 1) {
                VStack{
                        Text(reminderData.first!.name)
                    
                }
            }
            
            
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        
        .sheet(isPresented: $showingAddReminder) {
            AddReminder()
                
        }

        
    }
    
        
     
    
    
    
    
}

#Preview {
    ReminderView()
}
