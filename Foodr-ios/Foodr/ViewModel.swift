//
//  ViewModel.swift
//  Foodr
//
//  Created by Alexey Minakov on 25.08.2022.
//

import Foundation
import MQTTNIO
import NIO
import SotoCore
import SotoSignerV4


struct MQTTCommand: Decodable, Encodable {
    let command_uid: String
    let command: String
}

let HOST = ""  // AWS MQTT endpoint
let AWS_ACCESS_KEY_ID = ""  // AWS access key
let AWS_SECRET_KEY = ""  // AWS secret key
let COMMAND_TOPIC = "foodr/device/a279ajksD/command"
let RESPONSE_TOPIC = "foodr/device/a279ajksD/response"
let CLIENT_ID = "foodr-ios"


class ViewModel: ObservableObject {
    
    @Published var response: String = ""
    
    private(set) var client: MQTTClient!

    
    init() {
        client = createMQTTClient()
        client.connect().whenComplete { result in
            switch result {
            case .success:
                print("Succesfully connected")
                self.subscribe()
            case .failure(let error):
                print("Error while connecting \(error)")
            }
        }
        
    }
    
    func subscribe() {
        let subscription = MQTTSubscribeInfo(topicFilter: RESPONSE_TOPIC, qos: .atLeastOnce)
        client.subscribe(to: [subscription]).whenComplete { result in
            switch result {
            case .success:
                print("Succesfully subscribed to \(RESPONSE_TOPIC)")
            case .failure(let error):
                print("Error while subscribing \(error)")
            }
        }
        client.addPublishListener(named: "Result Listener") { result in
            switch result {
            case .success(let publish):
                let buffer = publish.payload
                let _: Data
                let responseCommand: MQTTCommand = try! JSONDecoder().decode(MQTTCommand.self, from:buffer)
                print("Response from the device received: \(responseCommand.command) \(responseCommand.command_uid)")
                DispatchQueue.main.async {
                    self.response = "\(responseCommand.command) \(responseCommand.command_uid)"
                }
            case .failure(_):
                print("Error while receiving PUBLISH event")
            }
        }
    }
    
    func crateSignedRequestURI() -> String {
        let headers = HTTPHeaders([("host", HOST)])
        let signer = AWSSigner(
            credentials: StaticCredential(accessKeyId: AWS_ACCESS_KEY_ID, secretAccessKey: AWS_SECRET_KEY),
            name: "iotdata",
            region: "eu-west-1"
        )
        let signedURL = signer.signURL(
            url: URL(string: "https://\(HOST)/mqtt")!,
            method: .GET,
            headers: headers,
            body: .none,
            expires: .minutes(30)
        )
        let requestURI = "/mqtt?\(signedURL.query!)"
        return requestURI
    }
    
    func createMQTTClient() -> MQTTClient {
        let client = MQTTClient(
            host: HOST,
            identifier: CLIENT_ID,
            eventLoopGroupProvider: .createNew,
            configuration: .init(useSSL: true, useWebSockets: true, webSocketURLPath: crateSignedRequestURI())
        )
        return client
    }
    
    func sendCommand() {
        print("Sending command to \(COMMAND_TOPIC)")
        let uuid = UUID().uuidString
        let commandData = "ping"
        let command: MQTTCommand = MQTTCommand(command_uid: uuid, command: commandData)
        var buffer = ByteBuffer()
        try! JSONEncoder().encode(command, into: &buffer)
        client.publish(to: COMMAND_TOPIC, payload: buffer, qos: .atLeastOnce, retain: true)
        print("Command sent: \(commandData) \(uuid)")
    }
}
