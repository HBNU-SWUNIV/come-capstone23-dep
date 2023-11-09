import UIKit
import CoreMotion

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    
    var timer: Timer?
    var isThresholdExceeded = false
    let threshold: Double = 0.45
    let durationToLog: TimeInterval = 3.0
    var motionStartTime: Date?
    var currentPitch: Double = 0.0
    var currentRoll: Double = 0.0


    private lazy var table: UITableView = {
        let table = UITableView(frame: self.view.bounds, style: .plain)
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        table.rowHeight = 60
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    struct MotionLog {
        let date: Date
        let pitch: Double
        let roll: Double
        let duration: TimeInterval // 시간 기록을 위한 새 필드 추가
    }

    private var motionLogs: [MotionLog] = []

    let motionManager = CMHeadphoneMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Motion Log"
        self.view.addSubview(table)
        table.reloadData() // 여기서 tableView가 사용 가능해야 함

        startMotionUpdates()
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] motion, error in
                guard let strongSelf = self, let motion = motion else { return }

                strongSelf.currentPitch = abs(motion.attitude.pitch)
                strongSelf.currentRoll = abs(motion.attitude.roll)

                if strongSelf.currentPitch > strongSelf.threshold || strongSelf.currentRoll > strongSelf.threshold {
                    if !strongSelf.isThresholdExceeded {
                        strongSelf.motionStartTime = Date()
                    }
                    strongSelf.isThresholdExceeded = true
                } else if strongSelf.isThresholdExceeded {
                    strongSelf.isThresholdExceeded = false
                    strongSelf.logMotionData()
                }
            }
        } else {
            print("Device Motion is not available.")
        }
    }

    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func resetTimerAndMotionStartTime() {
        timer?.invalidate()
        timer = nil
        motionStartTime = nil
    }

    func logMotionData() {
        guard let motionStartTime = motionStartTime else { return }

        let elapsedTime = Date().timeIntervalSince(motionStartTime)
        if elapsedTime >= 2.0 {
            let log = MotionLog(date: Date(), pitch: currentPitch, roll: currentRoll, duration: elapsedTime)
            motionLogs.insert(log, at: 0)

            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }

        resetTimerAndMotionStartTime()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return motionLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let log = motionLogs[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        
        cell.textLabel?.text = dateFormatter.string(from: log.date)
        
        let minutes = Int(log.duration) / 60
        let seconds = log.duration.truncatingRemainder(dividingBy: 60)
        
        // 소수점 다섯 번째 자리까지만 출력하도록 형식화
        cell.detailTextLabel?.text = String(format: "구부정한 자세로 있었던 시간 : %02d:%05.2f",minutes, seconds)
        
        
        //cell.detailTextLabel?.text = String(format: "Pitch: %.5f, Roll: %.5f duration : %02d:%05.2f",
        //                                    log.pitch,
        //                                    log.roll,
        //                                    minutes, seconds)
        
        return cell
    }

    
}
