
import UIKit

private var maxLengths = [UITextField: Int]()

extension UITextField {
  
  @IBInspectable var maxLength: Int {
    get {
      guard let length = maxLengths[self] else {
        return Int.max
      }
      return length
    }
    set {
      maxLengths[self] = newValue
      // Any text field with a set max length will call the limitLength
      // method any time it's edited (i.e. when the user adds, removes,
      // cuts, or pastes characters to/from the text field).
        addTarget(
            self,
            action: #selector(limitLength),
            for: UIControl.Event.editingChanged
      )
    }
  }
  
//    @objc func limitLength(textField: UITextField) {
//    guard let prospectiveText = textField.text, prospectiveText.count > maxLength else {
//        return
//    }
//
//    // If the change in the text field's contents will exceed its maximum length,
//    // allow only the first [maxLength] characters of the resulting text.
//    let selection = selectedTextRange
//    text = prospectiveText.substringWith(
////      Range<String.Index>(prospectiveText.startIndex ..< prospectiveText.startIndex.advancedBy(maxLength))
//              Range<String.Index>(prospectiveText.startIndex ..< advance(prospectiveText.startIndex, maxLength))
//    )
//    selectedTextRange = selection
//  }
    
    @objc func limitLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
  
}
