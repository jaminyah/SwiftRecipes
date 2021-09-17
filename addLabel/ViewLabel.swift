//  Reference:
//  https://stackoverflow.com/questions/24081731/how-to-create-uilabel-programmatically-using-swift

import UIKit

class ViewLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }
    
    func initLabel() {
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.textAlignment = .center
    }
}
