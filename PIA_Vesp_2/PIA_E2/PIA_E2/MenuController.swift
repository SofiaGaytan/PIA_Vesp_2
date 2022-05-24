//
//  MenuController.swift
//  PIA_E2
//
//  Created by iOSLabMini04 on 23/05/22.
//

import UIKit
class MenuController: UITableViewController{
    public var delegate: MenuControllerDelegate?
    var apartados = ["Usuario","Mapa","Cerrar Sesión"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int {
        return apartados.count
    }
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = apartados[indexPath.row]
        return cell
    }
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = apartados[indexPath.row]
        delegate?.didSelectMenuItem(named: selected)
    }
}

protocol MenuControllerDelegate{
    func didSelectMenuItem(named: String)
}
