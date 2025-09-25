//
//  Country.swift
//  CountriesGraphQL
//
//  Created by Angel Docampo on 25/9/25.
//

import Foundation

struct Country: Identifiable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let capital: String?
    let emoji: String
}

// We'll add GraphQL conversion later when the types are working