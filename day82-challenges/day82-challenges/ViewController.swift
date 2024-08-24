//
//  ViewController.swift
//  day82-challenges
//
//  Created by Leo on 2024-08-24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var square: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        5.times {
            print("Hello!")
        }
        
        var attractionParks = ["DisneyLand", "Europapark", "La St-Pierre"]
        attractionParks.remove(item: "La St-Pierre")
        print(attractionParks)
        
        var grade8Names = ["Oriane", "Louise", "Théo", "Isaac", "Leny", "Théo"]
        grade8Names.remove(item: "Théo")
        print(grade8Names)
    }
    @IBAction func bounce3s(_ sender: Any) {
        square.bounceOut(duration: 3)
    }
    @IBAction func bounce1s(_ sender: Any) {
        square.bounceOut(duration: 1)
    }
    @IBAction func reset(_ sender: Any) {
        square.transform = .identity
    }
}

extension UIView {
    func bounceOut(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: []) {
            [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.001)
        }
    }
}

extension Int {
    func times(_ fn: () -> Void) {
        for _ in 0...self {
            fn()
        }
    }
}

extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        for (i, elem) in self.enumerated() {
            if elem == item {
                self.remove(at: i)
                return ;
            }
        }
    }
}
