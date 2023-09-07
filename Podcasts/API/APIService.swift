//
//  APIService.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 25.05.23.
//

import UIKit
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    let baseItunesSearchURL = "https://itunes.apple.com/search"
    //singleton
    static let shared = APIService()
    
    func downloadEpisode(episode: Episode) {
        print("Downloading episode using Alamofire at stream url:", episode.streamUrl)
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        AF.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            // I want to notify DownloadsController about my download progress somehow?
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
            }.response { (resp) in
                print(resp.fileURL?.absoluteString ?? "")
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.fileURL?.absoluteString ?? "", episode.title)
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete , userInfo: nil)
                
                // I want to update UserDefaults downloaded episodes with this temp file somehow
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author }) else { return }
                downloadedEpisodes[index].fileUrl = resp.fileURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
                } catch let err {
                    print("Failed to encode downloaded episodes with file url update:", err)
                }
        }
    }
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping([Episode]) -> ()) {
        guard let url = URL(string: feedUrl) else { return }
        
        let parser = FeedParser(URL: url)
        parser.parseAsync { result in
            switch result {
            case .success(let feed):
                switch feed {
                case let .rss(feed):
                    let episodes = feed.toEpisodes()
                    completionHandler(episodes)
                    break
                default:
                    print("Found a feed")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchPodcasts(_ searchText: String, completionHandler: @escaping([Podcast]) -> ()) {
        let parameters = ["term": searchText, "media": "podcast"]
        
        AF.request(baseItunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { dataResponse in
            if let err = dataResponse.error {
                print("Failed to contact yahoo", err)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResult.results)
            } catch let decodeErr{
                print("Failed to decode: ",decodeErr)
            }
        }
    }
}
