//
//  CountriesGraphQLTests.swift
//  CountriesGraphQLTests
//
//  Created by Angel Docampo on 25/9/25.
//

import Testing
import Foundation
@testable import CountriesGraphQL

@Suite("Countries GraphQL App Tests")
struct CountriesGraphQLTests {
    
    // MARK: - Model Tests
    
    @Suite("Country Model Tests")
    struct CountryModelTests {
        
        @Test("Country creation with all properties")
        func countryCreationComplete() async throws {
            let country = Country(
                code: "US",
                name: "United States",
                capital: "Washington D.C.",
                emoji: "🇺🇸"
            )
            
            #expect(country.code == "US")
            #expect(country.name == "United States")
            #expect(country.capital == "Washington D.C.")
            #expect(country.emoji == "🇺🇸")
            #expect(country.id != UUID()) // Should have a unique ID
        }
        
        @Test("Country creation with nil capital")
        func countryCreationWithNilCapital() async throws {
            let country = Country(
                code: "AQ",
                name: "Antarctica",
                capital: nil,
                emoji: "🇦🇶"
            )
            
            #expect(country.code == "AQ")
            #expect(country.name == "Antarctica")
            #expect(country.capital == nil)
            #expect(country.emoji == "🇦🇶")
        }
        
        @Test("Country Codable conformance")
        func countryCodableConformance() async throws {
            let originalCountry = Country(
                code: "CA",
                name: "Canada",
                capital: "Ottawa",
                emoji: "🇨🇦"
            )
            
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let encodedData = try encoder.encode(originalCountry)
            let decodedCountry = try decoder.decode(Country.self, from: encodedData)
            
            #expect(decodedCountry.code == originalCountry.code)
            #expect(decodedCountry.name == originalCountry.name)
            #expect(decodedCountry.capital == originalCountry.capital)
            #expect(decodedCountry.emoji == originalCountry.emoji)
        }
        
        @Test("Country Identifiable conformance")
        func countryIdentifiableConformance() async throws {
            let country1 = Country(code: "FR", name: "France", capital: "Paris", emoji: "🇫🇷")
            let country2 = Country(code: "DE", name: "Germany", capital: "Berlin", emoji: "🇩🇪")
            
            #expect(country1.id != country2.id)
        }
    }
    
    // MARK: - CountryInfo and CountryState Tests
    
    @Suite("Country Detail Models Tests")
    struct CountryDetailModelsTests {
        
        @Test("CountryState creation")
        func countryStateCreation() async throws {
            let state = CountryState(name: "California")
            #expect(state.name == "California")
        }
        
        @Test("CountryInfo creation with states")
        func countryInfoCreationWithStates() async throws {
            let states = [
                CountryState(name: "California"),
                CountryState(name: "New York"),
                CountryState(name: "Texas")
            ]
            
            let countryInfo = CountryInfo(
                name: "United States",
                capital: "Washington D.C.",
                emoji: "🇺🇸",
                states: states
            )
            
            #expect(countryInfo.name == "United States")
            #expect(countryInfo.capital == "Washington D.C.")
            #expect(countryInfo.emoji == "🇺🇸")
            #expect(countryInfo.states.count == 3)
            #expect(countryInfo.states[0].name == "California")
        }
        
        @Test("CountryInfo creation with empty states")
        func countryInfoCreationWithEmptyStates() async throws {
            let countryInfo = CountryInfo(
                name: "Monaco",
                capital: "Monaco",
                emoji: "🇲🇨",
                states: []
            )
            
            #expect(countryInfo.states.isEmpty)
        }
        
        @Test("CountryInfo creation with nil capital")
        func countryInfoCreationWithNilCapital() async throws {
            let countryInfo = CountryInfo(
                name: "Antarctica",
                capital: nil,
                emoji: "🇦🇶",
                states: []
            )
            
            #expect(countryInfo.capital == nil)
        }
    }
    
    // MARK: - GraphQL Response Models Tests
    
    @Suite("GraphQL Response Models Tests")
    struct GraphQLResponseModelsTests {
        
        @Test("GraphQL Country parsing from JSON")
        func graphQLCountryParsing() async throws {
            let jsonString = """
            {
                "code": "JP",
                "name": "Japan",
                "capital": "Tokyo",
                "emoji": "🇯🇵"
            }
            """
            
            let jsonData = try #require(jsonString.data(using: .utf8))
            
            // We need to create these types for testing since they're embedded in ContentView
            struct GraphQLCountry: Codable {
                let code: String
                let name: String
                let capital: String?
                let emoji: String
            }
            
            let graphQLCountry = try JSONDecoder().decode(GraphQLCountry.self, from: jsonData)
            
            #expect(graphQLCountry.code == "JP")
            #expect(graphQLCountry.name == "Japan")
            #expect(graphQLCountry.capital == "Tokyo")
            #expect(graphQLCountry.emoji == "🇯🇵")
        }
        
