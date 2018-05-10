import Vapor
import Cocoa

final class Routes: RouteCollection {
    
    let view: ViewRenderer
    
    let emotioner = BluetoothHub.shared
    let queue = DispatchQueue(label: "Connection")
    
    init(_ view: ViewRenderer) {
        self.view = view
    }

    func build(_ builder: RouteBuilder) throws {
        /// GET /
        builder.get { req in
            return try self.view.make("welcome")
        }

        /// GET /hello/...
        builder.resource("hello", HelloController(view))

        // response to requests to /info domain
        // with a description of the request
        builder.get("info") { req in
            return req.description
        }
        
        builder.get("emotion") { req in
            guard let query = req.query else { return "None" }
            guard let name = query["name"]?.string else { return "None" }
            guard let emotion = query["data"]?.string else { return "None" }
            let matrix = Array(emotion).map { String($0).int }.compactMap{ return $0 }.map { UInt8($0) }
            self.queue.async { [weak self] in
                self?.emotioner.display(matrix)
                let string = "http://hellocode.local:8080/display?name=\(name)&data=\(emotion)"
                guard let url = URL(string: string) else { NSLog("Bad URL:\(string)"); return }
                NSWorkspace.shared.open(url)
            }
            self.queue.async { sleep(2) }
            
            return "Smile"
        }
        
        builder.resource("status", SetupController(view))
        builder.resource("display", DisplayController(view))
        
        
    }
}
