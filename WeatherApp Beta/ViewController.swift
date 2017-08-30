//
//  ViewController.swift
//  WeatherApp Beta
//
//  Created by Sylvain BARRIERE on 28/08/2017.
//  Copyright © 2017 Sylvain BARRIERE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLbd: UILabel!
    @IBOutlet weak var conditionLbd: UILabel!
    @IBOutlet weak var degreeLbd: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var degree: Int!
    var condition: String!
    var imgURL: String!
    var city: String!
    
    var exists: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.delegate = self
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=07bc5ff9a2d940398f3110652172808&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    if let current = json["current"] as? [String : AnyObject] {
                        
                        if let temp = current["temp_c"] as? Int {
                            self.degree = temp
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imgURL = "http:\(icon)"
                        }
                    }
                    if let location = json["location"] as? [String : AnyObject] {
                        self.city = location["name"] as! String
                    }
                    
                    if let _ = json["error"] {
                        self.exists = false
                    }
                    DispatchQueue.main.async {
                        if self.exists{
                            self.degreeLbd.isHidden = false
                            self.conditionLbd.isHidden = false
                            self.imgView.isHidden = false
                            self.degreeLbd.text = "\(self.degree.description)°"
                            self.cityLbd.text = self.city
                            self.conditionLbd.text = self.condition
                            self.imgView.downloadImage(from: self.imgURL!)
                        } else {
                            self.degreeLbd.isHidden = true
                            self.conditionLbd.isHidden = true
                            self.imgView.isHidden = true
                            self.cityLbd.text = "No matching city found"
                            self.exists = true
                        }
                    }
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
extension UIImageView {
    
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}
