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

    // Clase para pintar
    class MyPointAnnotation: MKPointAnnotation {
        var pinTintColor: UIColor?
    }


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
        etiquetaNombreActividad.text = nom
        etiquetaDuracion.text = dur
        etiquetafecha.text = f

        //Paso los geopoints a arrayCllocation, convertido a este tipo de dato
        for punto in coordenadas {
            arrayCllocation.append(CLLocationCoordinate2D(latitude: punto.latitude, longitude: punto.longitude))
        }

        //Funcion setUp
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



        // Añado co-ordinates para el  poly line
        /*let coords1 = CLLocationCoordinate2D(latitude: 42.846667, longitude: -2.673056) // Vitoria
        let coords2 = CLLocationCoordinate2D(latitude: 40.418889, longitude: -3.691944) // Madrid
        let coords3 = CLLocationCoordinate2D(latitude: 37.383333, longitude: -5.983333) // Sevilla
        
        testcoords = [coords1, coords2, coords3]*/

        dibujar()

        determineCurrentLocation() // updating current location method
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



        // Dibujar las chinchetas
        for each in 0..<testcoords.count {
            let anno = MKPointAnnotation()
            let pinColor = MyPointAnnotation()


            // Calculo el inicio y final de las coordenadas para señailzar inicio y fin de recorrido
            if each == 0 {
                print(each)
                anno.title = "Start"
                pinColor.pinTintColor = .green
                anno.coordinate = testcoords[each]
            }

            if each == testcoords.count - 1 {
                print(each)
                anno.title = "End"
                pinColor.pinTintColor = .red
                anno.coordinate = testcoords[each]
            }

            etiquetaMapView.addAnnotation(anno as MKAnnotation)
            etiquetaMapView.addAnnotation(pinColor as MKAnnotation)

        }
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
