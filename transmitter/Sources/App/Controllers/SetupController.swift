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
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        bluetoothHub.reset()
        return try view.make("status", ["status": bluetoothHub.connected ? "connected" : "disconnected"], for: req)
    }
    
    func show(_ req: Request, _ string: String) throws -> ResponseRepresentable {
        if string == "blink" {
            bluetoothHub.blink()
            return try view.make("status", ["status": bluetoothHub.connected ? "connected" : "disconnected"], for: req)
        }
        return try index(req)
    }

    func makeResource() -> Resource<String> {
        return Resource( index: index, show: show)
    }
}
