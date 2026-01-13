import UIKit
import Flutter
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Forzar fondo negro DESPUÉS de que Flutter inicialice
    DispatchQueue.main.async {
      if let window = UIApplication.shared.windows.first ?? self.window {
        window.backgroundColor = UIColor.black
        if let rootVC = window.rootViewController {
          rootVC.view.backgroundColor = UIColor.black
          self.setBlackBackground(view: rootVC.view)
          rootVC.setNeedsStatusBarAppearanceUpdate()
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func setBlackBackground(view: UIView?) {
    guard let view = view else { return }
    // Solo cambiar el fondo si no es el FlutterView (que tiene su propio contenido)
    if !view.isKind(of: NSClassFromString("FlutterView") ?? UIView.self) {
      view.backgroundColor = UIColor.black
    }
    for subview in view.subviews {
      setBlackBackground(view: subview)
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Dejar que Firebase maneje automáticamente el tipo de entorno (sandbox/prod)
    // Con FirebaseAppDelegateProxyEnabled = true, NO debemos forzar el tipo
    Messaging.messaging().apnsToken = deviceToken
    print("🔧 APNs token set automáticamente (length: \(deviceToken.count) bytes)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
