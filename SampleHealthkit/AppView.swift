//
//  AppView.swift
//  SampleHealthkit
//
//  Created by yuwenqian chen on 11/14/23.
//

//  Created by yuwenqian chen on 11/14/23.
//

import SwiftUI

struct AppView: View {
    @StateObject var healthStore = Healthstore()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Xcode App")
                    .padding()
                    .onAppear {
                        healthStore.getAuthorization()
                        print(healthStore.isAuthorized)
                    }

                if healthStore.isAuthorized {
                    NavigationLink(
                        destination: MainView(),
                        label: {
                            Text("Go to Main View")
                        }
                    )
                }
            }
            .navigationTitle("App Title") // Set your navigation title here
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
