//
//  NetworkMockTests.swift
//  CountriesGraphQLTests
//
//  Created by Angel Docampo on 25/9/25.
//

import Testing
import Foundation
@testable import CountriesGraphQL

@Suite("Network Mocking and Integration Tests")
struct NetworkMockTests {
    
    // MARK: - Mock URLProtocol for testing
    
    class MockURLProtocol: URLProtocol {
        static var mockData: Data?
        static var mockResponse: URLResponse?
        static var mockError: Error?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let error = MockURLProtocol.mockError {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response = MockURLProtocol.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = MockURLProtocol.mockData {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        static func reset() {
            mockData = nil
            mockResponse = nil
            mockError = nil
        }
    }
    
    // MARK: - Network Response Tests
    
    @Suite("GraphQL Response Parsing Tests")
    struct GraphQLResponseParsingTests {
        
        @Test("Successful countries response parsing")
        func successfulCountriesResponseParsing() async throws {
            let mockResponseJSON = """
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
                        },
                        {
                            "code": "MX",
                            "name": "Mexico",
                            "capital": "Mexico City",
                            "emoji": "🇲🇽"
                        }
                    ]
                }
            }
            """
            
            let jsonData = try #require(mockResponseJSON.data(using: .utf8))
            
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
            
            #expect(response.data.countries.count == 3)
            #expect(response.data.countries[0].name == "United States")
            #expect(response.data.countries[1].name == "Canada")
            #expect(response.data.countries[2].name == "Mexico")
            
            // Test transformation to Country model
            let countries = response.data.countries.map { graphQLCountry in
                Country(
                    code: graphQLCountry.code,
                    name: graphQLCountry.name,
                    capital: graphQLCountry.capital,
                    emoji: graphQLCountry.emoji
                )
            }
            
            #expect(countries.count == 3)
            #expect(countries[0].code == "US")
            #expect(countries[1].capital == "Ottawa")
            #expect(countries[2].emoji == "🇲🇽")
        }
        
        @Test("Successful country detail response parsing")
        func successfulCountryDetailResponseParsing() async throws {
            let mockResponseJSON = """
            {
                "data": {
                    "country": {
                        "name": "United States",
                        "capital": "Washington D.C.",
                        "emoji": "🇺🇸",
                        "states": [
                            {"name": "Alabama"},
                            {"name": "Alaska"},
                            {"name": "Arizona"},
                            {"name": "California"},
                            {"name": "New York"}
                        ]
                    }
                }
            }
            """
            
            let jsonData = try #require(mockResponseJSON.data(using: .utf8))
            
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
            let graphQLCountryInfo = try #require(response.data.country)
            
            #expect(graphQLCountryInfo.name == "United States")
            #expect(graphQLCountryInfo.capital == "Washington D.C.")
            #expect(graphQLCountryInfo.emoji == "🇺🇸")
            #expect(graphQLCountryInfo.states.count == 5)
            
            // Test transformation to CountryInfo model
            let countryInfo = CountryInfo(
                name: graphQLCountryInfo.name,
                capital: graphQLCountryInfo.capital,
                emoji: graphQLCountryInfo.emoji,
                states: graphQLCountryInfo.states.map { CountryState(name: $0.name) }
            )
            
            #expect(countryInfo.states.count == 5)
            #expect(countryInfo.states[0].name == "Alabama")
            #expect(countryInfo.states[4].name == "New York")
        }
        
        @Test("Country with no states response parsing")
        func countryWithNoStatesResponseParsing() async throws {
            let mockResponseJSON = """
            {
                "data": {
                    "country": {
                        "name": "Monaco",
                        "capital": "Monaco",
                        "emoji": "🇲🇨",
                        "states": []
                    }
                }
            }
            """
            
            let jsonData = try #require(mockResponseJSON.data(using: .utf8))
            
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
            let graphQLCountryInfo = try #require(response.data.country)
            
            #expect(graphQLCountryInfo.states.isEmpty)
        }
        
        @Test("Null country response parsing")
        func nullCountryResponseParsing() async throws {
            let mockResponseJSON = """
            {
                "data": {
                    "country": null
                }
            }
            """
            
            let jsonData = try #require(mockResponseJSON.data(using: .utf8))
            
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
            
            #expect(response.data.country == nil)
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Suite("Error Handling Tests")
    struct ErrorHandlingTests {
        
        @Test("GraphQL error response parsing")
        func graphQLErrorResponseParsing() async throws {
            let mockErrorResponseJSON = """
            {
                "errors": [
                    {
                        "message": "Cannot query field 'invalidField' on type 'Country'.",
                        "locations": [{"line": 3, "column": 5}],
                        "path": ["countries", 0, "invalidField"]
                    }
                ]
            }
            """
            
            let jsonData = try #require(mockErrorResponseJSON.data(using: .utf8))
            
            struct GraphQLErrorResponse: Codable {
                let errors: [GraphQLError]
            }
            
            struct GraphQLError: Codable {
                let message: String
                let locations: [GraphQLLocation]?
                let path: [GraphQLPathComponent]?
            }
            
            struct GraphQLLocation: Codable {
                let line: Int
                let column: Int
            }
            
            enum GraphQLPathComponent: Codable {
                case string(String)
                case int(Int)
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let stringValue = try? container.decode(String.self) {
                        self = .string(stringValue)
                    } else if let intValue = try? container.decode(Int.self) {
                        self = .int(intValue)
                    } else {
                        throw DecodingError.dataCorrupted(
                            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid path component")
                        )
                    }
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .string(let value):
                        try container.encode(value)
                    case .int(let value):
                        try container.encode(value)
                    }
                }
            }
            
            let errorResponse = try JSONDecoder().decode(GraphQLErrorResponse.self, from: jsonData)
            
            #expect(errorResponse.errors.count == 1)
            #expect(errorResponse.errors[0].message.contains("Cannot query field"))
            #expect(errorResponse.errors[0].locations?.count == 1)
            #expect(errorResponse.errors[0].locations?[0].line == 3)
        }
        
        @Test("Invalid JSON response handling")
        func invalidJSONResponseHandling() async throws {
            let invalidJSON = "{ invalid json }"
            let jsonData = try #require(invalidJSON.data(using: .utf8))
            
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
            
            #expect(throws: DecodingError.self) {
                try JSONDecoder().decode(GraphQLResponse.self, from: jsonData)
            }
        }
        
        @Test("Missing required fields handling")
        func missingRequiredFieldsHandling() async throws {
            let incompleteJSON = """
            {
                "data": {
                    "countries": [
                        {
                            "code": "US",
                            "name": "United States"
                        }
                    ]
                }
            }
            """
            
            let jsonData = try #require(incompleteJSON.data(using: .utf8))
            
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
                let emoji: String // This is required but missing in the JSON
            }
            
            #expect(throws: DecodingError.self) {
                try JSONDecoder().decode(GraphQLResponse.self, from: jsonData)
            }
        }
    }
    
    // MARK: - Performance Tests
    
    @Suite("Performance Tests")
    struct PerformanceTests {
        
        @Test("Large countries list parsing performance")
        func largeCountriesListParsingPerformance() async throws {
            // Generate a large mock response
            let countries = (1...1000).map { index in
                """
                {
                    "code": "C\(String(format: "%03d", index))",
                    "name": "Country \(index)",
                    "capital": "Capital \(index)",
                    "emoji": "🏴"
                }
                """
            }
            
            let mockResponseJSON = """
            {
                "data": {
                    "countries": [\(countries.joined(separator: ","))]
                }
            }
            """
            
            let jsonData = try #require(mockResponseJSON.data(using: .utf8))
            
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
            
            // Measure parsing time
            let startTime = CFAbsoluteTimeGetCurrent()
            let response = try JSONDecoder().decode(GraphQLResponse.self, from: jsonData)
            let parsingTime = CFAbsoluteTimeGetCurrent() - startTime
            
            #expect(response.data.countries.count == 1000)
            #expect(parsingTime < 1.0) // Should parse 1000 countries in less than 1 second
            
            // Measure transformation time
            let transformStartTime = CFAbsoluteTimeGetCurrent()
            let transformedCountries = response.data.countries.map { graphQLCountry in
                Country(
                    code: graphQLCountry.code,
                    name: graphQLCountry.name,
                    capital: graphQLCountry.capital,
                    emoji: graphQLCountry.emoji
                )
            }
            let transformTime = CFAbsoluteTimeGetCurrent() - transformStartTime
            
            #expect(transformedCountries.count == 1000)
            #expect(transformTime < 0.5) // Should transform in less than 0.5 seconds
        }
    }
    
    // MARK: - Integration Test Helpers
    
    @Suite("Test Utilities")
    struct TestUtilities {
        
        @Test("Mock data creation for countries")
        func mockDataCreationForCountries() async throws {
            let mockCountries = [
                Country(code: "US", name: "United States", capital: "Washington D.C.", emoji: "🇺🇸"),
                Country(code: "CA", name: "Canada", capital: "Ottawa", emoji: "🇨🇦"),
                Country(code: "MX", name: "Mexico", capital: "Mexico City", emoji: "🇲🇽")
            ]
            
            #expect(mockCountries.count == 3)
            #expect(mockCountries.allSatisfy { !$0.code.isEmpty })
            #expect(mockCountries.allSatisfy { !$0.name.isEmpty })
            #expect(mockCountries.allSatisfy { !$0.emoji.isEmpty })
        }
        
        @Test("Mock data creation for country info")
        func mockDataCreationForCountryInfo() async throws {
            let mockStates = [
                CountryState(name: "California"),
                CountryState(name: "Texas"),
                CountryState(name: "New York")
            ]
            
            let mockCountryInfo = CountryInfo(
                name: "United States",
                capital: "Washington D.C.",
                emoji: "🇺🇸",
                states: mockStates
            )
            
            #expect(mockCountryInfo.states.count == 3)
            #expect(mockCountryInfo.states.allSatisfy { !$0.name.isEmpty })
        }
    }
}