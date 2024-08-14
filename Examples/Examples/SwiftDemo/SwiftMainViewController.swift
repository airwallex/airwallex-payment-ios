//
//  SwiftMainViewController.swift
//  SwiftExamples
//
//  Created by Tony He (CTR) on 2024/8/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

// import Airwallex
import UIKit

class SwiftMainViewController: UIViewController {
    private lazy var flowWithUIButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("integrate with Airwallex UI", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var flowWithoutUIButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("integrate with low level API", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var h5DemoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("H5Demo", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var wechatDemoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("WeChat Demo", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var shippingButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Shipping", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 24)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(mainButtonTapped(_:)), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var shipping: AWXPlaceDetails?
    private var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAirwallexSDK()
        setupCartData()
        setupExamplesAPIClient()
    }

    private func setupAirwallexSDK() {
        // Step 1: Use a preset mode (Note: test mode as default)
        //    [Airwallex setMode:AirwallexSDKTestMode];
        // Or set base URL directly
        let mode = AirwallexExamplesKeys.shared().environment
        Airwallex.setMode(mode)

        // You can disable sending Analytics data or printing local logs
//        Airwallex.disableAnalytics()

        // you can enable local log file
//        Airwallex.enableLocalLogFile()

        // Theme customization
//        AWXTheme.shared().tintColor = UIColor.systemPink
    }

    private func setupViews() {
        navigationItem.rightBarButtonItem = .init(title: "Settings", style: .plain, target: self, action: #selector(settingTapped))

        view.addSubview(flowWithUIButton)
        view.addSubview(flowWithoutUIButton)
        view.addSubview(h5DemoButton)
        view.addSubview(wechatDemoButton)
        view.addSubview(shippingButton)

        NSLayoutConstraint.activate([
            flowWithUIButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            flowWithUIButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            flowWithUIButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            flowWithUIButton.heightAnchor.constraint(equalToConstant: 50),

            flowWithoutUIButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            flowWithoutUIButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            flowWithoutUIButton.topAnchor.constraint(equalTo: flowWithUIButton.bottomAnchor, constant: 20),
            flowWithoutUIButton.heightAnchor.constraint(equalToConstant: 50),

            h5DemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            h5DemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            h5DemoButton.topAnchor.constraint(equalTo: flowWithoutUIButton.bottomAnchor, constant: 20),
            h5DemoButton.heightAnchor.constraint(equalToConstant: 50),

            wechatDemoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            wechatDemoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            wechatDemoButton.topAnchor.constraint(equalTo: h5DemoButton.bottomAnchor, constant: 20),
            wechatDemoButton.heightAnchor.constraint(equalToConstant: 50),

            shippingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            shippingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            shippingButton.topAnchor.constraint(equalTo: wechatDemoButton.bottomAnchor, constant: 20),
            shippingButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupCartData() {
        let product0 = Product(name: "AirPods Pro", detail: "Free engraving x 1", price: 399.0)
        let product1 = Product(name: "HomePod", detail: "White x 1", price: 469.0)
        products = [product0, product1]
        shipping = AWXPlaceDetails(firstName: "Jason", lastName: "Wang", email: nil, dateOfBirth: nil, phoneNumber: "13800000000", address: AWXAddress(countryCode: "CN", city: "Shanghai", street: "Pudong District", state: "Shanghai", postcode: "100000"))
    }

    private func setupExamplesAPIClient() {
        APIClient.shared().apiKey = AirwallexExamplesKeys.shared().apiKey
        APIClient.shared().clientID = AirwallexExamplesKeys.shared().clientId
    }

    @objc func mainButtonTapped(_ button: UIButton) {
        switch button {
        case flowWithUIButton:
            showFlowWithUI()
        case flowWithoutUIButton:
            showFlowWithoutUI()
        case h5DemoButton:
            showH5Demo()
        case wechatDemoButton:
            showWechatDemo()
        case shippingButton:
            showShipping()
        default:
            return
        }
    }

    @objc func settingTapped() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OptionsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showFlowWithUI() {
        let vc = FlowWithUIViewController()
        vc.shipping = shipping
        vc.products = products
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showFlowWithoutUI() {
        let vc = FlowWithoutUIViewController()
        vc.shipping = shipping
        vc.products = products
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showH5Demo() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "InputViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showWechatDemo() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WechatPayViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showShipping() {
        let vc = AWXShippingViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        vc.shipping = shipping
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SwiftMainViewController: AWXShippingViewControllerDelegate {
    func shippingViewController(_ controller: AWXShippingViewController, didEditShipping shipping: AWXPlaceDetails) {
        controller.navigationController?.popViewController(animated: true)
        self.shipping = shipping
    }
}
