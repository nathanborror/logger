import UIKit

extension Notification {

    var keyboardFrameEnd: CGRect? {
        guard let value = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return nil
        }
        return value.cgRectValue
    }

    var keyboardAnimationDuration: TimeInterval? {
        guard let value = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return nil
        }
        return TimeInterval(value.floatValue)
    }

    var keyboardAnimationCurve: UIViewAnimationCurve? {
        guard let value = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return nil
        }
        return UIViewAnimationCurve(rawValue: value.intValue)
    }

    var keyboardAnimationOptions: UIViewAnimationOptions? {
        guard let value = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return nil
        }
        return UIViewAnimationOptions(rawValue: value.uintValue << 16)
    }
}
