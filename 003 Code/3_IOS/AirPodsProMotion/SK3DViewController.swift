/*//
//  SK3DViewController.swift
//  AirPodsProMotion
//
//  Created by Yoshio on 2020/09/23.
//

import UIKit
import SceneKit
import CoreMotion

/*
class SK3DViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    // cube
    var cubeNode: SCNNode!
    var textView2: UITextView! // 클래스 멤버 변수로 선언
    var isTilted = false // 기울어진 상태 여부를 판단하는 플래그
    var tiltTimer: Timer? // 비정상 상태 지속 시간을 추적하는 타이머

    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.view.backgroundColor = .systemBackground
        self.title = "3D "
        self.tabBarItem.image=UIImage(systemName: "person")

        APP.delegate = self

        SceneSetUp()
        
        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.NodeRotate(motion)
        })
        
        APP.delegate = self
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in guard let motion = motion, error == nil else { return }
            self?.NodeRotate(motion)

            // "현재 자세" 값을 받아와서 textView2 업데이트
            let currentState = self?.getCurrentStateFromMotion(motion)
            self?.updateTextView2Content(currentState)
        })
        
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error in
                    guard let motion = motion, error == nil else { return }

                    // 기울기 상태 감지
                    let threshold = 0.5 // 임계값을 조절하여 기울어진 상태를 판단
                    let isTiltedNow = abs(motion.attitude.pitch) > threshold || abs(motion.attitude.roll) > threshold

                    if isTiltedNow {
                        // 현재 기울어진 상태
                        if !self!.isTilted {
                            // 이전에 정상 상태였던 경우
                            self!.isTilted = true
                            self!.startTiltTimer()
                        }
                    } else {
                        // 현재 정상 상태
                        self!.isTilted = false
                        self!.stopTiltTimer()
                    }
                })
    }*/
class SK3DViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
let APP = CMHeadphoneMotionManager()
    var cubeNode: SCNNode!
    var textView2: UITextView!
    
    var isTilted = false
    var tiltStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        self.title = "3D"
        self.tabBarItem.image = UIImage(systemName: "person")

        APP.delegate = self

        SceneSetUp()

        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error in
            guard let motion = motion, error == nil else { return }

            let threshold = 0.5
            let isTiltedNow = abs(motion.attitude.pitch) > threshold || abs(motion.attitude.roll) > threshold

            if !self!.isTilted {
                self!.isTilted = true
                self!.tiltStartTime = Date()
                // 기울기가 정상으로 돌아올 때 파란색으로 변경
                let blueMaterial = SCNMaterial()
                blueMaterial.diffuse.contents = UIColor.blue
                self!.cubeNode.geometry?.materials = [blueMaterial]
            } else {
                if let tiltStartTime = self!.tiltStartTime, Date().timeIntervalSince(tiltStartTime) >= 2 {
                    // 비정상 상태가 30초 이상 지속됐으므로 빨간색으로 변경
                    let redMaterial = SCNMaterial()
                    redMaterial.diffuse.contents = UIColor.red
                    self!.cubeNode.geometry?.materials = [redMaterial]
                }
            }

            self?.NodeRotate(motion)
            let currentState = self?.getCurrentStateFromMotion(motion)
            self?.updateTextView2Content(currentState)
        })
    }





    
/*
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP.stopDeviceMotionUpdates()
    }
*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP.stopDeviceMotionUpdates()
    }
    
    /*삭제
    func startTiltTimer() {
        if tiltTimer == nil {
            tiltTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(handleTiltTimer), userInfo: nil, repeats: false)
        }
    }*/
    
    /*삭제
    // 비정상 상태가 지속된 경우 이 메서드가 호출됩니다.
        @objc func handleTiltTimer() {
            // 비정상 상태가 30초 이상 지속됐으므로 빨간색으로 변경
            let redMaterial = SCNMaterial()
            redMaterial.diffuse.contents = UIColor.red
            cubeNode.geometry?.materials = [redMaterial]

            // 기울기 타이머 중지
            stopTiltTimer()
        }

        // 기울기 타이머를 중지합니다.
        
         func stopTiltTimer() {
            tiltTimer?.invalidate()
            tiltTimer = nil
        }
     */
