//
//  DetailViewController.swift
//  Day59Challenge
//
//  Created by Leo on 2024-07-09.
//

import UIKit

class DetailViewController: UIViewController {

    static let identifier = "DetailView"
    
    var country: Country?
    
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var mottoLabal: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let country = country else {
            return
        }

        title = country.name
        navigationItem.largeTitleDisplayMode = .never
        
        capitalLabel.text = country.capital
        languagesLabel.text = country.official_languages.joined(separator: ", ")
        populationLabel.text = String(country.population)
        mottoLabal.text = country.motto
    }
    
    func configure(country: Country) {
        self.country = country
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
