//
//  CalenderIView.swift
//  Tappy
//
//  Created by Stephanie Vania Suwardi Data on 17/07/26.
//

import SwiftUI

struct CalenderIView: View {
    @State private var selectedDate: Date = .now
    @State private var showDetail = false

    
    
    var body: some View {
        
        VStack{
            Text("Reminder History").font(Font.body.bold())
            
            Divider()
                .padding()
            
            DatePicker(
                "Select a date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .onChange(of: selectedDate) { _, _ in
                            showDetail = true
                // a date was tapped -> show sheet
            }
            

        }
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .sheet(isPresented: $showDetail) {
            ReminderDetailSheet(date: selectedDate)
        }
        
        
        

    }
}

#Preview {
    CalenderIView()
}
