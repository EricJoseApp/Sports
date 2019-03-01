//
//  ViewControllerCorrer.swift
//  AppSports
//
//  Created by  on 25/1/19.
//  Copyright © 2019 EricJose. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewControllerCorrer: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
  
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let myString = formatter.string(from: Date()) // string purpose I add here
    // convert your string to date
    let yourDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "dd-MMM-yyyy"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)
    


    //Variables con las que guardamos los datos en Firebase
    var arrayCoordenadas: Array<CLLocationCoordinate2D> = []
    var coordenadas: Array<GeoPoint> = []
    var distancia = ""
    let date = Timestamp()
    var act = ""
    var duracion = ""

    //Etiqueta de acceso al MkmapView
    @IBOutlet weak var etiquetaMap: MKMapView!

    //Variable CllocationManager()
    let locationManager = CLLocationManager()

    //Cronómetro

    var timer = Timer()
    var horas = 0
    var minutos = 0
    var segundos = 0
    var tiempo = ""

    @IBOutlet weak var cronometro: UILabel!

    @IBAction func iniciar(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewControllerCorrer.action), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
        etiquetaMap.showsUserLocation = true
    }

    @IBAction func pausar(_ sender: Any) {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
        etiquetaMap.showsUserLocation = false
    }

    @IBAction func reset(_ sender: Any) {
        cronometro.text = "0"
        segundos = 0
        arrayCoordenadas.removeAll()
    }

    @objc func action() {
        if (segundos >= 60) {
            minutos = minutos + 1
            segundos = 0
        }

        if (minutos >= 60) {
            horas = horas + 1
            minutos = 0
        }

        segundos += 1

        cronometro.text = String(format: "%02d:%02d:%02d", horas, minutos, segundos)
        duracion = String(format: "%02d:%02d:%02d", horas, minutos, segundos)
    }

    //Fin Cronómetro

    //Funcion que calcula la distancia recorrida por el usuario
    func distanciaRecorrida(_ datos: Array<CLLocationCoordinate2D>) -> String {
        
        //Variable para la distancia
        var distance: CLLocationDistance = 0.0
        
       
        for i in 0...datos.count - 1 {
            
            print(i)
            
            if i < datos.count - 2 {
                let location1 = CLLocation(latitude: datos[i].latitude, longitude: datos[i].longitude)
                let location2 = CLLocation(latitude: datos[i + 1].latitude, longitude: datos[i + 1].longitude)
                
                let distancia: CLLocationDistance = location1.distance(from: location2)
                
                distance = distance + distancia
                
            }
            
        }
        
        //conversion a km
        let kilometers = Double(round(distance) / 1000)
        
        //Convierto kilometros (Double) a b (String)
        let b: String = String(kilometers)
        
        return b
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        etiquetaMap.showsUserLocation = true

        etiquetaMap.delegate = self

        if CLLocationManager.locationServicesEnabled() == true {

            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {

                locationManager.requestWhenInUseAuthorization()
            }

            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.activityType = .fitness
            locationManager.startUpdatingLocation()

        } else {
            print("PLease turn on location services or GPS")
        }
        
    }

    // MARK:- CLLocationManager Delegates

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.etiquetaMap.setRegion(region, animated: true)


        //Relleno el array de coordenadas
        arrayCoordenadas.append(locations[0].coordinate)

        //Variable Mkpolyline para pintar la linea
        let annotation2 = MKPolyline(coordinates: arrayCoordenadas, count: arrayCoordenadas.count)

        etiquetaMap.addOverlay(annotation2)

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "guardarCorrer" {
            
            locationManager.stopUpdatingLocation()
            
            let destino = segue.destination as! ViewController;
            
            distancia = distanciaRecorrida(arrayCoordenadas)
            
            //Guardar datos en Firestore Add a new document with a generated ID
            for punto in arrayCoordenadas {
                coordenadas.append(GeoPoint(latitude: punto.latitude, longitude: punto.longitude))
            }

            //Guardar datos en Firestore Add a new document with a generated ID
            var ref: DocumentReference? = nil
            
            
            ref = db.collection("actividades").addDocument(data: [
                "actividad": act,
                "coordenadas": coordenadas,
                "distancia": distancia,
                "duración": duracion,
                "fecha": date,
                ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")

                }
            }
        }
        
        
        
    }


}
