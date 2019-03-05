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



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func guardar(segue: UIStoryboardSegue) {
        print("Guardado")
    }

    // Funcion prepare para controlar los datos antes de la navegacion
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Variable destino para tener acceso a las variables de destino
        let destino = segue.destination as? ViewControllerCorrer

        // Identifico los identifiers de los shows para acceder a las etiquetas de destino y titulos del View
        if segue.identifier == "Correr" {

            destino?.navigationItem.title = "Actividad Correr"
            destino?.act = "Correr"

        } else if segue.identifier == "identifierAndar" {

            destino?.navigationItem.title = "Actividad Andar"
            destino?.act = "Andar"


        } else if segue.identifier == "identifierCiclismo" {

            destino?.navigationItem.title = "Actividad Ciclismo"
            destino?.act = "Ciclismo"


        }

    }


}