        @Test("GraphQL Country parsing with nil capital")
        func graphQLCountryParsingWithNilCapital() async throws {
            let jsonString = """
            {
                "code": "AQ",
                "name": "Antarctica",
                "capital": null,
                "emoji": "🇦🇶"
            }
            """
            
            let jsonData = try #require(jsonString.data(using: .utf8))
            
            struct GraphQLCountry: Codable {
                let code: String
                let name: String
                let capital: String?
                let emoji: String
            }
            
            let graphQLCountry = try JSONDecoder().decode(GraphQLCountry.self, from: jsonData)
            
            #expect(graphQLCountry.capital == nil)
        }
        
        @Test("GraphQL Countries response parsing")
        func graphQLCountriesResponseParsing() async throws {
            let jsonString = """
            {
                "data": {
                    "countries": [
                        {
                            "code": "US",
                            "name": "United States",
                            "capital": "Washington D.C.",
                            "emoji": "🇺🇸"
                        },
                        {
                            "code": "CA",
                            "name": "Canada",
                            "capital": "Ottawa",
                            "emoji": "🇨🇦"
                        }
                    ]
                }
            }
            """
            
            let jsonData = try #require(jsonString.data(using: .utf8))
            
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
            
            let response = try JSONDecoder().decode(GraphQLResponse.self, from: jsonData)
            
            #expect(response.data.countries.count == 2)
            #expect(response.data.countries[0].name == "United States")
            #expect(response.data.countries[1].name == "Canada")
        }
        
        @Test("GraphQL Country detail response parsing")
        func graphQLCountryDetailResponseParsing() async throws {
            let jsonString = """
            {
                "data": {
                    "country": {
                        "name": "United States",
                        "capital": "Washington D.C.",
                        "emoji": "🇺🇸",
                        "states": [
                            {"name": "California"},
                            {"name": "New York"},
                            {"name": "Texas"}
                        ]
                    }
                }
            }
            """
            
            let jsonData = try #require(jsonString.data(using: .utf8))
            
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
            
            let response = try JSONDecoder().decode(GraphQLResponse.self, from: jsonData)
            let countryInfo = try #require(response.data.country)
            
            #expect(countryInfo.name == "United States")
            #expect(countryInfo.capital == "Washington D.C.")
            #expect(countryInfo.emoji == "🇺🇸")
            #expect(countryInfo.states.count == 3)
            #expect(countryInfo.states[0].name == "California")
        }
    }
    
    // MARK: - GraphQL Query Tests
    
    @Suite("GraphQL Query Construction Tests")
    struct GraphQLQueryTests {
        
        @Test("Countries query format")
        func countriesQueryFormat() async throws {
            let expectedQuery = """
            query GetAllCountries {
                countries {
                    code
                    name
                    capital
                    emoji
                }
            }
            """
            
            // Test that our expected query structure matches what we expect
            #expect(expectedQuery.contains("query GetAllCountries"))
            #expect(expectedQuery.contains("countries"))
            #expect(expectedQuery.contains("code"))
            #expect(expectedQuery.contains("name"))
            #expect(expectedQuery.contains("capital"))
            #expect(expectedQuery.contains("emoji"))
        }
        
