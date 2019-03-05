//
//  TableViewControllerHistActividades.swift
//  AppSports
//
//  Created by  on 30/1/19.
//  Copyright © 2019 EricJose. All rights reserved.
//

import UIKit
import Firebase

class TableViewControllerHistActividades: UITableViewController {

    //Estruct Actividad
    struct Actividad {
        var id: String
        var fecha: String
        var activity: String
        var duracion: String
        var distancia: String
        var coor: Array<GeoPoint> = []
    }

    //Lista de actividades
    var listaActividad: [Actividad] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //Autentificacion para Firebase
        Auth.auth().signInAnonymously() { (user, error) in

            // UID de usuario asignado por Firebase
            let uid = user?.user.uid
            log.debug("Usuario: \(String(describing: uid))")

            db.collection("actividades").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    log.error("Error al recuperar documentos: \(error!)")
                    return
                }

                // Limpiar el array de objetos
                self.listaActividad.removeAll()

                //Recorro las actividades
                for document in documents {

                    // Recuperar los datos de la lista y crear el objeto
                    let datos = document.data()

                    //Variables para crear el objeto
                    let identificador = document.documentID
                    let act = datos["actividad"] as? String ?? "?"
                    let distancia = datos["distancia"] as? String ?? "?"
                    let duracion = datos["duración"] as? String ?? "?"
                    let fecha = datos["fecha"] as? String ?? "?"
                    let cord = datos["coordenadas"] as? Array<GeoPoint>

                    // Creo el objeto
                    let lista: Actividad = Actividad(id: identificador, fecha: fecha, activity: act, duracion: duracion, distancia: distancia, coor: cord!)

                    // Añado a la lista el Objeto
                    self.listaActividad.append(lista)

                }

                // Recargar la tabla
                self.tableView.reloadData()

            }

        }

        //Permite ativar editar las celdas para borrar la actividad
        self.navigationItem.rightBarButtonItem = self.editButtonItem

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return listaActividad.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Variable cell que identifica el identificador del ItemTableViewCell al que se quiere acceder
        let cell = tableView.dequeueReusableCell(withIdentifier: "CeldaItemLista", for: indexPath) as! ItemTableViewCell

        // Accedo y doy valor a las etiquetas (Labels) del ItemTableViewCell
        cell.etiquetaFecha.text = listaActividad[indexPath.row].fecha
        cell.etiquetaDistancia.text = listaActividad[indexPath.row].distancia
        cell.etiquetaDuracion.text = listaActividad[indexPath.row].duracion
        cell.etiquetaActividad.text = listaActividad[indexPath.row].activity

        // Retorno la celda
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */



    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            //Verifico que celda esta seleccionada
            let selectedRow = indexPath.row

            //Accedo a la lista de objetos para obtener el id de ese objeto
            var idBorrar = listaActividad[selectedRow].id

            //Recupero los datos de Firebase
            db.collection("actividades").addSnapshotListener { querySnapshot, error in
                guard var documents = querySnapshot?.documents else {
                    log.error("Error al recuperar documentos: \(error!)")
                    return
                }

                //Recorro la coleccion de actividades obtenidas de la consulta en Firebase
                for document in documents {

                    //Compruebo que la id de la celda es igual que la de la collecion de Firebase
                    if document.documentID == idBorrar {

                        //Accedo al indice de la coleccion que tiene en Firebase
                        let indice = document.index(ofAccessibilityElement: document.data())

                        //Elimino el documento
                        document.reference.delete()

                    }

                }

                // Recargar la tabla
                self.tableView.reloadData()

            }


            // Borrado de la fila del data source
            self.listaActividad.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)




        } /*else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        } */
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Identifico el identificador
        if segue.identifier == "identificadordetalle" {

            // Detecto la celda que se esta editando
            let pathRow = tableView.indexPathForSelectedRow
            let selectedRow = pathRow!.row

            // Variable destino para acceder al ViewController al que se quiere acceder
            let destino = segue.destination as? DetalleActividadViewController

            // Variables de los datos de la lista que coinciden con la celda que se esta editando
            let fech = listaActividad[selectedRow].fecha
            let dist = listaActividad[selectedRow].distancia
            let dur = listaActividad[selectedRow].duracion
            let nameAct = listaActividad[selectedRow].activity
            var co: Array<GeoPoint> = listaActividad[selectedRow].coor

            // Pongo titulo al View
            destino?.title = nameAct

            // Accedo a las etiquetas (Labels) del destino y les doy valor
            destino?.f = fech
            destino?.d = dist
            destino?.nom = nameAct
            destino?.dur = dur
            destino?.coordenadas = co

        }


    }


}
