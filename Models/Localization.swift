
import Foundation

class Localization {
    private var key: String
    private var value: String
    
    init() {
        self.key = "";
        self.value = ""
    }
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    public func getKey() -> String {
        return key
    }
    
    public func getValue() -> String {
        return value
    }
}
