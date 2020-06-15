
import UIKit

class AllowedCharsTextField: UITextField, UITextFieldDelegate {
  
  @IBInspectable var allowedChars: String = ""
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    delegate = self
    autocorrectionType = .no
  }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    return prospectiveText.containsOnlyCharactersIn(matchCharacters: allowedChars)
  }
  
}


extension String {
  
  // Returns true if the string contains only characters found in matchCharacters.
  func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
    let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
    return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
  }
  
}
