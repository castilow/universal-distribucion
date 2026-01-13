import UIKit
import Flutter

extension FlutterViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // Iconos blancos para fondo oscuro
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
}






