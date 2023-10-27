//
//  ListView.swift
//  AirPodsProMotion
//
//  Created by Yoshio on 2020/10/02.
//

import UIKit
import CoreMotion

class TableViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    private lazy var table :UITableView = {
        let table = UITableView(frame: self.view.bounds, style: .plain)
        table.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        table.autoresizingMask = [
          .flexibleWidth,
          .flexibleHeight
        ]
        table.rowHeight = 60
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    private var items: [Int] = []
    
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Log"
        self.tabBarItem.image=UIImage(systemName: "calendar")
        self.tabBarItem.selectedImage = UIImage(systemName: "calendar.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)

        
        tableSetUp()
        
        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        APP.stopDeviceMotionUpdates()
    }

}


extension TableViewController: UITableViewDataSource {
    
    func tableSetUp() {
        table.dataSource = self
        
        Array(20230801...20230830).forEach {
            items.append($0)
        }
        view.addSubview(table)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = String(items[indexPath.row])
        return cell
    }
    
}
