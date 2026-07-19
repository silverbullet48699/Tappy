//
//  ClockHistory.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 18/07/26.
//

import SwiftUI

struct ClockHistory: View {
    
    let date : Date
    let clockType : ClockType
    let reminderName : String
    
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                
                
                if(clockType == ClockType.clockIn){
                    Text("Clock In").font(.title3.bold())
                }
                else{
                    Text("Clock Out").font(.title3.bold())
                }
                
                
            
                Text(reminderName).font(.subheadline)
            }
            Spacer()
            
            Text(
                date.formatted(
                    
                    .dateTime
                    .hour(.twoDigits(amPM: .abbreviated))
                    .minute(.twoDigits)
                    .locale(Locale(identifier: "en_US"))
                
                )

                
            
            
            ).font(.title2)
        }
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
    }
}

#Preview {
    ClockHistory(date: Date.now, clockType: ClockType.clockIn, reminderName: "Apple Academy")
}
