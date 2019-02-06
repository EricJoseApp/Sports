//
//  ViewControllerAndar.swift
//  AppSports
//
//  Created by  on 25/1/19.
//  Copyright © 2019 EricJose. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewControllerAndar: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //Variables con las que guardamos los datos en Firebase
    var arrayCoordenadas = [CLLocationCoordinate2D]()
    var distancia = ""
    var duracionActividad = ""
    var actividad = ""
    var fecha = ""
    
    //Etiqueta acceso a las propiedades de MKMapView
    @IBOutlet weak var etiquetaMap: MKMapView!
    
    
    //Variable CLLLocationManager()
    let locationManager = CLLocationManager()
    
    //Cronómetro
    var time = 0
    var timer = Timer()
    
    
    @IBOutlet weak var cronometro: UILabel!//Label cronometro
    
    @IBAction func iniciar(_ sender: Any) {//Botón Iniciar
        
    
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewControllerAndar.action) , userInfo: nil, repeats: true)
    
    }
    
    @IBAction func reset(_ sender: Any) {
        cronometro.text = "0"
        time = 0
    }
    
    
    @IBAction func pausar(_ sender: Any) {//Botón Pausar
        timer.invalidate()
    }
    
    @objc func action(){
        time += 1
        cronometro.text = String(time)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        
        //Agregar un punto en el mapa
        //let annotation = MKPointAnnotation()
        //annotation.title = "Jose"
        
        //Relleno el array de coordenadas
        arrayCoordenadas.append(locations[0].coordinate)
        
        //Variable Mkpolyline para pintar la linea
        let annotation2 = MKPolyline(coordinates:arrayCoordenadas,count:arrayCoordenadas.count)
        
        etiquetaMap.addOverlay(annotation2)
        
        
        //annotation.coordinate = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //Mediante la etiquetaMap añado la anotacion
        //etiquetaMap.addAnnotation(annotation)
        
        //arrayCoordenadas.append(CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude))
        
        print(locations[0].coordinate.longitude)
        
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
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