/*
    func NodeRotate(_ motion: CMDeviceMotion) {
        let data = motion.attitude

        cubeNode.eulerAngles = SCNVector3(-data.pitch, -data.yaw, -data.roll)

        // 기울기가 일정 임계값을 초과하면 빨간색으로, 그렇지 않으면 파란색으로 변경
        let threshold = 0.5 // 임계값을 조절하여 기울어진 상태를 판단
        //var isTilted = false // 기울어진 상태 여부를 판단하는 플래그

        if abs(data.pitch) > threshold || abs(data.roll) > threshold {
            // 기울어질 때 빨간색으로 변경
            let redMaterial = SCNMaterial()
            redMaterial.diffuse.contents = UIColor.red
            cubeNode.geometry?.materials = [redMaterial]
            isTilted = true
        } else {
            // 정상일 때 파란색으로 변경
            let whiteMaterial = SCNMaterial()
            whiteMaterial.diffuse.contents = UIColor.white
            cubeNode.geometry?.materials = [whiteMaterial]
            isTilted = false
        }

        // 기울기 상태에 따라 textView2 업데이트
        let currentState = isTilted ? "기울어짐" : "정상"
        updateTextView2Content(currentState)
    }
*/
    func NodeRotate(_ motion: CMDeviceMotion) {
            let data = motion.attitude
            cubeNode.eulerAngles = SCNVector3(-data.pitch, -data.yaw, -data.roll)
        }
}


// SceneKit
extension SK3DViewController {
    
    func SceneSetUp() {
        let scnView = SCNView(frame: self.view.frame)
        scnView.backgroundColor = UIColor.white
        scnView.allowsCameraControl = false
        scnView.showsStatistics = true
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
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        cube.materials = [whiteMaterial]
        
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
        let textView2Frame = CGRect(x: 10, y: view.bounds.height-110, width: view.bounds.width-20 , height: 35)
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
    /*
    func getCurrentStateFromMotion(_ motion: CMDeviceMotion) -> String {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let threshold = 0.1 // 임계값을 조절하여 기울어진 상태를 판단

        if abs(pitch) > threshold || abs(roll) > threshold {
            // 기울어질 때 빨간색으로 변경
            let redMaterial = SCNMaterial()
            redMaterial.diffuse.contents = UIColor.red
            cubeNode.geometry?.materials = [redMaterial]
            return "기울어짐"
        } else {
            // 정상일 때 파란색으로 변경
            let whiteMaterial = SCNMaterial()
            whiteMaterial.diffuse.contents = UIColor.white
            cubeNode.geometry?.materials = [whiteMaterial]
            return "정상"
        }
    }*/
    func getCurrentStateFromMotion(_ motion: CMDeviceMotion) -> String {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let threshold = 0.5

        if abs(pitch) > threshold || abs(roll) > threshold {
            return "비정상"
        } else {
            return "정상"
        }
    }
}
*/




import UIKit
import SceneKit
import CoreMotion

class SK3DViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    let APP = CMHeadphoneMotionManager()
    var cubeNode: SCNNode!
    var textView2: UITextView!
    
    var isTilted = false
    var tiltStartTime: Date?
    var colorUpdateTimer: Timer?
    let colorUpdateInterval: TimeInterval = 1.0 // 1초마다 업데이트

    override func viewDidLoad() {
        super.viewDidLoad()


        self.view.backgroundColor = .systemBackground
        self.title = "3D"
        self.tabBarItem.image = UIImage(systemName: "person")

        APP.delegate = self

        SceneSetUp()

        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
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
        
        colorUpdateTimer = Timer.scheduledTimer(timeInterval: colorUpdateInterval, target: self, selector: #selector(updateColor), userInfo: nil, repeats: true)

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

    func SceneSetUp() {
        let scnView = SCNView(frame: self.view.frame)
        scnView.backgroundColor = UIColor.white
        scnView.allowsCameraControl = false
        scnView.showsStatistics = true
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
        let textView2Frame = CGRect(x: 10, y: view.bounds.height-110, width: view.bounds.width-20 , height: 35)
        textView2 = UITextView(frame: textView2Frame)
        textView2.text = "현재 자세 : 정상"
        textView2.isEditable = false
        textView2.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(textView2)
    }

    func updateTextView2Content(_ content: String?) {
        if let content = content {
            DispatchQueue.main.async {
                self.textView2.text = "현재 자세: " + content
            }
        }
    }

    func getCurrentStateFromMotion(_ motion: CMDeviceMotion) -> String {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let threshold = 0.5

        if abs(pitch) > threshold || abs(roll) > threshold {
            return "비정상"
        } else {
            return "정상"
        }
    }
}
