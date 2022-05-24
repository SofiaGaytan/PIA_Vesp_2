//
//  ViewController.swift
//  PIA_E2
//
//  Created by iOSLabMini04 on 25/03/22.
//

import UIKit

class ViewController: UIViewController  {

    @IBOutlet var TextFieldMatricula: UITextField!
    @IBOutlet var TextFieldContrasena: UITextField!
    @IBOutlet weak var LabelResult: UILabel!
    
    
    var usuarios: [String:String] = ["00":"00000", "01":"12345"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TextFieldContrasena.isSecureTextEntry = true
    }
    
    @IBAction func unwindToInicio(unwindSegue: UIStoryboardSegue){
        
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if (TextFieldMatricula.text == "" || TextFieldContrasena.text == ""){
            let alert = UIAlertController(title: "Datos invalidos", message: "Ingrese todos los datos requeridos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {action in
            }))
            present(alert, animated: true)
        }else{
            if let contrasenia = usuarios[TextFieldMatricula.text!]{
            if(contrasenia == TextFieldContrasena.text){
                let storyBoard : UIStoryboard = UIStoryboard(name : "Main", bundle: nil)
                if let newViewController = storyBoard.instantiateViewController(withIdentifier: "MapController") as? MapController{
                    if(TextFieldMatricula.text == "00"){
                        newViewController.usuario = .chofer
                    }
                    newViewController.matricula = TextFieldMatricula.text!
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            } else{
                TextFieldMatricula.textColor = .red
                TextFieldContrasena.textColor = .red
                let alert = UIAlertController(title: "Datos invalidos", message: "Contraseña incorrecta.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {action in
                    self.TextFieldContrasena.text = ""
                    self.TextFieldMatricula.textColor = .black
                    self.TextFieldContrasena.textColor = .black
                }))
                present(alert, animated: true)
            }
        }else{
            TextFieldMatricula.textColor = .red
            TextFieldContrasena.textColor = .red
            let alert = UIAlertController(title: "Datos invalidos", message: "Matricula no registrada.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {action in
                self.TextFieldContrasena.text = ""
                self.TextFieldMatricula.text = ""
                self.TextFieldMatricula.textColor = .black
                self.TextFieldContrasena.textColor = .black
            }))
            present(alert, animated: true)
        }
        }

    }
    
}

