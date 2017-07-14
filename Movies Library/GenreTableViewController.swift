//
//  GenresTableViewController.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 28/5/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {
    @IBOutlet weak var genreText: UILabel!
    var genre:Genre!
}

class GenresTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getGenres(settings: Settings())
    }

    var Genres: Array<Genre> = Array<Genre>()

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! GenreTableViewCell
        cell.genre = Genres[indexPath.row]
        cell.genreText?.text = Genres[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "genreSegue") {
            let indexPath = tableView.indexPathForSelectedRow!
            let currentCell = tableView.cellForRow(at: indexPath)! as! GenreTableViewCell
            let viewController = segue.destination as! MoviesTableViewController
            viewController.genre = currentCell.genre
        }
    }
    
    func getGenres(settings: Settings) {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en-US&api_key=\(settings.app_id)")
        
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
            let genres = json["genres"] as! Array<AnyObject>
            
            for g in genres {
                let genre = Genre()
                
                genre.id = g["id"] as! Double
                genre.name = g["name"] as! String
                
                self.Genres.append(genre)
            }
            
            DispatchQueue.main.async(execute: {self.refreshTableView()})
        }
        
        task.resume()
    }
    
    func refreshTableView() {
        self.tableView.reloadData()
    }

}

class Genre {
    var id:Double = 0.0
    var name:String = ""
}
