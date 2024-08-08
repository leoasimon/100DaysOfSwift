//
//  ViewController.swift
//  Project13
//
//  Created by Leo on 2024-07-01.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    @IBOutlet weak var filterSelectionButton: UIButton!
    
    var context: CIContext!
    var currentFilter: CIFilter!
    
    var currentImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        imageView.alpha = 0
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        filterSelectionButton.setTitle(getFilterDisplayName(for: "CISepiaTone"), for: .normal)
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Change filter", message: "Choose the filter you want to apply", preferredStyle: .actionSheet)
        let filters = ["CIBumpDistortion", "CIGaussianBlur", "CIPixellate", "CISepiaTone", "CITwirlDistortion", "CIUnsharpMask", "CIVignette"]
        
        for filter in filters {
            ac.addAction(UIAlertAction(title: getFilterDisplayName(for: filter) ?? "Unknown Filter", style: .default, handler: {[weak self] _ in self?.setFilter(with: filter)}))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func getFilterDisplayName(for filterName: String) -> String? {
        let prefix = "CI"
        
        if !filterName.hasPrefix(prefix) { return nil }
        
        let withoutPrefix = String(filterName.dropFirst(prefix.count))
        return camelCaseToWords(withoutPrefix)
    }
    
    func camelCaseToWords(_ camelCaseString: String) -> String {
        let pattern = "([a-z])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: camelCaseString.utf16.count)
        let modifiedString = regex.stringByReplacingMatches(in: camelCaseString, options: [], range: range, withTemplate: "$1 $2")
        
        return modifiedString
    }
    
    func setFilter(with name: String) {
        guard let filter = CIFilter(name: name) else {
            print("No filter found with name '\(name)'")
            return
        }
        
        currentFilter = filter
        filterSelectionButton.setTitle(getFilterDisplayName(for: name), for: .normal)
        
        guard currentImage != nil else { return }
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "No image to save", message: "you first need to select an image before trying to save it", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }

        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
            
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                [weak self] in self?.imageView.alpha = 1
            }, completion: nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
}
