//
//  ViewController.swift
//  MCRestfireExample
//
//  Created by Miller Mosquera on 30/08/23.
//

import UIKit

protocol ViewProtocol: AnyObject {
    func getResult(data: String)
}

class ViewController: UIViewController, ViewProtocol {

    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Seconds: __"
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let responseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loading: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.tintColor = .black
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    let btnDone: UIButton = {
        let button = UIButton()
        button.setTitle("Request Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        return button
    }()
    
    let btnFailed: UIButton = {
        let button = UIButton()
        button.setTitle("Request Fail", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        return button
    }()
    
    let btnTimeOut: UIButton = {
        let button = UIButton()
        button.setTitle("Request TimeOut", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        return button
    }()
    
    lazy var arrangeView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10

        stackView.addArrangedSubview(btnDone)
        stackView.addArrangedSubview(btnFailed)
        stackView.addArrangedSubview(btnTimeOut)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var timer = Timer()
    var counter = 0
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        presenter = ExamplePresenter(view: self, repository: ExampleRepository())
        
        setupView()
        setConstraints()
        setEvents()
    }

    func setupView() {
        view.addSubview(arrangeView)
        view.addSubview(timeLabel)
        view.addSubview(loading)
        view.addSubview(responseLabel)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            arrangeView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            arrangeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            arrangeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            arrangeView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: arrangeView.bottomAnchor, constant: 20),
            timeLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            loading.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            loading.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            responseLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            responseLabel.leadingAnchor.constraint(equalTo: loading.trailingAnchor, constant: 5),
            responseLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
    }
    
    func setEvents() {
        btnDone.addTarget(self, action: #selector(repDone), for: .touchUpInside)
        btnFailed.addTarget(self, action: #selector(repFail), for: .touchUpInside)
        btnTimeOut.addTarget(self, action: #selector(repTimeout), for: .touchUpInside)
    }
    
    @objc func timerAction() {
        counter += 1
        timeLabel.text = "Seconds: \(counter)"
    }
    
    @objc func repDone() {
        startTimer()
        loading.startAnimating()
        
        //presenter?.getResult()
        presenter?.getInterest()
    }
    
    @objc func repFail() {

    }
    
    @objc func repTimeout() {
        startTimer()
        loading.startAnimating()
    }
    
    func getResult(data: String) {
        Task { @MainActor in
            responseLabel.text = data
            loading.stopAnimating()
            timer.invalidate()
            timeLabel.text = "It tooks: \(counter) sec"
        }

    }
}

