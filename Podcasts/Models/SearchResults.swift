//
//  SearchResults.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 26.05.23.
//

import UIKit

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
