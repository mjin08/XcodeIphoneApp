//
//  MainView.swift
//  SampleHealthkit
//
//  Created by yuwenqian chen on 11/3/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var healthStore = Healthstore()
    @State private var userInput: String = ""


    var body: some View {
        VStack{
            TextField("Enter Patient ID: ", text: $userInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            
            Button("Submit"){
//                let textProcessor = TextProcessor()
                healthStore.processText(userInput)
            }
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            
//            Text("Your health data have been sent to the doctor successfully!")
//                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                .padding()
        }
        
    }
}

#Preview {
    MainView()
}
