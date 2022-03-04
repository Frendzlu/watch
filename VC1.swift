//
//  VC1.swift
//  watch
//
//  Created by Mateusz Francik on 14/01/2022.
//

import UIKit

class VC1: UIViewController, UITableViewDelegate {
    
    var arr = [["A", "B", "C"]]
    
    @IBOutlet weak var timeTable: UITableView!
    
    override func viewDidLoad() {
        timeTable.delegate = self
        timeTable.dataSource = self
        super.viewDidLoad()
        timeTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetRoundButton: UIButton!
    
    @IBAction func startStopBtnClick(_ sender: UIButton) {
        if ((sender.title(for: .normal))! == "Start") {
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1), for: .normal)
        } else {
            sender.setTitle("Start", for: .normal)
            sender.setTitleColor(UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1), for: .normal)
        }
    }

    @IBAction func resetRoundBtnClick(_ sender: UIButton) {
        if ((sender.title(for: .normal))! == "Wyzeruj") {
            sender.setTitle("Runda", for: .normal)
            sender.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1), for: .normal)
        } else {
            sender.setTitle("Wyzeruj", for: .normal)
            sender.setTitleColor(UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1), for: .normal)
        }
    }
}

extension VC1: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("aAAA")
        let cell = self.timeTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableData
        cell.left.text = self.arr[indexPath.row][0]
        cell.mid.text = self.arr[indexPath.row][1]
        cell.right.text = self.arr[indexPath.row][2]
        print(cell.left.text!)
        cell.left.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        return cell
    }
}

class TableData : UITableViewCell  {
    @IBOutlet weak var left: UILabel!
    @IBOutlet weak var mid: UILabel!
    @IBOutlet weak var right: UILabel!
}
