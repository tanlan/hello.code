//
//  DisplayController.swift
//  transmitter
//
//  Created by Sergii Buchniev on 02.05.18.
//

import Cocoa
import Vapor
import HTTP

class DisplayController: ResourceRepresentable {
    
    let view: ViewRenderer
    let bluetoothHub = BluetoothHub.shared
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        let emptyEmotion = try view.make("display", ["client": "Nobody", "emotion" : "none"], for: req)
        guard let query = req.query else { return emptyEmotion }
        guard let name = query["name"]?.string else { return emptyEmotion }
        guard let emotion = query["data"]?.string else { return emptyEmotion }
        let matrix = Array(emotion)
        var dic = ["client": name];
        for i in 0...7 {
            var matrixDisplay = ""
            for j in 0...7 {
                let sym = matrix[8 * i + j] == "0" ? "  ◎  " : "  ◉  "
                matrixDisplay.append(sym)
            }
            dic["emotion\(i+1)"] = matrixDisplay
        }
        return try view.make("display", dic, for: req)
    }
    
    func show(_ req: Request, _ string: String) throws -> ResponseRepresentable {
        return try index(req)
    }
    
    func makeResource() -> Resource<String> {
        return Resource(index: index, show: show)
    }
}
