//
//  ContentView.swift
//  SocketApp
//
//  Created by Dowon on 2/15/21.
//

import SwiftUI
import SocketIO

final class Service: ObservableObject {
    private var manager = SocketManager(socketURL: URL(string: "ws://localhost:3000")!, config: [.log(true), .compress])
    
    @Published var messages = [String]()
    
    
    
    
    init() {
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            socket.emit("NodeJs Server Port", "Hi Node.Js server!")
        }
        
        socket.on("iOS Client Port") { [weak self] (data, ack) in
            if let data = data[0] as? [String: String],
               let rawMessage = data["msg"] {
                DispatchQueue.main.async {
                    self?.messages.append(rawMessage)
                }
            }
        }
        
        socket.connect()
    }
}


struct ContentView: View {
    @ObservedObject var service = Service()
    
    @State var message: String = ""
    
    var body: some View {
        VStack {
            Text("Received Message from Node.js:")
                .font(.largeTitle)
            ForEach(service.messages, id: \.self) { msg in
                Text(msg).padding()
            }
            Spacer()
        }
        HStack(alignment: .center) {
            Text("Message:")
                .font(.callout)
                .bold()
            TextField("Enter message", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Send") {
                self.service.messages.append(message)
                print(service.messages)
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
