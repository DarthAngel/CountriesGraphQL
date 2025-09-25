// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAllCountriesQuery: GraphQLQuery {
  public static let operationName: String = "GetAllCountries"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetAllCountries { countries { __typename code name capital emoji } }"#
    ))

  public init() {}

  public struct Data: GraphqlAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { GraphqlAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("countries", [Country].self),
    ] }

    public var countries: [Country] { __data["countries"] }

    /// Country
    ///
    /// Parent Type: `Country`
    public struct Country: GraphqlAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { GraphqlAPI.Objects.Country }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("code", GraphqlAPI.ID.self),
        .field("name", String.self),
        .field("capital", String?.self),
        .field("emoji", String.self),
      ] }

      public var code: GraphqlAPI.ID { __data["code"] }
      public var name: String { __data["name"] }
      public var capital: String? { __data["capital"] }
      public var emoji: String { __data["emoji"] }
    }
  }
}
