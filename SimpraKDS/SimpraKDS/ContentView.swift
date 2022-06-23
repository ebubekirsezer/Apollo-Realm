//
//  ContentView.swift
//  SimpraKDS
//
//  Created by EbubekirSezer on 23.06.2022.
//

import SwiftUI
import Apollo
import RealmSwift

enum RealmFileName: String {
    case User
}

class RealmManager {
    
    static let service: RealmManager = RealmManager.init()
    
    func realm(named: RealmFileName) -> Realm? {
        var config = Realm.Configuration.defaultConfiguration
        
        guard let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent(named.rawValue + ".realm") else {
            return self.realm(named: named)
        }
        config.fileURL = fileUrl
        
        do {
            return try Realm(configuration: config, queue: nil)
        } catch {
            print("RealmError:\(error.localizedDescription)")
            return self.realm(named: named)
        }
    }
    
    func migrate() {
        Realm.migrate()
    }
}

private let kMinimumDataVersionKey: String = "kMinimumDataVersionKey"
private let kRealmDataVersion: UInt64 = 1    // Realmde değişiklik olunca 1 arttır
private let kMinimumDataVersion: Int = 1    // Datayı silmek istersen 1 arttır

extension Realm {
    static func migrate() {
        
        let config = Realm.Configuration(schemaVersion: kRealmDataVersion) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: MyUser.className()) { oldObject, newObject in
                    newObject?["id"] = UUID().uuidString
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
            print(config.fileURL ?? "")
        } catch let error as NSError {
            print(error)
        }
    }
}



class MyUser: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var ID = UUID().uuidString
    @Persisted var firstName: String?
    
    required convenience init?(dictionary: [String:Any]) {
        self.init()
        if let firstNameValue = dictionary["first_name"] as? String{
            firstName = firstNameValue
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                
                
                var userNew = UserLoginMutation.Data.UserLogin.User(firstName: "Ebubekir")
                Network.shared.apollo.perform(mutation: UserLoginMutation(input: UserLoginInput(email: "fcelik+bursa@protel.com.tr", password: "123123", token: nil, clientMutationId: nil))) { result in
                    switch result {
                    case .success(let response):
                        
                        guard let fatih = MyUser(dictionary: response.data?.userLogin?.user?.jsonObject ?? [:]) else { return }
                        
                        let realm = RealmManager.service.realm(named: .User)
                        print("REalm: \(realm?.configuration.fileURL)")
                        do {
                            try realm?.write({
                                realm?.add(fatih)
                            })
                        } catch {
                            print("Error writing the user")
                        }
                    case .failure(let error):
                        print("xxxx \(error)")
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
