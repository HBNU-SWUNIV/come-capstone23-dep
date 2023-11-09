import UIKit
import SceneKit
import CoreMotion
import AudioToolbox

class SK3DViewController: UIViewController, CMHeadphoneMotionManagerDelegate {

    //weak var delegate: SK3DViewControllerDelegate?
    var pitch: Double = 0.0
    var roll: Double = 0.0
    var motionManager: CMHeadphoneMotionManager?

    let APP = CMHeadphoneMotionManager()
    var cubeNode: SCNNode!
    var textView2: UITextView!
    
    var isTilted = false
    var tiltStartTime: Date?
    var colorUpdateTimer: Timer?
    let colorUpdateInterval: TimeInterval = 1.0 // 1초마다 업데이트

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.motionManager = CMHeadphoneMotionManager()
        //        startMotionMonitoring()

        self.view.backgroundColor = .systemBackground
        self.title = "3D"
        self.tabBarItem.image = UIImage(systemName: "person")

        APP.delegate = self

        SceneSetUp()

        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { [weak self] motion, error in
            guard let strongSelf = self else { return }
            guard let motion = motion, error == nil else { return }

            let threshold = 0.5
            let isTiltedNow = abs(motion.attitude.pitch) > threshold || abs(motion.attitude.roll) > threshold

            if isTiltedNow {
                if !self!.isTilted {
                    self!.isTilted = true
                    self!.tiltStartTime = Date()
                    // 기울기가 정상으로 돌아올 때 파란색으로 변경
                    let whiteMaterial = SCNMaterial()
                    whiteMaterial.diffuse.contents = UIColor.white
                    self!.cubeNode.geometry?.materials = [whiteMaterial]
                } else {
                    if let tiltStartTime = self!.tiltStartTime, Date().timeIntervalSince(tiltStartTime) >= 2 {
                        // 비정상 상태가 30초 이상 지속됐으므로 빨간색으로 변경
                        let redMaterial = SCNMaterial()
                        redMaterial.diffuse.contents = UIColor.red
                        self!.cubeNode.geometry?.materials = [redMaterial]
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

                        // 메인 스레드에서 알림 메시지 표시
                        DispatchQueue.main.async {
                                let alert = UIAlertController(title: "색상 변경", message: "3D 큐브의 색상이 변경되었습니다!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                                strongSelf.present(alert, animated: true, completion: nil)
                            }
                    }
                }
            } else {
                self!.isTilted = false
                self!.tiltStartTime = nil
            }

            self?.NodeRotate(motion)
            let currentState = self?.getCurrentStateFromMotion(motion)
            self?.updateTextView2Content(currentState)
        })
        
        colorUpdateTimer = Timer.scheduledTimer(timeInterval: colorUpdateInterval, target: self, selector: #selector(updateColor), userInfo: nil, repeats: true)

    }

    func checkIfAbnormalState(motion: CMDeviceMotion) -> Bool {
        let abnormalPitch = abs(motion.attitude.pitch) > 0.4 // 각도를 라디안에서 도로 변환
            // roll이 45도를 초과하면 비정상 상태로 간주
        let abnormalRoll = abs(motion.attitude.roll) > 0.4 // 각도를 라디안에서 도로 변환

            return abnormalPitch || abnormalRoll
        }
    
    @objc func updateColor() {
        if !isTilted {
            isTilted = true
            tiltStartTime = Date()
            // 기울기가 정상으로 돌아올 때 파란색으로 변경
            let whiteMaterial = SCNMaterial()
            whiteMaterial.diffuse.contents = UIColor.white
            cubeNode.geometry?.materials = [whiteMaterial]
        } else {
            if let tiltStartTime = tiltStartTime, Date().timeIntervalSince(tiltStartTime) >= 2 {
                // 비정상 상태가 30초 이상 지속됐으므로 빨간색으로 변경
                let redMaterial = SCNMaterial()
                redMaterial.diffuse.contents = UIColor.red
                cubeNode.geometry?.materials = [redMaterial]
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error in
            guard let motion = motion, error == nil else { return }

            let threshold = 0.5
            let isTiltedNow = abs(motion.attitude.pitch) > threshold || abs(motion.attitude.roll) > threshold

            if isTiltedNow {
                if !self!.isTilted {
                    self!.isTilted = true
                    self!.tiltStartTime = Date()
                    // 기울기가 정상으로 돌아올 때 파란색으로 변경
                    let whiteMaterial = SCNMaterial()
                    whiteMaterial.diffuse.contents = UIColor.white
                    self!.cubeNode.geometry?.materials = [whiteMaterial]
                } else {
                    if let tiltStartTime = self!.tiltStartTime, Date().timeIntervalSince(tiltStartTime) >= 2 {
                        // 비정상 상태가 30초 이상 지속됐으므로 빨간색으로 변경
                        let redMaterial = SCNMaterial()
                        redMaterial.diffuse.contents = UIColor.red
                        self!.cubeNode.geometry?.materials = [redMaterial]
                    }
                }
            } else {
                self!.isTilted = false
                self!.tiltStartTime = nil
            }

            self?.NodeRotate(motion)
            let currentState = self?.getCurrentStateFromMotion(motion)
            self?.updateTextView2Content(currentState)
        })
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP.stopDeviceMotionUpdates()
    }

