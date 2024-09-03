//
//  ViewController.swift
//  day90-challenge-meme-generator
//
//  Created by Leo on 2024-09-03.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let picker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.allowsEditing = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createMeme))
    }
    
    @objc func createMeme() {
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let img = info[.editedImage] as? UIImage else { return }
        
        let ac = UIAlertController(title: "Create your meme", message: "Add a label on top of your meme (optional)", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Next", style: .default, handler: { [weak self] _ in
            let topLabel = ac.textFields?[0].text
            
            let ac2 = UIAlertController(title: "Create your meme", message: "Add a label on the bottom of your meme (optional)", preferredStyle: .alert)
            ac2.addTextField()
            ac2.addAction(UIAlertAction(title: "Save", style: .default) {
                [weak self] _ in
                let bottomLabel = ac2.textFields?[0].text
                self?.renderMeme(with: img, topLabel: topLabel, bottomLabel: bottomLabel)
            })
            
            self?.present(ac2, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func renderMeme(with pic: UIImage, topLabel: String?, bottomLabel: String?) {
        var h = pic.size.height
        if topLabel != nil {
            h += 64
        }
        if bottomLabel != nil {
            h += 64
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pic.size.width, height: h))
        
        let img = renderer.image { ctx in
            let y = topLabel == nil ? 0 : 64
            pic.draw(at: CGPoint(x: 0, y: y))
            
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            
            let font = UIFont.systemFont(ofSize: 32)
            
            if topLabel != nil {
                let rect = CGRect(x: 0, y: 0, width: pic.size.width, height: 64)
                ctx.cgContext.addRect(rect)
                let s = NSAttributedString(string: topLabel!, attributes: [.paragraphStyle: pStyle, .font: font])
                s.draw(in: rect.offsetBy(dx: 8, dy: 8))
            }
            
            if bottomLabel != nil {
                let rect = CGRect(x: 0, y: h - 64, width: pic.size.width, height: 64)
                ctx.cgContext.addRect(rect)
                let s = NSAttributedString(string: bottomLabel!, attributes: [.paragraphStyle: pStyle, .font: font])
                s.draw(in: rect.offsetBy(dx: 8, dy: 8))
            }
        }
        
        imageView.image = img
        
        let ac = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        present(ac, animated: true)
    }
}

