//
//  Healthstore.swift
//  SampleHealthkit
//
//  Created by yuwenqian chen on 10/30/23.
//

import Foundation
import HealthKit
import Combine
import UIKit

class Healthstore: ObservableObject{
    @Published var speedData: [[String: Any]] = [];
    @Published var asymmetryData: [[String: Any]] = [];
    @Published var isAuthorized: Bool = false
    var healthStore: HKHealthStore
    //iphone_id is the vendorID
    var vendorID: String
    var patientID: String
    
    
    // initialize the health store
    init(){
        print("do init")
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            fatalError("*** HealthStore is not available ***")
        }
        
        if let identifierForVendor = UIDevice.current.identifierForVendor {
            vendorID = identifierForVendor.uuidString
            print(vendorID)
        } else {
            fatalError("*** Unable to retrieve iPhone ID ***")
        }
        
        patientID = "000"
    }
    
    
    func getAuthorization(){
        print("Get authorization")
        guard let asymmetry = HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage)else{
            fatalError("*** Unable to create a stride type ***")
        }
        guard let speed = HKQuantityType.quantityType(forIdentifier: .walkingSpeed)else{
            fatalError("*** Unable to create a speed type ***")
        }
        print("authorized status:", isAuthorized)
        healthStore.requestAuthorization(toShare: [], read: [speed, asymmetry]){ (success, error) in
            if !success {
                fatalError("*** Unable to requestAuthorization for speed ***")
            }
            else{
                self.isAuthorized = true;
                print("authorized status updated:", self.isAuthorized)
            }
        }
    }

    func getSpeed() {
        print("Get speed")
        guard let speedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            fatalError("*** Unable to create a speed type ***")
        }
        
        let calendar = Calendar.current
        let now = Date()
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) { // Get the date for yesterday
            let startOfDay = calendar.startOfDay(for: yesterday)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let dateFormatter = ISO8601DateFormatter()
            
            let query = HKSampleQuery(
                sampleType: speedType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { query, results, error in
                    if let samples = results as? [HKQuantitySample] {
                        // Handle the raw speed data for the specified day
                        for sample in samples {
                            let speed = sample.quantity.doubleValue(for: HKUnit.meter().unitDivided(by: .second()))
                            let dateString = dateFormatter.string(from: sample.startDate) // Convert Date to String
                                                    
                            let dataPoint: [String: Any] = ["value": speed, "timestamp": dateString]
                            self.speedData.append(dataPoint)
                        }
                    }
                    
                    // Use speedData or pass it to another function
                    // e.g., update a @Published property in your ViewModel
                    print(self.speedData)
                    self.tryToPostPatient()
                    
               // postPatient(speedData: self.speedData)
                }
            
            healthStore.execute(query)
            
        }
    }
    
    func getWalkingAsymmetryPercentage() {
        print("Get walking asymmetry percentage")
        
        guard let asymmetryType = HKQuantityType.quantityType(forIdentifier: .walkingAsymmetryPercentage) else {
            fatalError("*** Unable to create a walking asymmetry percentage type ***")
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) { // Get the date for yesterday
            let startOfDay = calendar.startOfDay(for: yesterday)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let dateFormatter = ISO8601DateFormatter()
            
            let query = HKSampleQuery(
                sampleType: asymmetryType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { query, results, error in
                    if let samples = results as? [HKQuantitySample] {
                        // Handle the raw asymmetry percentage data for the specified day
                        for sample in samples {
                            let asymmetryPercentage = sample.quantity.doubleValue(for: .percent())
                            let dateString = dateFormatter.string(from: sample.startDate) // Convert Date to String
                            
                            let dataPoint: [String: Any] = ["value": asymmetryPercentage, "timestamp": dateString]
                            self.asymmetryData.append(dataPoint)
                        }
                    }
                    
                    // Use asymmetryData or pass it to another function
                    // e.g., update a @Published property in your ViewModel
                    print(self.asymmetryData)
                    self.tryToPostPatient()
                    
                    // Uncomment the following line if you want to perform some action with the asymmetry data
                    // postAsymmetryData(asymmetryData: self.asymmetryData)
                }
            
            healthStore.execute(query)
        }
    }
    
    func tryToPostPatient() {
        if !speedData.isEmpty && !asymmetryData.isEmpty {
            print("Both speed and asymmetry data obtained. Calling postPatient.")
//            print("speed: ", speedData)
//            print("asymmetry: ", asymmetryData)
            postPatient(speedData: speedData, asymmetryData: asymmetryData)
        } else {
            print("Waiting for either speed or asymmetry data...")
        }
    }

        

    func postPatient(speedData: [[String: Any]], asymmetryData:[[String: Any]]) {
            
            print("in postPatient\n", speedData[1])
            print("asymmetryData: ", asymmetryData[1])
            print("vendorId", vendorID)
            print("Patient ID", patientID)
            
            let dateFormatter = ISO8601DateFormatter()
            
            // Define the request body
            let parameters: [String: Any] = [
                "patient_id": patientID,
                "iPhone_id": vendorID,
                "dailyData": [
                    [
                        "date": dateFormatter.string(from: Date()),
                        "DST": [],
                        "Speed": speedData,
                        "Asymetry": asymmetryData,
                        "Stride": []
                    ]
                ]
            ]
            
            print("1")
            
            // Create the URL and request
            if let url = URL(string: "https://xcodebackend.onrender.com/api/patient/") {
                var request = URLRequest(url: url)
            //    request.timeoutInterval = 15
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                print("2")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                    request.httpBody = jsonData
                } catch {
                //    print("3")
                    print("Error creating JSON data: \(error)")
                    return
                }
                print("4")
                
                // Perform the POST request
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    print("in post")
                    if let error = error {
                        if let response = response as? HTTPURLResponse {
                        print("HTTP status code: \(response.statusCode)")
                        }
                        print("Error in POST request: \(error)")
                        return
                    }
                    
                //    if let response = response as? HTTPURLResponse {
                //        if response.statusCode == 400{
                //            print("statusCode 400")
                //        }
                //        if(response.statusCode == 200){
                //            print("statusCode 200")
                //        }
                //    }
                    
                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("POST request response: \(responseString)")
                        }
                    }
                }
                task.resume()
            } else {
                print("Invalid URL")
            }
        }

    
    func processText(_ text: String) {
        print("patient id: ", patientID)
        // Implement your text processing logic here.
        print("Processing text: \(text)")
        patientID = text
        print("patiend id update: ", patientID)
        if(patientID != "000"){
            getSpeed()
            getWalkingAsymmetryPercentage()
//            if(!speedData.isEmpty){
//                print("speed: ", speedData)
//                print("asymmetry: ", asymmetryData)
//            }else{
//                print("speed data is empty")
//            }
//            postPatient(speedData: speedData, asymmetryData: asymmetryData)
        }else{
            fatalError("*** did not input patient ID")
        }
    }
    
}
