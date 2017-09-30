//
//  ViewController.swift
//  Pairing
//
//  Created by Yaqing Wang on 28/09/2017.
//  Copyright © 2017 Yaqing Wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import CoreMotion

class ViewController: UIViewController {
    fileprivate let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()

    lazy var table: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(table)
        table.snp.makeConstraints({ [unowned self] (make) in
            make.edges.equalTo(self.view)
        })
        table.tableFooterView = UIView()
        
        table.backgroundColor = UIColor(rgba: "#F8F8F8")
        table.rowHeight = 50
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: String(describing: PairTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PairTableViewCell.self))
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setRightNavigationItem("Manage") { [weak self] in
            self?.slideMenuController()?.openRight()
        }
        
        setLeftNavigationItem("Pair") { [weak self] in
            self?.viewModel.generatePairs(includeInactivePerson: false)
        }
        
        bindViewModel()
        viewModel.generatePairs(includeInactivePerson: false)
        navigationItem.title = "Find your pair"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.resignFirstResponder()
        super.viewWillDisappear(animated)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            delayInMainQueue(0.5, closure: {
                SoundEffectManager.shareInstance.playEffect()
                self.viewModel.generatePairs(includeInactivePerson: false)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func bindViewModel() {
        viewModel.pairs.asDriver().drive(onNext: { [weak self] pairs in
            //TODO: reload table
            self?.table.reloadData()
        }).addDisposableTo(disposeBag)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PairTableViewCell.self)) as! PairTableViewCell
        
        cell.pair = viewModel.pairs.value[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pairs.value.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 1.5, y: 1.2)
        UIView.animate(withDuration: 1) {
            cell.transform = CGAffineTransform.identity
        }
    }

}

func delayInMainQueue(_ delay: Double, closure:@escaping ()->Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure
    )
}

