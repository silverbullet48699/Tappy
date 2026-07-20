//
//  ReminderDetailSheet.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 18/07/26.
//

import SwiftUI

struct ReminderDetailSheet: View {
    let date : Date
    @Environment(\.dismiss) private var dismiss
    // 1. Properties declared at the struct level
    @State private var absen = false
    let calendar = Calendar.current
    let now = Date()
    
    
        
    // 2. Logic computed safely inside a property
    var targetDate: Date? {
        calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20){
                    VStack {
                        Text("Apple Academy").font(.subheadline)
                        
                        Toggle("Absen", isOn: $absen)
                                        .tint(.blue)
                                        .padding()
                        
                        ClockCard(clockType: ClockType.clockIn, date: targetDate ?? Date.now)
                        
                        ClockCard(clockType: ClockType.clockOut, date: nil)
                    }
                    VStack (spacing: 30) {
                        Text("History").font(.subheadline)
                        ScrollView{
                            VStack(spacing: 30){
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
                                
                            }
                        }
                        
                        
                        
                        
                    }

                }
                
                .padding(.horizontal, 30)
                .navigationTitle(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        // Triggers the dismissal
                        Button("Back", systemImage: "checkmark")
                        {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .labelStyle(.iconOnly)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
        }
        .presentationDetents([.large])
        
    }
}

#Preview {
    ReminderDetailSheet(date: Date.now)
}
