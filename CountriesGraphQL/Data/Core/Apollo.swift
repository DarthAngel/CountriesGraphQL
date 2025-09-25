//
//  Apollo.swift
//  CountriesGraphQL
//
//  Created by Angel Docampo on 25/9/25.
//

import Foundation
import Apollo
import ApolloAPI

class Network {
    static let shared = Network()
    
    private(set) lazy var apollo: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let client = URLSessionClient()
        let provider = DefaultInterceptorProvider(client: client, store: store)
        
        let url = URL(string: "https://countries.trevorblades.com/")!
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    private init() {}
}
