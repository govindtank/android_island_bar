import Flutter
import UIKit

public class AndroidIslandBarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "android_island_bar", binaryMessenger: registrar.messenger())
    let instance = AndroidIslandBarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getCutoutInfo":
      result(getCutoutInfo())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getCutoutInfo() -> [String: Any] {
    let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first
    let topInset = Double(window?.safeAreaInsets.top ?? 0.0)
    let bottomInset = Double(window?.safeAreaInsets.bottom ?? 0.0)
    let leftInset = Double(window?.safeAreaInsets.left ?? 0.0)
    let rightInset = Double(window?.safeAreaInsets.right ?? 0.0)
    let screenWidth = Double(UIScreen.main.bounds.width)

    var hasCutout = false
    var cutoutType = "none"
    var rectList: [[String: Double]] = []

    if topInset >= 54.0 {
      // iPhone 14 Pro / 15 / 16 series with native Dynamic Island
      hasCutout = true
      cutoutType = "center_punch"
      let islandWidth = 126.0
      let islandHeight = 36.67
      let islandTop = 11.0
      let islandLeft = (screenWidth - islandWidth) / 2.0
      rectList.append([
        "left": islandLeft,
        "top": islandTop,
        "right": islandLeft + islandWidth,
        "bottom": islandTop + islandHeight,
        "width": islandWidth,
        "height": islandHeight,
        "centerX": screenWidth / 2.0,
        "centerY": islandTop + (islandHeight / 2.0)
      ])
    } else if topInset >= 44.0 {
      // iPhone X through 14 with standard Notch
      hasCutout = true
      cutoutType = "notch"
      let notchWidth = 160.0
      let notchHeight = topInset
      let notchLeft = (screenWidth - notchWidth) / 2.0
      rectList.append([
        "left": notchLeft,
        "top": 0.0,
        "right": notchLeft + notchWidth,
        "bottom": notchHeight,
        "width": notchWidth,
        "height": notchHeight,
        "centerX": screenWidth / 2.0,
        "centerY": notchHeight / 2.0
      ])
    }

    return [
      "hasCutout": hasCutout,
      "cutoutType": cutoutType,
      "safeInsetTop": topInset,
      "safeInsetBottom": bottomInset,
      "safeInsetLeft": leftInset,
      "safeInsetRight": rightInset,
      "rects": rectList
    ]
  }
}
