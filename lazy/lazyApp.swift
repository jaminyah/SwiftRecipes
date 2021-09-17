//  Avoiding optionals with lazy var

import UIKit

class ViewController: UIViewController {
    
    lazy var label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))

    override func loadView() {
        super.loadView()
        self.view.addSubview(self.label)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.text = "Hello, World!"
        self.label.textColor = .black
        self.label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.label.center = CGPoint(x: 160, y: 285)
        self.label.textAlignment = .center
    }
}
