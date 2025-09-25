# CountriesGraphQL

A modern SwiftUI application that demonstrates GraphQL integration using Apollo iOS. The app fetches and displays country information from a public GraphQL API, showcasing best practices for iOS development with GraphQL.

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

### Core Functionality
- 🌍 **Browse Countries**: View a comprehensive list of countries worldwide
- 🏛️ **Country Details**: Get detailed information including capitals, states, and flags
- 🔄 **Real-time Data**: Fetch fresh data from GraphQL API
- ⚡ **Modern UI**: Built with SwiftUI for smooth, native performance
- 🎯 **Error Handling**: Robust error handling with user-friendly messages

### Technical Features
- **GraphQL Integration**: Uses Apollo iOS for type-safe GraphQL queries
- **Modern Architecture**: Clean separation of concerns with models, views, and network layer
- **Async/Await**: Modern Swift concurrency for smooth data fetching
- **Comprehensive Testing**: Full test coverage using Swift Testing framework
- **Responsive Design**: Optimized for all iPhone sizes

## Screenshots

> *Add your app screenshots here*

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

```
CountriesGraphQL/
├── App/
│   └── CountriesGraphQLApp.swift    # App entry point
├── Models/
│   └── Country.swift                # Data models
├── Views/
│   ├── ContentView.swift            # Main countries list
│   └── CountryDetailView.swift      # Country detail view
├── Network/
│   └── Apollo.swift                 # GraphQL network layer
└── GraphQL/
    ├── GetAllCountriesQuery.graphql.swift
    ├── GetCountryInfoQuery.graphql.swift
    └── Schema files...
```

## Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## Dependencies

This project uses the following dependencies:

- **Apollo iOS** (1.23.0): GraphQL client for iOS
  - Provides type-safe GraphQL queries and mutations
  - Handles caching and network requests
  - Generates Swift code from GraphQL schema

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/CountriesGraphQL.git
   cd CountriesGraphQL
   ```

2. **Open in Xcode**
   ```bash
   open CountriesGraphQL.xcodeproj
   ```

3. **Install Dependencies**
   - Dependencies are managed through Swift Package Manager
   - Xcode will automatically resolve and install dependencies on first build

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## GraphQL API

This app uses the public Countries GraphQL API:
- **Endpoint**: `https://countries.trevorblades.com/`
- **Documentation**: [https://github.com/trevorblades/countries](https://github.com/trevorblades/countries)

### Available Queries

#### Get All Countries
```graphql
query GetAllCountries {
  countries {
    code
    name
    capital
    emoji
  }
}
```

#### Get Country Details
```graphql
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
```

## Testing

The project includes comprehensive tests using the modern Swift Testing framework:

### Test Coverage
- ✅ **Model Tests**: Country data structure validation
- ✅ **Network Tests**: Apollo client configuration
- ✅ **GraphQL Tests**: Query initialization and validation
- ✅ **Data Model Tests**: GraphQL response parsing
- ✅ **Integration Tests**: End-to-end API testing (optional)
- ✅ **Error Handling**: Edge cases and error scenarios
- ✅ **Performance Tests**: Model creation and query performance

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme CountriesGraphQL -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use Xcode
# Press Cmd + U to run all tests
```

### Test Structure

```swift
@Suite("Countries GraphQL Tests")
struct CountriesGraphQLTests {
    @Suite("Country Model Tests")
    struct CountryModelTests { /* ... */ }
    
    @Suite("Network Configuration Tests") 
    struct NetworkTests { /* ... */ }
    
    @Suite("GraphQL Query Tests")
    struct GraphQLQueryTests { /* ... */ }
    
    // More test suites...
}
```

## Code Generation

GraphQL code generation is handled automatically by Apollo iOS. The generated files include:

- Type-safe query definitions
- Response data structures  
- Schema metadata

To regenerate GraphQL code (if schema changes):

```bash
# Install Apollo CLI if not already installed
npm install -g @apollo/client

# Generate Swift code from GraphQL schema
apollo codegen:generate --target=swift
```

## Project Structure

```
CountriesGraphQL/
├── CountriesGraphQL/               # Main app target
│   ├── App/                       # App configuration
│   ├── Models/                    # Data models
│   ├── Views/                     # SwiftUI views
│   ├── Network/                   # GraphQL network layer
│   └── Generated/                 # Apollo generated files
├── CountriesGraphQLTests/         # Unit tests
├── GraphQL/                       # GraphQL queries and schema
├── Sources/                       # Swift Package sources
└── Package.swift                  # Package configuration
```

## Key Components

### Models
- **Country**: Core data model with properties for code, name, capital, and emoji

### Network Layer
- **Network**: Singleton class managing Apollo client configuration
- **Apollo Client**: Configured with in-memory caching and request interceptors

### Views
- **ContentView**: Main list view displaying all countries
- **CountryDetailView**: Detailed view for individual country information

### GraphQL Queries
- **GetAllCountriesQuery**: Fetches all countries with basic information
- **GetCountryInfoQuery**: Fetches detailed information for a specific country

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Swift coding conventions
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass before submitting PR

## Performance Considerations

- **Caching**: Apollo iOS provides built-in caching for GraphQL responses
- **Memory Management**: Uses Swift's ARC for automatic memory management
- **Network Efficiency**: GraphQL allows fetching only required fields
- **UI Responsiveness**: Async/await ensures UI remains responsive during data fetching

## Troubleshooting

### Common Issues

**Build Errors**
- Ensure Xcode 15.0+ is installed
- Clean build folder (`Cmd + Shift + K`) and rebuild
- Check that all dependencies are properly resolved

**Network Issues**
- Verify internet connection
- Check that the GraphQL endpoint is accessible
- Review Apollo client configuration

**Testing Issues**
- Ensure test target is properly configured
- Check that test dependencies are available
- For integration tests, verify network connectivity

## Future Enhancements

- [ ] Add offline support with CoreData persistence
- [ ] Implement search and filtering functionality
- [ ] Add country comparison features
- [ ] Support for multiple languages
- [ ] Add map integration
- [ ] Implement favorites functionality
- [ ] Add widget support for iOS

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Trevor Blades](https://github.com/trevorblades) for the Countries GraphQL API
- [Apollo GraphQL](https://www.apollographql.com/) for the excellent iOS GraphQL client
- Apple for SwiftUI and modern iOS development frameworks

## Contact

For questions, suggestions, or contributions, please:
- Open an issue on GitHub
- Submit a pull request
- Contact: [your-email@example.com]

---

Built with ❤️ using SwiftUI and GraphQL