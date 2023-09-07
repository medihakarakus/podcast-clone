//
//  RSSFeed.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 06.06.23.
//

import FeedKit

extension RSSFeed{
    
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        var episodes = [Episode]()
        items?.forEach({ feedItem in
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }
}
