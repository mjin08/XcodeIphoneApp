//
//  DoubleStandView.swift
//  SampleHealthkit
//
//  Created by yuwenqian chen on 10/30/23.
//

import SwiftUI

struct DoubleStandView: View {
    @ObservedObject var healthStore = Healthstore()
//    @State private var userInput: String = ""

    var body: some View {
        VStack {
//            Text("Enter Patient ID: ", text: $userInput)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            Button("Submit"){
//                healthStore.patientId(userInput)
//            }
            Text("Running Stride Length Data:")
                .font(.title)
        }
            .onAppear {
                healthStore.getAuthorization()
            }
        }
}

struct DoubleStandView_Previews: PreviewProvider {
    static var previews: some View {
        DoubleStandView()
    }
}
