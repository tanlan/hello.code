//
//  SetupController.swift
//  transmitter
//
//  Created by Sergii Buchniev on 01.05.18.
//

import Cocoa
import Vapor
import HTTP

class SetupController: ResourceRepresentable {
    
    let view: ViewRenderer
    let bluetoothHub = BluetoothHub()
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    /// GET /hello
    func index(_ req: Request) throws -> ResponseRepresentable {
        bluetoothHub.reset()
        return try view.make("status", ["status": bluetoothHub.connected ? "connected" : "disconnected"], for: req)
    }
    
    /// GET /hello/:string
    func show(_ req: Request, _ string: String) throws -> ResponseRepresentable {
        if string == "blink" {
            bluetoothHub.blink()
            return try view.make("status", ["status": bluetoothHub.connected ? "connected" : "disconnected"], for: req)
        }
        return try index(req)
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<String> {
        return Resource( index: index, show: show)
    }
}
