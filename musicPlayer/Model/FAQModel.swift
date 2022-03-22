//
//  FAQModel.swift
//  NextJAM
//
//  Created by apple on 18/11/21.
//


import Foundation

// MARK: - FAQModel
struct FAQModel: Codable {
    var faqs: [FAQ]
}

// MARK: - FAQ
struct FAQ: Codable {
    var id: Int
    var question : String
    var answer: String
}

