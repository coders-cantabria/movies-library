//
//  MoviesTableViewController.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 28/5/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieRate: UILabel!
    @IBOutlet weak var movieGenre: UILabel!
    var movie: Movie!
}

class MoviesTableViewController: UITableViewController {
    
    var Movies:Array<Movie> = Array<Movie>()
    var Genres:Array<Genre> = Array<Genre>()
    
    var genre:Genre = Genre()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let s = Settings()
        
        self.getGenres(settings: s)
        if genre.id != 0.0 {
            self.getMovies(genre: genre, settings: s, page: 1)
        } else {
            self.getMovies(settings: s, page: 1)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Movies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = Movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        cell.movieTitle.text = movie.title
        cell.movieImage?.downloadedFrom(url: URL(string: movie.thumbnailPath)!)
        cell.movieRate?.text = String(movie.averageRate)
        
        if movie.genreIds.count > 0 && Genres.count > 0 {
            var genres : [String] = []
            for genreId in movie.genreIds {
                let genre = Genres.first(where: { $0.id == genreId })
                genres.append((genre?.name)!)
            }
            
            movie.genres = genres.joined(separator: ", ")
            cell.movieGenre?.text = genres.joined(separator: ", ")
        }
        
        cell.movie = movie
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = Movies.count - 1
        if indexPath.row == lastElement {
            let page = (Movies.count / 20) + 1
            if genre.id != 0.0 {
                self.getMovies(genre: genre, settings: Settings(), page: Int(page))
            } else {
                self.getMovies(settings: Settings(), page: Int(page))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "movieSegue") {
            let indexPath = tableView.indexPathForSelectedRow!
            let currentCell = tableView.cellForRow(at: indexPath)! as! MovieTableViewCell
            let viewController = segue.destination as! MovieViewController
            viewController.movie = currentCell.movie
        }
    }
    
    func getMovies(genre: Genre, settings: Settings, page: Int) {
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(settings.app_id)&language=en-US&page=\(page)&sort_by=popularity.desc&with_genres=\(String(genre.id))")
        self.getMovies(url: url!, settings: settings, page: page)
    }
    
    func getMovies(settings: Settings, page: Int) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(settings.app_id)&language=en-US&page=\(page)")
        self.getMovies(url: url!, settings: settings, page: page)
    }
    
    func getMovies(url: URL, settings: Settings, page: Int) {
        let task = URLSession.shared.dataTask(with: url) {data,response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let movies = json["results"] as! Array<AnyObject>
            
            for m in movies {
                let movie = Movie()
                
                var posterPath: String = ""
                let path = m["poster_path"]
                
                if path == nil {
                    continue
                } else {
                    posterPath = path as! String
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let releaseDate = dateFormatter.date(from: m["release_date"] as! String)
                
                movie.id = m["id"] as! Double
                movie.title = m["title"] as! String
                movie.overview = m["overview"] as! String
                movie.thumbnailPath = "https://image.tmdb.org/t/p/w185\(posterPath)"
                movie.posterPath = "https://image.tmdb.org/t/p/w500\(posterPath)"
                movie.releaseDate = releaseDate!
                movie.averageRate = m["vote_average"] as! Double
                movie.genreIds = m["genre_ids"] as! [Double]
                
                self.Movies.append(movie)
            }
            
            DispatchQueue.main.async(execute: {
                self.refreshTableView()
            })
        }
        
        task.resume()
    }
    
    func getGenres(settings: Settings) {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en-US&api_key=\(settings.app_id)")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty!")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let genres = json["genres"] as! Array<AnyObject>
            
            for g in genres {
                let genre = Genre()
                
                genre.id = g["id"] as! Double
                genre.name = g["name"] as! String
                
                self.Genres.append(genre)
            }
            
            DispatchQueue.main.async(execute: {
                if self.genre.id != 0 {
                    let genre = self.Genres.first(where: { $0.id == self.genre.id })
                    self.title = genre?.name
                }
            })
        }
        
        task.resume()
    }
    
    func refreshTableView() {
        self.tableView.reloadData()
    }
    
}

class Movie {
    var id: Double = 0
    var title: String = ""
    var posterPath: String = ""
    var thumbnailPath: String = ""
    var releaseDate: Date = Date()
    var overview: String = ""
    var averageRate: Double = 0.0
    var genreIds: [Double] = []
    var genres: String = ""
}
