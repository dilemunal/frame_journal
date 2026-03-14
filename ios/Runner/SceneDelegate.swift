import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    // Google Sign-In geri dönüş URL'ini Flutter engine'e ilet
    let options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    _ = UIApplication.shared.delegate?.application?(UIApplication.shared, open: url, options: options)
  }
}
