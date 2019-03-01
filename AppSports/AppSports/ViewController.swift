//
//  ViewController.swift
//  AppSports
//
//  Created by  on 23/1/19.
//  Copyright © 2019 EricJose. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func guardar(segue: UIStoryboardSegue) {
        print("Guardado")
    }


    // Funcion prepare para hacer controlar los datos antes de la navegacion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //Variable destino para tener acceso a las variables de destino
        let destino = segue.destination as? ViewControllerCorrer

        if segue.identifier == "Correr" {

            destino?.navigationItem.title = "Actividad Correr"
            destino?.act = "correr"

        } else if segue.identifier == "identifierAndar" {
            
            destino?.navigationItem.title = "Actividad Andar"
            destino?.act = "andar"
            
    
        } else if segue.identifier == "identifierCiclismo" {
            
            destino?.navigationItem.title = "Actividad Ciclismo"
            destino?.act = "ciclismo"
            
            
        }

    }


}
