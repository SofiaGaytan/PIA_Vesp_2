//
//  MapController.swift
//  PIA_E2
//
//  Created by iOSLabMini04 on 22/04/22.
//

import SideMenu
import UIKit
import MapKit
import CoreLocation
import SwiftUI

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MenuControllerDelegate  {
    
    func didSelectMenuItem(named: String) {
        menu?.dismiss(animated: true, completion: {
            if named == "Cerrar Sesión"{
                let storyBoard : UIStoryboard = UIStoryboard(name : "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "Main") as? ViewController{
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }else if named == "Usuario"{
                let storyBoard : UIStoryboard = UIStoryboard(name : "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "Usuario") as? UserController{
                    if(self.usuario == .chofer){
                        newViewController.tipoUsuario = "Chofer"
                    }else{
                        newViewController.tipoUsuario = "Pasajero"
                    }
                    newViewController.id = self.matricula
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
        })
    }
    
    @IBOutlet var mapa: MKMapView!
    @IBOutlet var paradaCercana: UILabel!
    @IBOutlet weak var paradaCercanaLabel: UILabel!
    @IBOutlet weak var cambio: UIButton!
    var parada: Bool = true
    var direccionActual = CLLocationManager()
    let primeraParada = MKPointAnnotation()
    let segundaParada = MKPointAnnotation()
    let terceraParada = MKPointAnnotation()
    let cuartaParada = MKPointAnnotation()
    let quintaParada = MKPointAnnotation()
    let sextaParada = MKPointAnnotation()
    let septimaParada = MKPointAnnotation()
    let tigreBus = MKPointAnnotation()
    
    private var menu: SideMenuNavigationController?
    
    struct Posicion: Decodable{
        var latitud: Double
        var longitud: Double
        var estado: Bool
    }
    
    enum TipoUsuario{
        case pasajero, chofer
    }
    
    var usuario: TipoUsuario = .pasajero
    var matricula: String = "Invalido"
    
    @IBOutlet weak var cargarPosicion: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let aux = MenuController()
        aux.delegate = self
        menu = SideMenuNavigationController(rootViewController: aux)
        menu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        // Region: Ciudad Universitaria
        let centro = MKPointAnnotation()
        centro.coordinate = CLLocationCoordinate2D(latitude: 25.7264094, longitude: -100.3134514)
        let ciudadUniversitaria = MKCoordinateRegion(center: centro.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapa.setRegion(ciudadUniversitaria, animated: true)
        
        //Paradas: Primera Parada
        primeraParada.title = "Facultad de Ciencias Biologicas"
        primeraParada.coordinate = CLLocationCoordinate2D(latitude: 25.7237223, longitude: -100.316239)
        mapa.addAnnotation(primeraParada)
        
        //Paradas: Segunda Parada
        segundaParada.title = "Facultad de Ingeniería Civil"
        segundaParada.coordinate = CLLocationCoordinate2D(latitude: 25.7238952, longitude: -100.3136897)
        mapa.addAnnotation(segundaParada)
        
       /* //Paradas: Tercera Parada
        terceraParada.title = "Entrada"
        terceraParada.coordinate = CLLocationCoordinate2D(latitude: 25.7238409, longitude: -100.3100549)
        mapa.addAnnotation(terceraParada)
        
        //Paradas: Cuarta Parada
        cuartaParada.title = "Rectoria"
        cuartaParada.coordinate = CLLocationCoordinate2D(latitude: 25.7242887, longitude: -100.3097919)
        mapa.addAnnotation(cuartaParada)
        
        //Paradas: Quinta Parada
        quintaParada.title = "Facultad de Contaduria Publica y Administración"
        quintaParada.coordinate = CLLocationCoordinate2D(latitude: 25.7281094, longitude: -100.3083007)
        mapa.addAnnotation(quintaParada)
        
        //Paradas: Sexta Parada
        sextaParada.title = "Canchas"
        sextaParada.coordinate = CLLocationCoordinate2D(latitude: 25.7279859, longitude: -100.3154612)
        mapa.addAnnotation(sextaParada)
        
        //Paradas: Septima Parada
        septimaParada.title = "Estadio Raymundo Chico Rivera"
        septimaParada.coordinate = CLLocationCoordinate2D(latitude: 25.727214, longitude: -100.3150376)
        mapa.addAnnotation(septimaParada)*/
        
        // Direccion Actual
        direccionActual.delegate = self
        direccionActual.desiredAccuracy = kCLLocationAccuracyBest
        direccionActual.requestAlwaysAuthorization()
        direccionActual.requestWhenInUseAuthorization()
        direccionActual.startUpdatingLocation()
        
        // TigreBus
        if(usuario == .chofer){
            cargarPosicion.isEnabled = false
            cambio.isHidden = true
        }else{
            self.ubicarTigreBus()
        }
        
        // Ruta
        self.ruta(origen: self.segundaParada.coordinate, destino: self.primeraParada.coordinate)
        /*self.ruta(origen: self.terceraParada.coordinate, destino: self.segundaParada.coordinate)
        self.ruta(origen: self.cuartaParada.coordinate, destino: self.terceraParada.coordinate)
        self.ruta(origen: self.quintaParada.coordinate, destino: self.cuartaParada.coordinate)
        self.ruta(origen: self.sextaParada.coordinate, destino: self.quintaParada.coordinate)
        self.ruta(origen: self.septimaParada.coordinate, destino: self.sextaParada.coordinate)
        self.ruta(origen: self.primeraParada.coordinate, destino: self.septimaParada.coordinate)*/
        
        mapa.showsUserLocation = true
        mapa.delegate = self
    }
    
   @IBAction func didTapMenuButton(){
        present(menu!, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(parada){
        let p1 = CLLocation(latitude: primeraParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let p2 = CLLocation(latitude: segundaParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let toPrimeraParada = direccionActual.location?.distance(from: p1)
        let toSegundaParada = direccionActual.location?.distance(from: p2)
        var minDistance = Double(toPrimeraParada!.magnitude)
        var parada = primeraParada.title
        if Double(toSegundaParada!.magnitude) < minDistance {
            minDistance = Double(toSegundaParada!.magnitude)
            parada = segundaParada.title
        }
        paradaCercana.text = parada
        }
        if(usuario == .chofer){
            enviarPosicion()
        }
    }
    
    func calcularCercana(){
        if(!parada){
        let tb = CLLocation(latitude: tigreBus.coordinate.latitude, longitude: tigreBus.coordinate.longitude)
        let p1 = CLLocation(latitude: primeraParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let p2 = CLLocation(latitude: segundaParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let toPrimeraParada = tb.distance(from: tb)
        let toSegundaParada = p2.distance(from: tb)
        var minDistance = Double(toPrimeraParada.magnitude)
        var parada = primeraParada.title
        if Double(toSegundaParada.magnitude) < minDistance {
            minDistance = Double(toSegundaParada.magnitude)
            parada = segundaParada.title
        }
        paradaCercana.text = parada
        }
    }
    
    func calcularParada(){
        if let location = direccionActual.location as? CLLocation{
        if(parada){
        let p1 = CLLocation(latitude: primeraParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let p2 = CLLocation(latitude: segundaParada.coordinate.latitude, longitude: segundaParada.coordinate.longitude)
        let toPrimeraParada = direccionActual.location?.distance(from: p1)
        let toSegundaParada = direccionActual.location?.distance(from: p2)
        var minDistance = Double(toPrimeraParada!.magnitude)
        var parada = primeraParada.title
        if Double(toSegundaParada!.magnitude) < minDistance {
            minDistance = Double(toSegundaParada!.magnitude)
            parada = segundaParada.title
        }
        paradaCercana.text = parada
        }
        }else{
            paradaCercana.text = "Ubicación Invalida"
        }
    }
    
    @IBAction func cambioBoton(){
       let aux: UIImage!
        if(parada){
           aux = UIImage(systemName: "arrow.left.circle.fill")
            parada = false
            paradaCercanaLabel.text = "Tigre Bus en:"
            calcularCercana()
       }else{
           aux = UIImage(systemName: "arrow.right.circle.fill")
           parada = true
           paradaCercanaLabel.text = "Parada Cercana:"
           calcularParada()
       }
       cambio.setImage(aux, for: .normal)
   }
    func ruta(origen: CLLocationCoordinate2D, destino: CLLocationCoordinate2D){
        //let ubicacion =  (direccionActual.location?.coordinate)!
        
        let actualPlaceMark = MKPlacemark(coordinate: origen)
        let destinoPlaceMark = MKPlacemark(coordinate: destino)
        
        let actualItem = MKMapItem(placemark: actualPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        let destinoRequest = MKDirections.Request()
        destinoRequest.source = actualItem
        destinoRequest.destination = destinoItem
        destinoRequest.transportType = .automobile
        
        let direcciones = MKDirections(request: destinoRequest)
        direcciones.calculate{ (response, error) in
            guard let reponse = response else {
                if let error = error {
                    print("Ha ocurrido un error.")
                }
                return
            }
            let route = response!.routes[0]
        self.mapa.addOverlay(route.polyline)
            self.mapa.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline )
        render.strokeColor = .blue
        return render
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)-> MKAnnotationView?{
        guard !(annotation is MKUserLocation || annotation.title != "Tigre Bus")else{
            return nil
        }
        var annotationView = mapa.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        }else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "tigrebus")
         return annotationView
    }
    
    private var tigreBusPosicion: Posicion?
    
    @IBAction func ubicarTigreBus(){
        guard let url = URL(string: "https://tigrebuse2-default-rtdb.firebaseio.com/tigrebus.json") else{
            return
        }
        URLSession.shared.dataTask(with: url){ data,response, error in
            guard let data = data else{
                return
            }
            if let decodedData = try? JSONDecoder().decode(Posicion.self, from: data){
                DispatchQueue.main.async {
                    self.tigreBusPosicion = decodedData
                    if let latitude = self.tigreBusPosicion?.latitud as? Double{
                        if let longitude = self.tigreBusPosicion?.longitud as? Double{
                            self.tigreBus.title = "Tigre Bus"
                            self.tigreBus.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            self.mapa.addAnnotation(self.tigreBus)
                        }
                    }
                }
            }
        }.resume()
    
    }
    
    func enviarPosicion(){
        guard let url = URL(string: "https://tigrebuse2-default-rtdb.firebaseio.com/tigrebus.json") else{
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body : [String:AnyHashable] = [
            "latitud": direccionActual.location?.coordinate.latitude,
            "longitud": direccionActual.location?.coordinate.longitude,
            "estado": true
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let response = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(response)
            } catch{
                print(error)
            }
        }
        task.resume()
    }
    
}
