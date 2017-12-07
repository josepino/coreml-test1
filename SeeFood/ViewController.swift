//
//  ViewController.swift
//  SeeFood
//
//  Created by Jose Pino on 30/11/17.
//  Copyright © 2017 Jose Pino. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!      // Enlazado a la vista de la cámara
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera        // Contiene el modulo de la camara
        imagePicker.allowsEditing = false               // Para que el usuario edite o no la foto
        
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {    // Cuando ya tenemos la imagen. Dentro de "info" está la imagen que el usuario tomó
        
        // Verificamos que la imagen no es nula
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {    // Le decimos que este dato es una imagen y preguntamos que no este vacio
            imageView.image = userPickedImage
            
            // Convertimos en una imagen "core image" para usar el Vision Framework y el CoreMLConvertimos
            guard let ciimage = CIImage(image: userPickedImage) else { // El guard es para que sea más seguro el código. En teoría no debería suceder.
                fatalError("No se pudo convertir la imagen a CIImage")
                
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { // Si mi modelo es nulo
            fatalError("Falló la carga de cargar el modelo de CoreML")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Falló al procesar el modelo")
            }
        //print (results) // Imprimimos el resultado en la consola
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("laptop") {
                    self.navigationItem.title = "Estoy viendo una computadora!"
                } else {
                    self.navigationItem.title = "No veo ninguna computadora ahí 🤔"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler (ciImage: image)
        
        do {
            try handler.perform([request])

        } catch {
            print(error)
        }
        
        
        
    }
    
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {    // Enlazado al botón de la cámara
        
        present(imagePicker, animated: true, completion:nil)        // Cuando se presiona el boton de la camara, presentamos
        
    }
    
}

