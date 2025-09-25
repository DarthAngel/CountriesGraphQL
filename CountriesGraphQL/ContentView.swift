//
//  ContentView.swift
//  CountriesGraphQL
//
//  Created by Angel Docampo on 25/9/25.
//

import SwiftUI
import Apollo
import ApolloAPI

struct ContentView: View {
    
    @State private var countries: [Country] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                if isLoading {
                    ProgressView("Loading countries...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await loadCountries()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(countries) { country in
                        NavigationLink(
                            destination: CountryDetailView(country: country),
                            label: {
                                HStack {
                                    Text(country.emoji)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(country.name)
                                            .font(.headline)
                                        if let capital = country.capital {
                                            Text(capital)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        )
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .task {
                await loadCountries()
            }
            .navigationTitle("Countries")
        }
    }
    
    @MainActor
    private func loadCountries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Using raw Apollo client to execute the GraphQL query as a string
            let query = """
            query GetAllCountries {
                countries {
                    code
                    name
                    capital
                    emoji
                }
            }
            """
            
            // For now, let's use a simple approach with URLSession
            // Later we can switch back to Apollo once the generated types work
            let url = URL(string: "https://countries.trevorblades.com/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody = [
                "query": query
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            struct GraphQLResponse: Codable {
                let data: GraphQLData
            }
            
            struct GraphQLData: Codable {
                let countries: [GraphQLCountry]
            }
            
            struct GraphQLCountry: Codable {
                let code: String
                let name: String
                let capital: String?
                let emoji: String
            }
            
            let response = try JSONDecoder().decode(GraphQLResponse.self, from: data)
            
            // Convert to our Country model
            countries = response.data.countries.map { graphQLCountry in
                Country(
                    code: graphQLCountry.code,
                    name: graphQLCountry.name,
                    capital: graphQLCountry.capital,
                    emoji: graphQLCountry.emoji
                )
            }
            
        } catch {
            errorMessage = "Failed to load countries: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}
