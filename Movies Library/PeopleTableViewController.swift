//
//  PeopleTableViewController.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 28/5/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personKnownFor: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    var person: Person!
}

class PeopleTableViewController: UITableViewController {
    
    var PeopleData:Array<Person> = Array<Person>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPeople(settings: Settings(), page: 1)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PeopleData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = PeopleData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonTableViewCell
        cell.personName?.text = person.name
        cell.personKnownFor?.text = person.knownFor
        cell.personImage?.downloadedFrom(url: URL(string: person.thumbnailPath)!)
        cell.person = person
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = PeopleData.count - 1
        if indexPath.row == lastElement {
            let page = (PeopleData.count / 20) + 1
            getPeople(settings: Settings(), page: Int(page))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "peopleSegue") {
            let indexPath = tableView.indexPathForSelectedRow!
            let currentCell = tableView.cellForRow(at: indexPath)! as! PersonTableViewCell
            let viewController = segue.destination as! PersonViewController
            viewController.person = currentCell.person
        }
    }
    
    func getPeople(settings: Settings, page: Int) {
        let url = URL(string: "https://api.themoviedb.org/3/person/popular?api_key=\(settings.app_id)&language=en-US&page=\(page)")
        
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
            let people = json["results"] as! Array<AnyObject>
            
            for p in people {
                let person = Person()
                
                var profilePath: String = ""
                let path = p["profile_path"]
                
                if path is NSNull {
                    continue
                } else {
                    profilePath = path as! String
                }

                let firstKnownFor = (p["known_for"] as! Array<AnyObject>)[0]
                let mediaType = firstKnownFor["media_type"] as! String
                var title = ""
                var releaseYear = 0
                if mediaType == "movie" {
                    title = firstKnownFor["title"] as! String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let calendar = Calendar.current
                    let releaseDate = dateFormatter.date(from: firstKnownFor["release_date"] as! String)
                    releaseYear = calendar.component(.year, from: releaseDate!)
                } else {
                    title = firstKnownFor["name"] as! String
                }
                
                person.id = p["id"] as! Double
                person.name = p["name"] as! String
                person.thumbnailPath = "https://image.tmdb.org/t/p/w185\(profilePath)"
                person.profilePath = "https://image.tmdb.org/t/p/h632\(profilePath)"
                person.knownFor = releaseYear != 0 ? "\(title) (\(releaseYear))" : title
                
                self.PeopleData.append(person)
            }
            
            DispatchQueue.main.async(execute: {self.refreshTableView()})
        }
        
        task.resume()
    }
    
    func refreshTableView() {
        self.tableView.reloadData()
    }

}

class Person {
    var id: Double = 0
    var name: String = ""
    var thumbnailPath: String = ""
    var profilePath: String = ""
    var knownFor: String = ""
}
