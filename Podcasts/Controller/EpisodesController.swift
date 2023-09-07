//
//  EpisodesController.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 27.05.23.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    fileprivate let cellId = "cellId"
    var episodes = [Episode]()
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { episodes in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarButtons()
        setupTableView()
    }
    
    //MARK: setup Work
    func setupNavigationBarButtons() {
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.firstIndex(where: {$0.trackName == podcast?.trackName && $0.artistName == podcast?.artistName}) != nil
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        }else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
            ]
        }
        
    }
    
    @objc fileprivate func handleSaveFavorite() {
        guard let podcast = self.podcast else { return }
        
        var listOfPodcats = UserDefaults.standard.savedPodcasts()
        listOfPodcats.append(podcast)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: listOfPodcats)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
    }
    
    func showBadgeHighlight() {
        tabBarController?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }
   
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK: UITableview
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { _, _ in
            let episode = self.episodes[indexPath.item]
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            // download the podcast episode using Alamofire
            APIService.shared.downloadEpisode(episode: episode)
        }
        return [downloadAction]
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.item]
        UIApplication.mainTabbarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes )
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
