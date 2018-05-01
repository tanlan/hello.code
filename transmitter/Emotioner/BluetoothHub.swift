//
//  BluetoothHub.swift
//  transmitter
//
//  Created by Sergii Buchniev on 01.05.18.
//

import Cocoa
import CoreBluetooth

class BluetoothHub: NSObject {
    
    private(set) var connected: Bool = false
    
    private let centralQueue = DispatchQueue(label: "Bluetooth-stream")
    private lazy var centralManager:CBCentralManager = CBCentralManager(delegate: self, queue: centralQueue)
    
    private var peripheralDevice: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    override init() {
        super.init()
        _ = centralManager
    }
    
    func blink() {
        display([1,1,1,1,1,1,1,1,
                 1,1,1,1,1,1,1,1,
                 0,0,0,0,1,1,1,1,
                 0,0,0,1,1,1,1,1,
                 0,0,1,1,1,0,1,1,
                 0,1,1,1,0,0,1,1,
                 1,1,1,0,0,0,1,1,
                 1,1,0,0,0,0,1,1])
    }
    
    func reset() {
        display(Array<UInt8>(repeating: 0, count: 64))
    }
    
    func display(_ matrix:[UInt8]) {
        guard let device = peripheralDevice else { return }
        guard let characteristic = characteristic else { return }
        
        var displayMatrix = matrix
        for i in 0...7 {
            for j in 0...3 {
                let index = i * 8 + j
                let mirrorIndex = i * 8 + 7 - j
                let value: UInt8 = matrix[index] > 0 ? 49 : 40
                let mirrorValue: UInt8 = matrix[mirrorIndex] > 0 ? 49 : 40
                displayMatrix[index] = mirrorValue
                displayMatrix[mirrorIndex] = value
            }
        }
        let data = NSData(bytes: &displayMatrix, length: 64)
        device.writeValue(data as Data, for: characteristic, type: .withResponse)
    }
    
    var onConnectionEstablished: (() -> Void)?
    var onConnectionClosed: (() -> Void)?
}

extension BluetoothHub: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff: peripheralDevice = nil
        case .poweredOn: scanForPeriferal()
        case .resetting: peripheralDevice = nil
        default: break
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard peripheralDevice == nil else { return }
        guard peripheral.identifier.uuidString == "E03D3926-1BBE-435F-A833-75F8034C8B1E" else { return }
        peripheralDevice = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        onConnectionEstablished?()
        connected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        peripheralDevice = nil
        scanForPeriferal()
        onConnectionClosed?()
        connected = false
    }
}

extension BluetoothHub: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        characteristic = service.characteristics?.first
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("Error: \(String(describing: error))")
        NSLog("Char: \(characteristic)")
    }
}

private extension BluetoothHub {
    
    private func scanForPeriferal() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}
