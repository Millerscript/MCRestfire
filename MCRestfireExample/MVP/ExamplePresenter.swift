//
//  ExamplePresenter.swift
//  MCRestfireExample
//
//  Created by Miller Mosquera on 30/08/23.
//

import Foundation
import Combine
import MCRestfire


protocol PresenterProtocol {
    func getResult()
    func getInterest()
}

class ExamplePresenter: PresenterProtocol {
    
    weak var view: ViewProtocol?
    var repository: TestingRepository

    init(view: ViewProtocol, repository: TestingRepository) {
        self.view = view
        self.repository = repository
    }
    
    func getResult() {
        /*Task {
            let r = await repository.testingSomething()
            _ = r.sink { error in
                print(error)
            } receiveValue: { data in
                print(data)
                self.view?.getResult(data: data.author)
            }
        }*/
        
        
        Task {
            let result = await repository.testingSomething()
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
        
    }
    
    func getInterest() {
        Task {
            let result = await repository.test()
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
}