    func NodeRotate(_ motion: CMDeviceMotion) {
        let data = motion.attitude
        cubeNode.eulerAngles = SCNVector3(-data.pitch, -data.yaw, -data.roll)
    }
    
    func detectAbnormalStateAndUpdateLog(motion: CMDeviceMotion) {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let threshold = 0.5

        if checkIfAbnormalState(pitch: pitch, roll: roll, threshold: threshold) {
            // 여기서는 비정상 상태일 때만 로그를 기록합니다.
            let logInfo = ["date": Date(), "pitch": pitch, "roll": roll] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name("RecordMotionLog"), object: nil, userInfo: logInfo)
        }
    }

    func checkIfAbnormalState(pitch: Double, roll: Double, threshold: Double) -> Bool {
        if abs(pitch) > threshold || abs(roll) > threshold {
            return true // 비정상
        } else {
            return false // 정상
        }
    }
    
    
    func SceneSetUp() {
        let scnView = SCNView(frame: self.view.frame)
        scnView.backgroundColor = UIColor.white
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        view.addSubview(scnView)
        
        // Set SCNScene to SCNView
        let scene = SCNScene()
        scnView.scene = scene
        
        // Adding a camera to a scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        scene.rootNode.addChildNode(cameraNode)
        
        // Adding an omnidirectional light source to the scene
        let omniLight = SCNLight()
        omniLight.type = .omni
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(omniLightNode)
        
        // Adding a light source to your scene that illuminates from all directions.
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.darkGray
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Adding a cube(face) to a scene
        let cube:SCNGeometry = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0.5)
        let eye:SCNGeometry = SCNSphere(radius: 0.3)
        let leftEye = SCNNode(geometry: eye)
        let rightEye = SCNNode(geometry: eye)
        leftEye.position = SCNVector3(x: 0.6, y: 0.6, z: 1.5)
        rightEye.position = SCNVector3(x: -0.6, y: 0.6, z: 1.5)
        
        let nose:SCNGeometry = SCNSphere(radius: 0.3)
        let noseNode = SCNNode(geometry: nose)
        noseNode.position = SCNVector3(x: 0, y: 0, z: 1.5)
        
        let mouth:SCNGeometry = SCNBox(width: 1.5, height: 0.2, length: 0.2, chamferRadius: 0.4)
        let mouthNode = SCNNode(geometry: mouth)
        mouthNode.position = SCNVector3(x: 0, y: -0.6, z: 1.5)
        
        cubeNode = SCNNode(geometry: cube)
        cubeNode.addChildNode(leftEye)
        cubeNode.addChildNode(rightEye)
        cubeNode.addChildNode(noseNode)
        cubeNode.addChildNode(mouthNode)
        cubeNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(cubeNode)
        
        // 텍스트 뷰 생성
        let textViewWidth: CGFloat = 300
        let textViewHeight: CGFloat = 100
        let textViewX = (view.bounds.width - textViewWidth) / 2
        let textViewY: CGFloat = 20
        let textViewFrame = CGRect(x: textViewX, y: textViewY+100, width: textViewWidth, height: textViewHeight)
        
        let textView = UITextView(frame: textViewFrame)
        textView.text = "현재 나의 모습"
        textView.isEditable = false // 사용자 입력 비활성화
        textView.font=UIFont.systemFont(ofSize: 50)
        view.addSubview(textView)
        
        // 텍스트 뷰 생성
        let textView2Frame = CGRect(x: 10, y: view.bounds.height-100, width: view.bounds.width-20 , height: 35)
        textView2 = UITextView(frame: textView2Frame)
        textView2.text = "현재 자세 : 정상"
        textView2.isEditable = false
        textView2.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(textView2)
    }

    func updateTextView2Content(_ content: String?) {
        if let content = content {
            DispatchQueue.main.async {
                self.textView2.text = "현재 자세 : " + content
            }
        }
    }

    func getCurrentStateFromMotion(_ motion: CMDeviceMotion) -> String {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let threshold = 0.5

        if abs(pitch) > threshold || abs(roll) > threshold {
            return "기울어짐"
        } else {
            return "정상"
        }
    }
}
