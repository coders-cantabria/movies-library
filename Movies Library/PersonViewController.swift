//
//  PersonViewController.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 28/5/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var biographyText: UILabel!
    @IBOutlet weak var bornText: UILabel!
    @IBOutlet weak var moviesScrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let s = Settings()
        
        self.title = person.name
        self.profileImage.downloadedFrom(url: URL(string: person.profilePath)!)
        
        self.loadPersonDetails(settings: s)
        //self.loadPersonMovies(settings: s)
    }
    
    func loadPersonDetails(settings: Settings) {
        let url = URL(string: "https://api.themoviedb.org/3/person/\(person.id)?api_key=\(settings.app_id)&language=en-US")
        
        let task = URLSession.shared.dataTask(with: url!) {data,response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let personDetails = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            DispatchQueue.main.async {
                self.biographyText.text = personDetails["biography"] as? String
                self.bornText.text = personDetails["birthday"] as? String
            }
        }
        
        task.resume()

    }
}
