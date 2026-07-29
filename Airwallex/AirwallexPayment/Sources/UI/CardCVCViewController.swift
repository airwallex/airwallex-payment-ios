//
//  CardCVCViewController.swift
//  AirwallexPayment
//
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

/// Collects CVC/CVV for API-integration consent payments.
final class CardCVCViewController: UIViewController {

    let onComplete: (_ cvc: String, _ cancelled: Bool) -> Void

    private let card: AWXCard?
    private let totalAmountText: String
    private let language: AWXPaymentLanguage
    private let requiredCVCLength: Int

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.keyboardDismissMode = .interactive
        view.contentInsetAdjustmentBehavior = .always
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .awxColor(.textPrimary)
        label.font = .awxFont(.title1, weight: .bold)
        return label
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .awxColor(.textSecondary)
        label.font = .awxFont(.headline1)
        return label
    }()

    private lazy var cvcFieldContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .awxColor(.backgroundPrimary)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = .awxCGColor(.borderDecorative)
        return view
    }()

    private lazy var cvcTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .asciiCapableNumberPad
        field.textColor = .awxColor(.textPrimary)
        field.font = .awxFont(.body1)
        field.delegate = self
        field.addTarget(self, action: #selector(cvcTextDidChange), for: .editingChanged)
        if #available(iOS 17.0, *) {
            field.textContentType = .creditCardSecurityCode
        }
        return field
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.awxColor(.textInverse), for: .normal)
        button.titleLabel?.font = .awxFont(.headline1, weight: .bold)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(payPressed), for: .touchUpInside)
        return button
    }()

    init(
        card: AWXCard?,
        totalAmountText: String,
        language: AWXPaymentLanguage = .english,
        onComplete: @escaping (_ cvc: String, _ cancelled: Bool) -> Void
    ) {
        self.card = card
        self.totalAmountText = totalAmountText
        self.language = language
        self.onComplete = onComplete
        if let brandName = card?.brand,
           let brand = AWXCardValidator.shared().brand(forCardName: brandName) {
            self.requiredCVCLength = AWXCardValidator.cvcLength(for: brand.type)
        } else {
            self.requiredCVCLength = AWXCardValidator.cvcLength(for: .unknown)
        }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .awxColor(.backgroundPrimary)
        setupNavigationItem()
        setupViews()
        setupContent()
        setupGesture()
        updateConfirmButtonAppearance()
        updateConfirmButtonState()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateConfirmButtonAppearance()
        cvcFieldContainer.layer.borderColor = .awxCGColor(.borderDecorative)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cvcTextField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsLogger.log(pageView: .cvcScreen)
    }

    private func setupNavigationItem() {
        let image = UIImage(named: "close", in: .resource())?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.awxColor(.iconPrimary))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(closePressed)
        )
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "close"
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(totalLabel)
        contentView.addSubview(cvcFieldContainer)
        cvcFieldContainer.addSubview(cvcTextField)
        contentView.addSubview(confirmButton)

        let scrollViewBottom: NSLayoutConstraint
        if #available(iOS 15.0, *) {
            // Shrink the scroll view above the keyboard (same effect as ObjC bottomConstraint).
            // Must pin scrollView — not content inside it — to keyboardLayoutGuide.
            scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        } else {
            scrollViewBottom = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollViewBottom,

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.heightAnchor).priority(.defaultHigh - 20),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            totalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            cvcFieldContainer.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 16),
            cvcFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cvcFieldContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.328),
            cvcFieldContainer.heightAnchor.constraint(equalToConstant: 52),

            cvcTextField.leadingAnchor.constraint(equalTo: cvcFieldContainer.leadingAnchor, constant: 16),
            cvcTextField.trailingAnchor.constraint(equalTo: cvcFieldContainer.trailingAnchor, constant: -16),
            cvcTextField.topAnchor.constraint(equalTo: cvcFieldContainer.topAnchor, constant: 4),
            cvcTextField.bottomAnchor.constraint(equalTo: cvcFieldContainer.bottomAnchor, constant: -4),

            confirmButton.topAnchor.constraint(greaterThanOrEqualTo: cvcFieldContainer.bottomAnchor, constant: 16),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    private func setupContent() {
        let strings = Bundle.payment.language(language)

        if let brand = card?.brand, !brand.isEmpty,
           let last4 = card?.last4, !last4.isEmpty {
            let cardInfo = "\(brand.capitalized) •••• \(last4)"
            let format = NSLocalizedString(
                "Enter CVC/CVV for\n%@",
                bundle: strings,
                comment: "CVC title with card brand and last4"
            )
            titleLabel.text = String(format: format, cardInfo)
        } else {
            titleLabel.text = NSLocalizedString(
                "Enter CVC/CVV",
                bundle: strings,
                comment: "CVC title without card details"
            )
        }

        let totalFormat = NSLocalizedString(
            "Total %@",
            bundle: strings,
            comment: "total amount of payment session"
        )
        totalLabel.text = String(format: totalFormat, totalAmountText)

        cvcTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("CVC / CVV", bundle: strings, comment: "CVC / CVV placeholder"),
            attributes: [
                .foregroundColor: UIColor.awxColor(.textPlaceholder),
                .font: UIFont.awxFont(.body1),
            ]
        )

        confirmButton.setTitle(
            NSLocalizedString("Pay now", bundle: strings, comment: "Pay now - pay button"),
            for: .normal
        )

        if let prefilled = card?.cvc, !prefilled.isEmpty {
            cvcTextField.text = String(prefilled.prefix(requiredCVCLength))
        }
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func cvcTextDidChange() {
        updateConfirmButtonState()
    }

    private func updateConfirmButtonState() {
        if card == nil {
            confirmButton.isEnabled = true
            return
        }
        let length = cvcTextField.text?.count ?? 0
        confirmButton.isEnabled = length == requiredCVCLength
    }

    private func updateConfirmButtonAppearance() {
        confirmButton.setBackgroundColor(.awxColor(.backgroundInteractive), for: .normal)
        confirmButton.setBackgroundColor(.awxColor(.borderDecorative), for: .disabled)
        confirmButton.setTitleColor(.awxColor(.textInverse), for: .normal)
    }

    @objc private func payPressed() {
        close(cancelled: false)
        AnalyticsLogger.log(action: .tapPayButton)
    }

    @objc private func closePressed() {
        close(cancelled: true)
    }

    private func close(cancelled: Bool) {
        let completion = { [self] in
            onComplete(cvcTextField.text ?? "", cancelled)
        }
        if presentingViewController != nil {
            dismiss(animated: true, completion: completion)
        } else if let navigationController {
            if navigationController.viewControllers.first === self,
               navigationController.presentingViewController != nil {
                navigationController.dismiss(animated: true, completion: completion)
            } else {
                navigationController.popViewController(animated: true)
                completion()
            }
        } else {
            completion()
        }
    }
}

extension CardCVCViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            return true
        }
        let digits = string.filter(\.isNumber)
        guard digits.count == string.count else {
            return false
        }
        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else {
            return false
        }
        let updated = current.replacingCharacters(in: textRange, with: digits)
        return updated.count <= requiredCVCLength
    }
}

private extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        setBackgroundImage(image, for: state)
    }
}
