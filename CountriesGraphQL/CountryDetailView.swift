//
//  CountryDetailView.swift
//  CountriesGraphQL
//
//  Created by Angel Docampo on 25/9/25.
//

import SwiftUI
import Apollo

struct CountryDetailView: View {
    
    let country: Country
    @State private var countryInfo: CountryInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Header with flag and basic info
            VStack(spacing: 8) {
                Text(country.emoji)
                    .font(.system(size: 80))
                
                Text(country.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let capital = country.capital {
                    Text("Capital: \(capital)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Text("Code: \(country.code)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // States/Subdivisions section
            if isLoading {
                ProgressView("Loading details...")
            } else if let errorMessage = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Error loading details")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let countryInfo = countryInfo, !countryInfo.states.isEmpty {
                VStack(alignment: .leading) {
                    Text("States/Provinces")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List(countryInfo.states, id: \.name) { state in
                        Text(state.name)
                    }
                    .listStyle(PlainListStyle())
                }
            } else {
                Text("No additional details available")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Spacer()
        }
        .task {
            await loadCountryDetails()
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @MainActor
    private func loadCountryDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let query = """
            query GetCountryInfo($code: ID!) {
                country(code: $code) {
                    name
                    capital
                    emoji
                    states {
                        name
                    }
                }
            }
            """
            
            let url = URL(string: "https://countries.trevorblades.com/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody: [String: Any] = [
                "query": query,
                "variables": ["code": country.code]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            struct GraphQLResponse: Codable {
                let data: GraphQLData
            }
            
            struct GraphQLData: Codable {
                let country: GraphQLCountryInfo?
            }
            
            struct GraphQLCountryInfo: Codable {
                let name: String
                let capital: String?
                let emoji: String
                let states: [GraphQLState]
            }
            
            struct GraphQLState: Codable {
                let name: String
            }
            
            let response = try JSONDecoder().decode(GraphQLResponse.self, from: data)
            
            if let graphQLCountryInfo = response.data.country {
                countryInfo = CountryInfo(
                    name: graphQLCountryInfo.name,
                    capital: graphQLCountryInfo.capital,
                    emoji: graphQLCountryInfo.emoji,
                    states: graphQLCountryInfo.states.map { CountryState(name: $0.name) }
                )
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct CountryInfo {
    let name: String
    let capital: String?
    let emoji: String
    let states: [CountryState]
}

struct CountryState {
    let name: String
}

#Preview {
    CountryDetailView(country: Country(
        code: "US",
        name: "United States",
        capital: "Washington D.C.",
        emoji: "🇺🇸"
    ))
}
