//
//  VC1.swift
//  watch
//
//  Created by Mateusz Francik on 14/01/2022.
//

import UIKit

class VC1: UIViewController, UITableViewDelegate {
    
    var arr: [(String, TimeInterval, TimeInterval)] = []
    
    var collectiveTime: TimeInterval = 0
    var beginningTime: TimeInterval = 0
    var currentTime: TimeInterval = 0
    var timer: Timer?
    var formatter: DateFormatter
    var currentRound = 1
    var best: TimeInterval = 0
    var worst: TimeInterval = Double.infinity
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTable: UITableView!
    
    required init(coder: NSCoder) {
        formatter = DateFormatter();
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        formatter.setLocalizedDateFormatFromTemplate("HH:mm:ss.SSS")
        super.init(coder: coder)!
    }
    
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
            resetRoundButton.setTitle("Runda", for: .normal)
            resetRoundButton.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1), for: .normal)
            self.startClock()
        } else {
            sender.setTitle("Start", for: .normal)
            sender.setTitleColor(UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1), for: .normal)
            resetRoundButton.setTitle("Wyzeruj", for: .normal)
            resetRoundButton.setTitleColor(UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1), for: .normal)
            self.stopClock()
        }
    }

    @IBAction func resetRoundBtnClick(_ sender: UIButton) {
        if ((sender.title(for: .normal))! == "Wyzeruj") {
            self.reset()
        } else {
            self.markRound()
        }
    }
    
    func reset() {
        print("Resetting")
        self.currentTime = 0
        self.collectiveTime = 0
        self.beginningTime = 0
        self.arr = []
        self.timeTable.reloadData()
        print(self.arr)
    }
    
    func markRound() {
        print("Round")
        if (currentTime > worst) {
            worst = currentRound
        } else if (currentTime < best) {
            best = currentRound
        }
        collectiveTime += currentTime
        arr.append(("Runda \(currentRound)", currentTime, collectiveTime))
        currentRound += 1
        beginningTime = Date().timeIntervalSince1970
        currentTime = 0
        timeTable.reloadData()
    }
    
    func stopClock() {
        print("Stop")
        self.timer?.invalidate()
    }
    
    func startClock() {
        print("Start")
        beginningTime = Date().timeIntervalSince1970
        self.timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        let now = Date().timeIntervalSince1970
        currentTime += now - beginningTime
        beginningTime = now
        timeLabel.text = formatter.string(from: Date(timeIntervalSince1970: currentTime))
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
        let cell = self.timeTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableData
        cell.left.text = self.arr[indexPath.row].0
        cell.mid.text = formatter.string(from: Date(timeIntervalSince1970: self.arr[indexPath.row].1))
        cell.right.text = formatter.string(from: Date(timeIntervalSince1970: self.arr[indexPath.row].2))
        return cell
    }
}

class TableData : UITableViewCell  {
    @IBOutlet weak var left: UILabel!
    @IBOutlet weak var mid: UILabel!
    @IBOutlet weak var right: UILabel!
}