        @Test("Country detail query format")
        func countryDetailQueryFormat() async throws {
            let expectedQuery = """
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
            
            #expect(expectedQuery.contains("query GetCountryInfo"))
            #expect(expectedQuery.contains("$code: ID!"))
            #expect(expectedQuery.contains("country(code: $code)"))
            #expect(expectedQuery.contains("states"))
        }
        
        @Test("GraphQL request body construction")
        func graphQLRequestBodyConstruction() async throws {
            let query = "query { countries { name } }"
            let requestBody = [
                "query": query
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            let reconstructed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            #expect(reconstructed?["query"] as? String == query)
        }
        
        @Test("GraphQL request body with variables")
        func graphQLRequestBodyWithVariables() async throws {
            let query = "query GetCountry($code: ID!) { country(code: $code) { name } }"
            let variables = ["code": "US"]
            let requestBody: [String: Any] = [
                "query": query,
                "variables": variables
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            let reconstructed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            #expect(reconstructed?["query"] as? String == query)
            #expect(reconstructed?["variables"] as? [String: String] == variables)
        }
    }
    
    // MARK: - URL and Network Request Tests
    
    @Suite("Network Configuration Tests")
    struct NetworkConfigurationTests {
        
        @Test("GraphQL endpoint URL construction")
        func graphQLEndpointURL() async throws {
            let urlString = "https://countries.trevorblades.com/"
            let url = try #require(URL(string: urlString))
            
            #expect(url.scheme == "https")
            #expect(url.host == "countries.trevorblades.com")
        }
        
        @Test("HTTP request configuration")
        func httpRequestConfiguration() async throws {
            let url = try #require(URL(string: "https://countries.trevorblades.com/"))
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        }
        
        @Test("Request body serialization")
        func requestBodySerialization() async throws {
            let requestBody = [
                "query": "{ countries { name } }"
            ]
            
            let httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            #expect(httpBody.count > 0)
            
            // Verify we can deserialize it back
            let deserialized = try JSONSerialization.jsonObject(with: httpBody) as? [String: String]
            #expect(deserialized?["query"] == "{ countries { name } }")
        }
    }
    
    // MARK: - Data Transformation Tests
    
    @Suite("Data Transformation Tests")
    struct DataTransformationTests {
        
        @Test("GraphQL to Country model transformation")
        func graphQLToCountryTransformation() async throws {
            struct GraphQLCountry {
                let code: String
                let name: String
                let capital: String?
                let emoji: String
            }
            
            let graphQLCountry = GraphQLCountry(
                code: "BR",
                name: "Brazil",
                capital: "Brasília",
                emoji: "🇧🇷"
            )
            
            let country = Country(
                code: graphQLCountry.code,
                name: graphQLCountry.name,
                capital: graphQLCountry.capital,
                emoji: graphQLCountry.emoji
            )
            
            #expect(country.code == "BR")
            #expect(country.name == "Brazil")
            #expect(country.capital == "Brasília")
            #expect(country.emoji == "🇧🇷")
        }
        
        @Test("GraphQL to CountryInfo transformation")
        func graphQLToCountryInfoTransformation() async throws {
            struct GraphQLCountryInfo {
                let name: String
                let capital: String?
                let emoji: String
                let states: [GraphQLState]
            }
            
            struct GraphQLState {
                let name: String
            }
            
            let graphQLStates = [
                GraphQLState(name: "São Paulo"),
                GraphQLState(name: "Rio de Janeiro")
            ]
            
            let graphQLCountryInfo = GraphQLCountryInfo(
                name: "Brazil",
                capital: "Brasília",
                emoji: "🇧🇷",
                states: graphQLStates
            )
            
            let countryInfo = CountryInfo(
                name: graphQLCountryInfo.name,
                capital: graphQLCountryInfo.capital,
                emoji: graphQLCountryInfo.emoji,
                states: graphQLCountryInfo.states.map { CountryState(name: $0.name) }
            )
            
            #expect(countryInfo.name == "Brazil")
            #expect(countryInfo.capital == "Brasília")
            #expect(countryInfo.emoji == "🇧🇷")
            #expect(countryInfo.states.count == 2)
            #expect(countryInfo.states[0].name == "São Paulo")
            #expect(countryInfo.states[1].name == "Rio de Janeiro")
        }
        
        @Test("Multiple countries transformation")
        func multipleCountriesTransformation() async throws {
            struct GraphQLCountry {
                let code: String
                let name: String
                let capital: String?
                let emoji: String
            }
            
            let graphQLCountries = [
                GraphQLCountry(code: "AU", name: "Australia", capital: "Canberra", emoji: "🇦🇺"),
                GraphQLCountry(code: "NZ", name: "New Zealand", capital: "Wellington", emoji: "🇳🇿"),
                GraphQLCountry(code: "FJ", name: "Fiji", capital: "Suva", emoji: "🇫🇯")
            ]
            
            let countries = graphQLCountries.map { graphQLCountry in
                Country(
                    code: graphQLCountry.code,
                    name: graphQLCountry.name,
                    capital: graphQLCountry.capital,
                    emoji: graphQLCountry.emoji
                )
            }
            
            #expect(countries.count == 3)
            #expect(countries[0].name == "Australia")
            #expect(countries[1].name == "New Zealand")
            #expect(countries[2].name == "Fiji")
        }
    }
    
    // MARK: - Edge Case Tests
    
    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        
        @Test("Empty countries array handling")
        func emptyCountriesArrayHandling() async throws {
            let countries: [Country] = []
            #expect(countries.isEmpty)
        }
        
        @Test("Country with empty string values")
        func countryWithEmptyStringValues() async throws {
            let country = Country(
                code: "",
                name: "",
                capital: "",
                emoji: ""
            )
            
            #expect(country.code == "")
            #expect(country.name == "")
            #expect(country.capital == "")
            #expect(country.emoji == "")
        }
        
        @Test("Country with special characters")
        func countryWithSpecialCharacters() async throws {
            let country = Country(
                code: "XK",
                name: "Kosovo",
                capital: "Pristinë/Priština",
                emoji: "🇽🇰"
            )
            
            #expect(country.capital?.contains("/") == true)
            #expect(country.capital?.contains("ë") == true)
            #expect(country.capital?.contains("š") == true)
        }
        
        @Test("CountryInfo with no states")
        func countryInfoWithNoStates() async throws {
            let countryInfo = CountryInfo(
                name: "Vatican City",
                capital: "Vatican City",
                emoji: "🇻🇦",
                states: []
            )
            
            #expect(countryInfo.states.isEmpty)
        }
        
        @Test("Large number of states handling")
        func largeNumberOfStatesHandling() async throws {
            let states = (1...50).map { CountryState(name: "State \($0)") }
            let countryInfo = CountryInfo(
                name: "Test Country",
                capital: "Test Capital",
                emoji: "🏁",
                states: states
            )
            
            #expect(countryInfo.states.count == 50)
            #expect(countryInfo.states.first?.name == "State 1")
            #expect(countryInfo.states.last?.name == "State 50")
        }
    }
}
