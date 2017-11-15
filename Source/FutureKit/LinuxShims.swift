#if os(Linux)
    import Foundation
    import Dispatch

    /// Dummy class for linux support
    public class NSManagedObjectContext: NSObject {

        enum ConcurrencyType : UInt {
            case privateQueueConcurrencyType
            case mainQueueConcurrencyType
        }

        var concurrencyType: ConcurrencyType = .mainQueueConcurrencyType

        private let privateQueue: DispatchQueue = DispatchQueue.init(label: "org.futurekit.privateCoreDataShimQueue")

        func perform(_ block: @escaping () -> Void) {
            switch concurrencyType {
            case .privateQueueConcurrencyType:
                privateQueue.async(execute: block)
            default:
                DispatchQueue.main.async(execute: block)
            }
        }
    }

    public struct NSExceptionName : RawRepresentable, Equatable, Hashable {

        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static func == (lhs: NSExceptionName, rhs: NSExceptionName) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        public var hashValue: Int {
            return rawValue.hashValue
        }
    }

    public class NSException : NSObject, NSCopying, NSCoding {

        public var name: NSExceptionName
        public var reason: String?
        public var userInfo: [AnyHashable : Any]?

        public init(name aName: NSExceptionName, reason aReason: String?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
            self.name = aName
            self.reason = aReason
            self.userInfo = aUserInfo
        }

        public func encode(with aCoder: NSCoder) {
            aCoder.encode(name.rawValue, forKey: "name")
            aCoder.encode(reason, forKey: "reason")
            aCoder.encode(userInfo, forKey: "userInfo")
        }

        public required init?(coder aDecoder: NSCoder) {
            name = NSExceptionName(aDecoder.decodeObject(forKey: "name") as! String)
            reason = aDecoder.decodeObject(forKey: "reason") as? String
            userInfo = aDecoder.decodeObject(forKey: "userInfo") as? [AnyHashable: Any]
        }

        public func raise() {
            fatalError("Raising NSExceptions not supported on linux")
        }

        public func copy(with zone: NSZone? = nil) -> Any {
            return NSException(name: name, reason: reason, userInfo: userInfo)
        }

        public let callStackReturnAddresses: [NSNumber] = []

        public let callStackSymbols: [String] = []
    }
#endif
