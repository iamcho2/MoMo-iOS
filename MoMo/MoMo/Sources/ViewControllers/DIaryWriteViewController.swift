//
//  DiaryWriteViewController.swift
//  MoMo
//
//  Created by 이정엽 on 2021/01/10.
//

import UIKit

protocol DiaryWriteViewControllerDelegate: class {
    func popDiaryWirteViewController(data: DiaryInfo)
}

enum NavigationButton: Int {
    case leftButton = 0, rightButton
}

class DiaryWriteViewController: UIViewController {
    
    // MARK: - Properties
    
    var date: String = "2020. 12. 26 토요일"
    var emotionImageName: String = "icAngry14Black"
    var emotion: String = "화남"
    var author: String = "구병모"
    var book: String = "파괴"
    var publisher: String = "위즈덤 하우스"
    var quote: String = "접입가경, 이게 웬 심장이 콧구멍으로 쏟아질 얘긴가 싶지만 그저 지레짐작이나 얻어걸린 이야기일 가능성이 더 많으니 조각은 표정을 바꾸지 않는다."
    var journal: String = ""
    var placeHolder: NSMutableAttributedString = NSMutableAttributedString()
    var isFromDiary: Bool = false
    var diaryInfo: DiaryInfo?
    var alertModalView: AlertModalView?
    weak var diaryWriteViewControllerDelegate: DiaryWriteViewControllerDelegate?
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emotionImage: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var featherImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var depthImage: UIImageView!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var quoteLabelTopConstraint: NSLayoutConstraint!
    
    lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: Constants.Design.Image.btnBackWhite, style: .plain, target: self, action: #selector(buttonPressed(sender:)))
        button.tintColor = UIColor.Black1
        button.tag = NavigationButton.leftButton.rawValue
        return button
    }()
    
    lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(buttonPressed(sender:)))
        button.tag = NavigationButton.rightButton.rawValue
        button.tintColor = UIColor.systemBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertModalView = AlertModalView.instantiate(
            alertLabelText: "수정한 일기가 저장되지 않습니다.\n정말 뒤로 가시겠어요?",
            leftButtonTitle: "취소",
            rightButtonTitle: "확인"
        )
        
        self.journalTextView.delegate = self
        
        self.setWordSpace()
        
        if isFromDiary {
            self.setValuesFromDiaryView()
            self.depthImage.isHidden = false
            self.depthLabel.isHidden = false
        } else {
            self.setPlaceholder()
            journalTextView.attributedText = placeHolder
            self.depthImage.isHidden = true
            self.depthLabel.isHidden = true
        }
        
        self.navigationItem.leftBarButtonItem = self.leftButton
    }
    
    // MARK: - IBAction
    
    @IBAction func tapBackground(_ sender: Any) {
        self.journalTextView.endEditing(true)
    }
    
    @IBAction func touchMoreButton(_ sender: Any) {
        self.shrinkQuoteLabel()
    }
    
    // MARK: - Private function for settings
    
    private func setValuesFromDiaryView() {
        self.dateLabel.text = diaryInfo?.date
        self.emotionImage.image = diaryInfo?.mood.toIcon()
        self.emotionLabel.text = diaryInfo?.mood.toString()
        self.depthLabel.text = diaryInfo?.depth.toString()
        self.authorLabel.text = diaryInfo?.sentence.author
        self.bookLabel.text = diaryInfo?.sentence.bookTitle
        self.quoteLabel.text = diaryInfo?.sentence.sentence
        self.journalTextView.text = diaryInfo?.diary
    }
    
    private func setWordSpace() {
        self.dateLabel.attributedText = self.date.wordSpacing(-0.6)
        self.emotionImage.image = UIImage(named: self.emotionImageName)
        self.emotionLabel.attributedText = self.emotion.wordSpacing(-0.6)
        self.authorLabel.attributedText = self.author.wordSpacing(-0.6)
        self.bookLabel.attributedText = "<\(book)>".wordSpacing(-0.6)
        self.publisherLabel.attributedText = "(\(publisher))".wordSpacing(-0.6)
        
        let attributedString = NSMutableAttributedString(string: self.quote)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: -0.6, range: NSRange(location: 0, length: attributedString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        paragraphStyle.lineSpacing = 4
        
        self.quoteLabel.attributedText = attributedString
    }
    
    private func setPlaceholder() {
        let text = "파동을 충분히 느낀 후, 감정을 기록해보세요."
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: -0.6, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Blue3, range: NSRange(location: 0, length: attributedString.length))
        
        self.placeHolder = attributedString
    }
    
    private func coordinateTextView() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attribute: [NSAttributedString.Key: Any] = [
            .kern: -0.6,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.Black3List
        ]
        
        return attribute
    }
    
    private func shrinkQuoteLabel() {
        if quoteLabel.text == "" {
            UIView.animate(withDuration: 0.5) {
                self.moreButton.transform = CGAffineTransform(rotationAngle: -.pi*2)
                self.quoteLabel.text = self.quote
                self.quoteLabelTopConstraint.constant = 24
            }
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.moreButton.transform = CGAffineTransform(rotationAngle: .pi)
                self.quoteLabel.text = ""
                self.quoteLabelTopConstraint.constant = 0
            }
            
        }
    }
    
    @objc private func buttonPressed(sender: Any) {
        if let button = sender as? UIBarButtonItem {
            switch button.tag {
            case NavigationButton.leftButton.rawValue:
                self.popDiaryWirteViewController()
            case NavigationButton.rightButton.rawValue:
                self.saveDiary()
            default:
                print("error")
            }
        }
    }
    
    func saveDiary() {
        self.diaryInfo?.diary = journalTextView.text
        self.postDiaryWithAPI {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - 서버로 다이어리 저장해야함
    
    func postDiaryWithAPI(completion: @escaping () -> Void) {
        // 저장이 완료되면 실행함
        DispatchQueue.main.async {
            print("텍스트 업데이트 완료")
            completion()
        }
    }
    
    func popDiaryWirteViewController() {
        if self.diaryInfo?.diary != self.journalTextView.text {
            self.attachAlertModalView()
        } else {
            self.passDataAndPopViewController()
        }
    }
    
    func passDataAndPopViewController() {
        if let diaryInfo = self.diaryInfo {
            self.diaryWriteViewControllerDelegate?.popDiaryWirteViewController(data: diaryInfo)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func attachAlertModalView() {
        if let alertModalView = self.alertModalView {
            alertModalView.alertModalDelegate = self
            self.view.insertSubview(alertModalView, aboveSubview: self.view)
            alertModalView.setConstraints(view: alertModalView, superView: self.view)
        }
    }
}

// MARK: - UITextViewDelegate

extension DiaryWriteViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if self.journalTextView.text == "파동을 충분히 느낀 후, 감정을 기록해보세요." {
            self.journalTextView.text = ""
            self.journalTextView.typingAttributes = coordinateTextView()
        }
        
        if self.quoteLabel.text == "" {
            return true
        }
        
        self.shrinkQuoteLabel()
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.journalTextView.text == "" {
            self.journalTextView.attributedText = self.placeHolder
        }
        
        self.journal = journalTextView.text
        
        self.navigationItem.rightBarButtonItem = self.rightButton
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.navigationItem.rightBarButtonItem == nil {
            self.navigationItem.rightBarButtonItem = self.rightButton
        }
    }
}

// MARK: - diaryWriteViewControllerDelegate

extension DiaryWriteViewController: AlertModalDelegate {
    
    func leftButtonTouchUp(button: UIButton) {
        self.alertModalView?.removeFromSuperview()
    }
    
    func rightButtonTouchUp(button: UIButton) {
        self.passDataAndPopViewController()
    }
}
