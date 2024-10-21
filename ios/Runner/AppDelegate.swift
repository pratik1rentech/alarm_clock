import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
          if granted {
              print("Notification permission granted.")
          } else if let error = error {
              print("Notification permission denied: \(error.localizedDescription)")
          }
      }
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.alarm/setAlarm", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "setAlarm" {
        if let args = call.arguments as? [String: Any],
           let time = args["time"] as? String {
          self.setAlarm(time: time)
          result("Alarm is set for \(time)")
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Time not provided", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setAlarm(time: String) {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "Alarm"
    content.body = "Your alarm is ringing!"
    content.sound = UNNotificationSound.default

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"

    if let alarmDate = formatter.date(from: time) {
      let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: alarmDate)
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

      center.add(request) { (error) in
        if let error = error {
          print("Error adding notification: \(error.localizedDescription)")
        }
      }
    }
  }
}
