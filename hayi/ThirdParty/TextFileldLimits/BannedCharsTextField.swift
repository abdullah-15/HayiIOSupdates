
import UIKit

class BannedCharsTextField: UITextField, UITextFieldDelegate {
  
  @IBInspectable var bannedChars: String = ""
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    delegate = self
    autocorrectionType = .no
  }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard string.count > 0 else {
      return true
    }
    
    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    return prospectiveText.doesNotContainCharactersIn(matchCharacters: bannedChars)
  }
  
}


extension String {
  
  // Returns true if the string has no characters in common with matchCharacters.
  func doesNotContainCharactersIn(matchCharacters: String) -> Bool {
    let characterSet = NSCharacterSet(charactersIn: matchCharacters)
    return self.rangeOfCharacter(from: characterSet as CharacterSet) == nil
  }
  
}
