//
//  Emotioner.swift
//  transmitter
//
//  Created by Sergii Buchniev on 01.05.18.
//

import Cocoa
import CoreBluetooth

class Emotioner: NSObject {
    
    private let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }
    
    func reset() {
        
    }
}

extension Emotioner: CBPeripheralDelegate {
    
}
