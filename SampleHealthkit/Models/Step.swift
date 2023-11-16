//
//  Step.swift
//  SampleHealthkit
//
//  Created by yuwenqian chen on 10/3/23.
//

import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
