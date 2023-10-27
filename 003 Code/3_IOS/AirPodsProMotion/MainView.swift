import UIKit

class MainView: UITabBarController{
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.frame = CGRect(x: self.view.bounds.minX + (self.view.bounds.width / 10),
                            y: self.view.bounds.minY + (self.view.bounds.height / 6),
                            width: self.view.bounds.width, height: self.view.bounds.height)
        view.text = "Looking for AirPods Pro"
        view.font = view.font?.withSize(14)
        view.isEditable = false
        return view
    }()
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // "Hello World" 레이블을 생성합니다.
            let label = UILabel()
            label.text = "Hello World"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            label.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
            label.center = view.center
            
            // 레이블을 현재 뷰 컨트롤러의 뷰에 추가합니다.
            view.addSubview(label)
        }
}

