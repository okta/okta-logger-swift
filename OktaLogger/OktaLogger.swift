import Foundation

/**
 Public interface for main OktaLogger instances
 */
@objc
public protocol OktaLoggerProtocol {
    
    /**
    Logging super-method for all parameters
    
    - Parameters:
      - level: OktaLogLevel for this event
      - eventName: name for this event
      - message: message for this event (optional)
      - properties: key-value properties for this event (optional)
      - identifier: logger identifier for this event
         */
    func log(level: OktaLogLevel,
             eventName: String,
             message: String?,
             properties: [AnyHashable: Any]?,
             identifier: String?,
             file: String?,
             line: NSNumber?,
             column: NSNumber?,
             funcName: String?)
    
    /**
     Convenience method for log(level: .debug, ...)
     */
    func debug(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .info, ...)
     */
    func info(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .warning, ...)
     */
    func warning(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .uievent, ...)
     */
    func uiEvent(eventName: String,
                       message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    /**
     Convenience method for log(level: .error, ...)
     */
    func error(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Set default property dict for a given logging destination
     
     - Parameters:
     - properties: Key-value pairs of properties to be applied to logs
     - identifier: Logger identifier, nil will apply to all loggers
     */
    func setDefaultProperties(properties: [AnyHashable : Any])
    
    /**
     Add a logging destination to the Logger
     
     - Parameters:
        - destination: Concrete logger destination to be added
     */
    func addDestination(_ destination: OktaLoggerDestination)
    
    /**
    Remove a logging destination
    
    - Parameters:
       - identifier: identifier of destination to be removed
    */
    func removeDestination(identifier: String)
}

/**
 Main Logger Proxy
 */
@objc
open class OktaLogger: NSObject, OktaLoggerProtocol {
   
    // MARK: Public
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, identifier: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        // sync so that callstacks are preserved
        self.queue.sync {
            for logger in self.destinations.values {
                // check the logging level of this destination
                let levelCheck = (logger.level.rawValue & level.rawValue) == level.rawValue
                if !levelCheck {return}
                
                // log to one or all idenitifiers
                if identifier == nil ||
                    logger.identifier == identifier {
                    logger.log(level: level,
                               eventName: eventName,
                               message: message,
                               properties: properties ?? self.defaultProperties,
                               file: file, line: line, column: column, funcName: funcName)
                    // if we logged to the right identifier, we can break early
                    if identifier != nil { break }
                }
            }
        }
    }
    
    public func debug(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, column: NSNumber? = #column, funcName: String? = #function) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    public func info(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, column: NSNumber? = #column, funcName: String? = #function) {
        log(level: .info, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    public func warning(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String? = #file, line: NSNumber? = #line, column: NSNumber? = #column, funcName: String? = #function) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    public func uiEvent(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, column: NSNumber? = #column, funcName: String? = #function) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    public func error(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, column: NSNumber? = #column, funcName: String? = #function) {
        log(level: .error, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    public func removeDestination(identifier: String) {
        _ = self.queue.sync {
            self.destinations.removeValue(forKey: identifier)
        }
    }
    
    public func addDestination(_ destination: OktaLoggerDestination) {
        self.queue.sync {
            self.destinations[destination.identifier] = destination
        }
    }
    
    public func setDefaultProperties(properties: [AnyHashable : Any]) {
        self.queue.sync {
            self.defaultProperties = properties
        }
    }
    
    // MARK: Private / Internal
    
    var destinations = [String:OktaLoggerDestination]()
    var defaultProperties = [AnyHashable : Any]()
    let queue = DispatchQueue(label: "com.okta.logger")
    
}
