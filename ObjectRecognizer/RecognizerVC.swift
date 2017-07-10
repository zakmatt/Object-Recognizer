//
//  ViewController.swift
//  ObjectRecognizer
//
//  Created by Admin on 07/07/2017.
//  Copyright © 2017 Mattowy. All rights reserved.
//

import UIKit

class RecognizerVC: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var imageToClassify: UIImageView!
    @IBOutlet weak var classifiedLabel: UILabel!
    
    var model: Inceptionv3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model = Inceptionv3()
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        camera.allowsEditing = false
        present(camera, animated: true)
    }
    
    @IBAction func libraryPressed(_ sender: Any) {
        let library = UIImagePickerController()
        library.delegate = self
        library.sourceType = .photoLibrary
        library.allowsEditing = false
        present(library, animated: true)
    }
}

extension RecognizerVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        classifiedLabel.text = "Analysing an image..."
        guard  let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let recognizedImg = RecognizedImage(image)
        recognizedImg.transformImage()
        imageToClassify.image = recognizedImg.image
        classifiedLabel.text = recognizeLabel(recognizedImg.pixelBuffer)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func recognizeLabel(_ pixelBuffer: CVPixelBuffer) -> String {
        guard let prediction = try? model.prediction(image: pixelBuffer) else {
            return ""
        }
        return "I think this is a \(prediction.classLabel)."
    }
}

