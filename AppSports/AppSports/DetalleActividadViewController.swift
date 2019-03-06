//
//  DetalleActividadViewController.swift
//  AppSports
//
//  Created by  on 20/2/19.
//  Copyright © 2019 EricJose. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class DetalleActividadViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {


    //Acceso al mapView
    @IBOutlet weak var etiquetaMapView: MKMapView!
    

    //Variables de control para el map y polilyne
    var locationManager = CLLocationManager()
    var testcoords: [CLLocationCoordinate2D] = []

    //Acceso a los labels
    @IBOutlet weak var etiquetaNombreActividad: UILabel!
    @IBOutlet weak var etiquetaDuracion: UILabel!
    @IBOutlet weak var etiquetafecha: UILabel!
    @IBOutlet weak var etiquetaDistancia: UILabel!

    //Variables donde voy a guardar los datos recibidos de la celda (self delegate)
    var f: String = ""
    var d: String = ""
    var nom: String = ""
    var dur: String = ""
    var coordenadas: Array<GeoPoint> = []

    //Array donde voy a almacenar los geopoints convertidos
    var arrayCllocation: Array<CLLocationCoordinate2D> = []


    override func viewDidLoad() {
        super.viewDidLoad()

        //Doy valor a los labels
        etiquetaDistancia.text = d
        //etiquetaNombreActividad.text = nom
        etiquetaDuracion.text = dur
        etiquetafecha.text = f

        //Paso los geopoints a arrayCllocation, convertido a este tipo de dato
        for punto in coordenadas {
            arrayCllocation.append(CLLocationCoordinate2D(latitude: punto.latitude, longitude: punto.longitude))
        }

        // Funcion setUp
        setUp()

    }


    //Set up LocationManager y MapView
    func setUp() {

        // location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        // Map view settings
        etiquetaMapView.delegate = self
        etiquetaMapView.mapType = MKMapType.standard
        etiquetaMapView.isZoomEnabled = true
        etiquetaMapView.isScrollEnabled = true
        //etiquetaMapView.center = view.center

        // Recorro el array de Cllocation para añadir sus coodenadas a testcoords
        for c in arrayCllocation {
            testcoords.append(CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude))
        }

        dibujar()

        //determineCurrentLocation() // updating current location method
    }

    // Actualizacion del la localizacion
    func determineCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    // Funcion que dibuja la linea del recorrido en el mapa
    func dibujar() {

        // Dibujar la línea
        let testline = MKPolyline(coordinates: testcoords, count: testcoords.count)
        etiquetaMapView.addOverlay(testline)

        etiquetaMapView.setRegion(MKCoordinateRegion(coordinates:testcoords), animated: true)

        
        // Dibujar las chinchetas
        for each in 0..<testcoords.count {
            let anno = MKPointAnnotation()
            

            // Calculo el inicio y final de las coordenadas para señailzar inicio y fin de recorrido
            if each == 0 {
                anno.title = "Start"
                anno.coordinate = testcoords[each]
            }

            if each == testcoords.count - 1 {
                anno.title = "Finish"
                anno.coordinate = testcoords[each]
            }

            etiquetaMapView.addAnnotation(anno as MKAnnotation)

        }
        
        //self.etiquetaMapView.showAnnotations(etiquetaMapView.annotations, animated: true)
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Recibir las actualizaciones de posición del GPS y centrar el mapa
        let userLocation: CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)) // Nivel de zoom (estaba a 0.1)
        etiquetaMapView.setRegion(region, animated: true)

        //locationManager.stopUpdatingLocation() // Esto para el GPS, no recibimos más actualizaciones
    }




    //Añadiendo polilyne
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        fatalError("Something wrong...")
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

// Ref:https://gist.github.com/robmooney/923301
extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D]) {
        var minLat: CLLocationDegrees = 90.0
        var maxLat: CLLocationDegrees = -90.0
        var minLon: CLLocationDegrees = 180.0
        var maxLon: CLLocationDegrees = -180.0
        
        for coordinate in coordinates {
            let lat = Double(coordinate.latitude)
            let long = Double(coordinate.longitude)
            if lat < minLat {
                minLat = lat
            }
            if long < minLon {
                minLon = long
            }
            if lat > maxLat {
                maxLat = lat
            }
            if long > maxLon {
                maxLon = long
            }
        }
        
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*2.0, longitudeDelta: (maxLon - minLon)*2.0)
        let center = CLLocationCoordinate2DMake(maxLat - span.latitudeDelta / 4, maxLon - span.longitudeDelta / 4)
        self.init(center: center, span: span)
    }
}
