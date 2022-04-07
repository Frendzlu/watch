//
//  VC1.swift
//  watch
//
//  Created by Mateusz Francik on 14/01/2022.
//

import UIKit

class VC1: UIViewController, UITableViewDelegate {
    
    var arr: [(String, TimeInterval, TimeInterval)] = []
    var slides = Array<Any>()
    var collectiveTime: TimeInterval = 0
    var beginningTime: TimeInterval = 0
    var currentTime: TimeInterval = 0
    var timer: Timer?
    var formatter: DateFormatter
    var currentRound = 1
    var best: (TimeInterval, Int) = (Double.infinity, 0)
    var worst: (TimeInterval, Int)  = (0, 0)
    var currentOffset: Int = 0
    var licznik: TimerSlide?
    var zegarek: ClockSlide?
    var flick: [Int] = []
    
    var timeLabel: UILabel!
    @IBOutlet weak var timeTable: UITableView!
    @IBOutlet weak var pc: UIPageControl!
    @IBOutlet weak var sv: UIScrollView!
    
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
        sv.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        let licznik : TimerSlide = Bundle.main.loadNibNamed("TimerSlide", owner: self, options: nil)?.first as! TimerSlide
        let zegarek : ClockSlide = Bundle.main.loadNibNamed("ClockSlide", owner: self, options: nil)?.first as! ClockSlide
        timeLabel = licznik.timerLabel

        licznik.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        zegarek.frame = CGRect(x: 400, y: 0, width: 400, height: 400)
        self.licznik = licznik
        self.zegarek = zegarek
        sv.addSubview(self.licznik!)
        sv.addSubview(self.zegarek!)
        sv.isPagingEnabled = true
        sv.isScrollEnabled = true
        sv.contentSize = CGSize(width: 800, height: 400)
        pc.numberOfPages = 2
        sv.delegate = self
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(sv.contentOffset.x/400)
        self.currentOffset = Int(sv.contentOffset.x)
        pc.currentPage = Int(pageIndex)
    }
    
    @IBAction func change(_ sender: UIPageControl) {
        scrollViewDidScroll(sv)
        flick.append(sender.currentPage == 0 ? 1 : 0)
        print(flick)
        if (flick.count == 1) {
            self.interval(pgnum: flick[0])
        }
    }
    
    func interval (pgnum: Int) {
        var x = CGFloat(pgnum)*400
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {(timer: Timer) -> Void in
            //print(self.currentOffset, x)
            if (CGFloat(self.currentOffset) != x) {
                if (CGFloat(self.currentOffset) < x) {
                    self.currentOffset += 4
                } else {
                    self.currentOffset -= 4
                }
                self.sv.contentOffset = CGPoint(x: self.currentOffset, y: 0)
            } else if (self.flick.count > 1) {
                self.scrollViewDidScroll(self.sv)
                self.flick.removeFirst()
                x = CGFloat(self.flick[0]*400)
            } else {
                self.scrollViewDidScroll(self.sv)
                self.flick.removeFirst()
                timer.invalidate()
            }
        })
    }
    func reset() {
        print("Resetting")
        self.currentTime = 0
        self.collectiveTime = 0
        self.beginningTime = 0
        self.currentRound = 1
        licznik?.timerLabel.text = "00:00:00,000"
        zegarek?.clockTicksTimerLabel.text = "00:00:00,000"
        zegarek?.drawTicks(dateTotal: Date(timeIntervalSince1970: collectiveTime), dateCurr: Date(timeIntervalSince1970: currentTime), rounds: arr.count)
        self.arr = []
        self.timeTable.reloadData()
        print(self.arr)
    }
    
    func markRound() {
        print("Round")
        if (currentTime > worst.0) {
            worst.0 = currentTime
            worst.1 = currentRound
        }
        if (currentTime < best.0) {
            best.0 = currentTime
            best.1 = currentRound
        }
        collectiveTime += currentTime
        currentRound += 1
        beginningTime = Date().timeIntervalSince1970
        currentTime = 0
        arr.insert(("Runda \(currentRound)", currentTime, collectiveTime), at: 0)
        timeTable.reloadData()
    }
    
    func stopClock() {
        print("Stop")
        self.timer?.invalidate()
    }
    
    func startClock() {
        print("Start")
        beginningTime = Date().timeIntervalSince1970
        if (arr.count == 0) {
            arr.insert(("Runda \(currentRound)", currentTime, collectiveTime), at: 0)
        }
        self.timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        let now = Date().timeIntervalSince1970
        currentTime += now - beginningTime
        beginningTime = now
        timeLabel.text = formatter.string(from: Date(timeIntervalSince1970: currentTime))
        arr[0].1 = currentTime
        arr[0].2 = collectiveTime + currentTime
        timeTable.reloadData()
        zegarek?.drawTicks(dateTotal: Date(timeIntervalSince1970: collectiveTime + currentTime), dateCurr: Date(timeIntervalSince1970: currentTime), rounds: arr.count)
        zegarek?.clockTicksTimerLabel.text = formatter.string(from: Date(timeIntervalSince1970: currentTime))
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
        let roundNumber = self.arr[indexPath.row].0
        if (roundNumber == "Runda " + String(best.1)) {
            cell.left.textColor = UIColor.green
            cell.mid.textColor = UIColor.green
            cell.right.textColor = UIColor.green
        } else if (roundNumber == "Runda " + String(worst.1)) {
            cell.left.textColor = UIColor.red
            cell.mid.textColor = UIColor.red
            cell.right.textColor = UIColor.red
        } else {
            cell.left.textColor = UIColor.black
            cell.mid.textColor = UIColor.black
            cell.right.textColor = UIColor.black
        }
        cell.left.text = roundNumber
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
