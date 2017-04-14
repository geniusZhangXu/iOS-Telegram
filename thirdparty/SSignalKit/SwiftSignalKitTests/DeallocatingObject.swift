import Foundation

internal class DeallocatingObject : CustomStringConvertible {
    fileprivate var deallocated: UnsafeMutablePointer<Bool>
    
    init(deallocated: UnsafeMutablePointer<Bool>) {
        self.deallocated = deallocated
    }
    
    deinit {
        self.deallocated.pointee = true
    }
    
    var description: String {
        get {
            return ""
        }
    }
}
