import UIKit

class TopViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 첫 번째 탭
        let firstViewController = TableViewController()
        firstViewController.title = "Log"
        firstViewController.tabBarItem = UITabBarItem(title: "Log", image: nil, tag: 0)
        firstViewController.tabBarItem.image=UIImage(systemName: "calendar")

        
        // 두 번째 탭
        let secondViewController = InformationViewController()
        secondViewController.title = "Information"
        secondViewController.tabBarItem = UITabBarItem(title: "Info", image: nil, tag: 1)
        secondViewController.tabBarItem.image=UIImage(systemName: "calendar")

        
        // 세 번째 탭
        let thirdViewController = SK3DViewController()
        thirdViewController.title = "3D"
        thirdViewController.tabBarItem = UITabBarItem(title: "3D", image: nil, tag: 1)
        thirdViewController.tabBarItem.image=UIImage(systemName: "person")
        
        thirdViewController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)

        firstViewController.tabBarItem.selectedImage = UIImage(systemName: "calendar.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)

        // 탭 바 컨트롤러에 탭 뷰 컨트롤러 추가
        self.viewControllers = [thirdViewController, firstViewController]
    }
}

