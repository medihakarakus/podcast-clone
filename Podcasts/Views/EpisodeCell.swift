//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Mediha Karakuş on 05.06.23.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    var episode: Episode! {
        didSet {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormater.string(from: episode.pubDate)
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            let url = URL(string: episode.imageUrl ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }

    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var episodeImageView: UIImageView!
    @IBOutlet var pubDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!{
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet var descriptionLabel: UILabel!
    {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
}
