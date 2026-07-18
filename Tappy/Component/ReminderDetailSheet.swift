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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20){
                
                
                
                VStack {
                    Text("Apple Academy").font(.subheadline)
                    
                    HStack{
                        Text("Clock In").font(.title2)
                        
                        Spacer()
                        
                        
                        Text("10:00 AM").font(.title2.bold())
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                    .padding(.horizontal, 30)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(24)
                    HStack{
                        Text("Clock Out").font(.title2)
                        
                        Spacer()
                        
                        
                        Text("N/A").font(.title2.bold())
         
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                    .padding(.horizontal, 30)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(24)
                }
                
                
                VStack (spacing: 30) {
                    Text("History").font(.subheadline)
                    
                    HStack{
                        VStack(alignment: .leading){
                            
                            
                            Text("Clock In").font(.title3.bold())
                        
                            Text("Apple Academy").font(.subheadline)
                        }
                        Spacer()
                        
                        Text("10:00 AM").font(.title2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                    
                    HStack{
                        VStack(alignment: .leading){
                            
                            
                            Text("Clock In").font(.title3.bold())
                        
                            Text("Apple Academy").font(.subheadline)
                        }
                        Spacer()
                        
                        Text("11:00 AM").font(.title2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                    
                    
                    
                    
                }
                
                
                
                
                
                
            }
            
            .padding()
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
        .presentationDetents([.large])
        
    }
}

#Preview {
    ReminderDetailSheet(date: Date.now)
}
