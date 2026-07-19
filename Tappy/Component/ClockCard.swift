//
//  ClockCard.swift
//  Tappy
//
//  Created by Muhammad Rasya Devansyah on 18/07/26.
//

import SwiftUI

struct ClockCard: View {
    
    let clockType : ClockType
    let date : Date?
    
    var body: some View {
        HStack{
            
            if(clockType == ClockType.clockIn){
                Text("Clock In").font(.title2)
            }
            else{
                Text("Clock Out").font(.title2)
            }
            
            Spacer()
            
 
            let formattedDate = date?.formatted(
                    
                    .dateTime
                    .hour(.twoDigits(amPM: .abbreviated))
                    .minute(.twoDigits)
                    .locale(Locale(identifier: "en_US"))
                
            )
                            
            Text(formattedDate ?? "N/A").font(.title2.bold())

            
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding(.horizontal, 30)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(24)
    }
}

#Preview {

    ClockCard(clockType: ClockType.clockIn, date: nil)
              
}
