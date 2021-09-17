import UIKit

class ViewController: UIViewController {
    
    var viewLabel: UILabel = ViewLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    var viewLabel2: UILabel = ViewLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
 
    override func loadView() {
        super.loadView()
        self.view.addSubview(viewLabel)
        self.view.addSubview(viewLabel2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewLabel.text = "Hello, World!"
        viewLabel.center = CGPoint(x: 160, y: 285)
        
        viewLabel2.text = "Hello, Label!"
        viewLabel2.center = CGPoint(x: 160, y: 385)
    }
}
