//
//  MovieViewController.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 10/6/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    var movie: Movie!
    
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var picturesScroll: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var plotText: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let s = Settings()
        
        var releaseYear = 0
        let calendar = Calendar.current
        releaseYear = calendar.component(.year, from: movie.releaseDate)

        let titleYear = movie.title + " (" + String(releaseYear) + ")"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        titleLabel.text = titleYear
        genresLabel.text = movie.genres
        releaseDateLabel.text = "Release Date: \n" + dateFormatter.string(from: movie.releaseDate)
        ratingLabel.text = String(movie.averageRate) + "/10"
        posterImage.downloadedFrom(url: URL(string: movie.posterPath)!)
        
        self.loadMovieDetails(settings: s)
        self.loadMoviePictures(settings: s)
    }
    
    func loadMovieDetails(settings: Settings) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movie.id)?api_key=\(settings.app_id)&language=en-US")
        
        let task = URLSession.shared.dataTask(with: url!) {data,response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let movieDetails = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            DispatchQueue.main.async {
                self.runtimeLabel.text = String(movieDetails["runtime"] as! Int) + " min"
                self.plotText.text = movieDetails["overview"] as? String
            }
        }
        
        task.resume()
    }
    
    func loadMoviePictures(settings: Settings) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movie.id.string(fractionDigits: 0))/images?api_key=\(settings.app_id)&language=en-US&include_image_language=en,null")
        
        let task = URLSession.shared.dataTask(with: url!) {data,response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            var moviePictures = json["backdrops"] as! Array<AnyObject>
            moviePictures.append(contentsOf: json["posters"] as! Array<AnyObject>)
            
            DispatchQueue.main.async {
                self.picturesScroll.frame = self.scrollContainerView.frame
                
                for i in 0..<moviePictures.count {
                    let moviePic = moviePictures[i]
                    let imageView = UIImageView()
                    let imageUrl = "https://image.tmdb.org/t/p/h632\(moviePic["file_path"] as! String)"
                    imageView.downloadedFrom(url: URL(string: imageUrl)!)
                    imageView.contentMode = UIViewContentMode.scaleAspectFill
                    let xPosition = self.picturesScroll.frame.width * CGFloat(i)
                    imageView.frame = CGRect(x: xPosition, y: 0, width: self.picturesScroll.frame.width, height: self.picturesScroll.frame.height)
                    
                    self.picturesScroll.contentSize.width = self.picturesScroll.frame.width * CGFloat(i + 1)
                    self.picturesScroll.addSubview(imageView)
                }
            }
        }
        
        task.resume()
    }
}
