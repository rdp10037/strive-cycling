//
//  Query.swift
//  Stacks
//
//  Created by Rob Pee on 1/16/24.
//

import Foundation
import FirebaseFirestore
import Combine

extension Query {

    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).itemsArray
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (itemsArray: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let itemsArray =  try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (itemsArray, snapshot.documents.last)
        
    }
    
    /// check on pagination
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggragateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
            return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let itemsArray: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            publisher.send(itemsArray)
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}
