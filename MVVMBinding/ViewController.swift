//
//  ViewController.swift
//  MVVMBinding
//
//  Created by abdrahman on 29/05/2021.
//

import UIKit

class Observable<T> {
    var value: T?{
        didSet{
            //listner?(value)
            listeners.forEach {
                $0(value)
            }
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
    
    //private var listner: ((T?) -> Void)?
    private var listeners: [((T?) -> Void)] = []
    
    func bind(_ listner: @escaping((T?) -> Void)){
        listner(value)
        //self.listner = listner
        self.listeners.append(listner)
    }
}

//struct User: Codable {
//    var name: String
//}
struct User: Codable {
    let id: Int
    let name, username, email: String
    let address: Address
    let phone, website: String
    //let company: Company
}



// MARK: - Address
struct Address: Codable {
    let street, suite, city, zipcode: String
    //let geo: Geo
}

struct UserListViewModel {
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel {
    var name: String
}


class ViewController: UIViewController {
    
    var viewModel = UserListViewModel()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        viewModel.users.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        fetchData()
    }
    

    func fetchData(){
        let url: URL = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else{ return}
            do{
                let userModels = try JSONDecoder().decode([User].self, from: data)
                self.viewModel.users.value = userModels.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            }catch{
                print("error is : \(error)")
            }
        }
        task.resume()
    }


}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
    
}

