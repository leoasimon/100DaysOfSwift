//
//  ViewController.swift
//  project27-drawing-with-core-graphics
//
//  Created by Leo on 2024-08-30.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var drawingType = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }
    
    
    @IBAction func redrawTapped(_ sender: Any) {
        drawingType += 1
        
        if drawingType > 7 {
            drawingType = 0
        }
        
        switch drawingType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImageAndText()
        case 6:
            drawStar()
        case 7:
            drawTwin()
        default:
            break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rect)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rect)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func drawCheckboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0..<64 {
                for col in 0..<64 {
                    if (col + row) % 2 == 0 {
                        let rect = CGRect(x: col * 64, y: row * 64, width: 64, height: 64)
                        ctx.cgContext.fill(rect)
                    }
                }
            }
            
            ctx.cgContext.drawPath(using: .fill)
        }
        
        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let rotationAmount = Double.pi / Double(rotations)
            
            for _ in 0..<rotations {
                let rect = CGRect(x: -128, y: -128, width: 256, height: 256)
                ctx.cgContext.rotate(by: rotationAmount)
                ctx.cgContext.addRect(rect)
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.drawPath(using: .stroke)
        }
        
        imageView.image = img
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var length = 256.0
            
            for i in 0..<256 {
                ctx.cgContext.rotate(by: CGFloat.pi / 2)
                
                if i == 0 {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                length *= 0.99
            }
            
            ctx.cgContext.drawPath(using: .stroke)
        }
        
        imageView.image = img
    }
    
    func drawImageAndText() {
        // Create a renderer at the correct size.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            // Define a paragraph style that aligns text to the center.
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            
            // Create an attributes dictionary containing that paragraph style, and also a font.
            let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: pStyle, .font: UIFont.systemFont(ofSize: 36)]
            
            // Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            let text = "The best-laid schemes o'\nmice an' men gang aft agley"
            let s = NSAttributedString(string: text, attributes: attributes)
            s.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 32, dy: 32))
            
            // Load an image from the project and draw it to the context.
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        // Update the image view with the finished result.
        imageView.image = img
    }
    
    func drawStar() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotation = Double.pi / 5
            
            ctx.cgContext.move(to: CGPoint(x: 0, y: -200))
            for i in 0..<10 {
                ctx.cgContext.rotate(by: rotation)
                if i == 0 || i % 2 == 0 {
                    ctx.cgContext.addLine(to: CGPoint(x: 0, y: -64))
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: 0, y: -200))
                }
            }
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    
        imageView.image = img
    }
    
    func drawTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            
            ctx.cgContext.move(to: CGPoint(x: 32, y: 124))
            ctx.cgContext.addLine(to: CGPoint(x: 128, y: 124))
            ctx.cgContext.move(to: CGPoint(x: 80, y: 124))
            ctx.cgContext.addLine(to: CGPoint(x: 80, y: 384))
            
            ctx.cgContext.move(to: CGPoint(x: 160, y: 124))
            ctx.cgContext.addLine(to: CGPoint(x: 184, y: 384))
            ctx.cgContext.addLine(to: CGPoint(x: 208, y: 254))
            ctx.cgContext.addLine(to: CGPoint(x: 232, y: 384))
            ctx.cgContext.addLine(to: CGPoint(x: 256, y: 124))
            
            ctx.cgContext.move(to: CGPoint(x: 288, y: 124))
            ctx.cgContext.addLine(to: CGPoint(x: 288, y: 384))
            
            ctx.cgContext.move(to: CGPoint(x: 320, y: 384))
            ctx.cgContext.addLine(to: CGPoint(x: 320, y: 124))
            ctx.cgContext.addLine(to: CGPoint(x: 448, y: 384))
            ctx.cgContext.addLine(to: CGPoint(x: 448, y: 124))
            
            ctx.cgContext.drawPath(using: .stroke)
        }
        
        imageView.image = img
    }
}

