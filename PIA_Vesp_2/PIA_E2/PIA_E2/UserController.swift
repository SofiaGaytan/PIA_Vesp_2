//
//  UserController.swift
//  PIA_E2
//
//  Created by iOSLabMini04 on 24/05/22.
//

import Foundation
import SwiftUI
import SideMenu

class UserController: UIViewController, MenuControllerDelegate  {
    
    @IBOutlet weak var matricula: UILabel!
    @IBOutlet weak var tipo: UILabel!
    var id: String = "Invalido"
    var tipoUsuario: String = "Invalido"
    @IBOutlet weak var imagen: UIImageView!
    
    private var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        matricula.text = id
        tipo.text = tipoUsuario
        if(tipoUsuario == "Chofer"){
            let image = UIImage(systemName: "bus.fill")
            imagen.image = image
        }
        let aux = MenuController()
        aux.delegate = self
        menu = SideMenuNavigationController(rootViewController: aux)
        menu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    
    func didSelectMenuItem(named: String) {
        menu?.dismiss(animated: true, completion: {
            if named == "Cerrar Sesión"{
                let storyBoard : UIStoryboard = UIStoryboard(name : "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "Main") as? ViewController{
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }else if named == "Mapa"{
                let storyBoard : UIStoryboard = UIStoryboard(name : "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "MapController") as? MapController{
                    if(self.matricula.text == "00"){
                        newViewController.usuario = .chofer
                    }
                    newViewController.matricula = self.matricula.text!
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }            }
        })
    }
    
    @IBAction func didTapMenuButton(){
         present(menu!, animated: true)
     }}
