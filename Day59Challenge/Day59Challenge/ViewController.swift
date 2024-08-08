//
//  ViewController.swift
//  Day59Challenge
//
//  Created by Leo on 2024-07-09.
//

import UIKit

class ViewController: UITableViewController {

    var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Country facts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        performSelector(inBackground: #selector(loadData), with: nil)
    }
    
    @objc func loadData() {
        guard let countriesFileUrl = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            print("Unable to locate countries.json")
            return
        }
        
        guard let countriesData = try? Data(contentsOf: countriesFileUrl) else {
            print("Can't load data from countries.json")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let countries = try decoder.decode([Country].self, from: countriesData)
            performSelector(onMainThread: #selector(populateData), with: countries, waitUntilDone: false)
        } catch {
            print("An error occured while decoding the data")
        }
    }
    
    @objc func populateData(countries: [Any]) {
        self.countries = countries as! [Country]
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryListItem", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else {
            print("Unable to instantiate the detail view")
            return
        }
        
        vc.configure(country: countries[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

