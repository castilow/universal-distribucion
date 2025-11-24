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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
