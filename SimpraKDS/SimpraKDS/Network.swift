//
//  Network.swift
//  SimpraKDS
//
//  Created by EbubekirSezer on 23.06.2022.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()

  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://api-qa.simprapos.com/graphql")!)
}
