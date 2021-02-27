//
//  OnboardingSentenceViewController.swift
//  MoMo
//
//  Created by Haeseok Lee on 2021/01/07.
//

import UIKit

enum SentenceViewUsage: Int {
    case onboarding = 0, upload
}

class SentenceViewController: UIViewController {
    
    // MARK: - @IBOutlet Properties

    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var moodIcon: UIImageView!
    
    @IBOutlet weak var firstAuthorLabel: UILabel!
    @IBOutlet weak var firstBookTitleLabel: UILabel!
    @IBOutlet weak var firstPublisherLabel: UILabel!
    @IBOutlet weak var firstSentenceLabel: UILabel!
            
    @IBOutlet weak var secondAuthorLabel: UILabel!
    @IBOutlet weak var secondBookTitleLabel: UILabel!
    @IBOutlet weak var secondPublisherLabel: UILabel!
    @IBOutlet weak var secondSentenceLabel: UILabel!
    
    @IBOutlet weak var thirdAuthorLabel: UILabel!
    @IBOutlet weak var thirdBookTitleLabel: UILabel!
    @IBOutlet weak var thirdPublisherLabel: UILabel!
    @IBOutlet weak var thirdSentenceLabel: UILabel!
    
    @IBOutlet weak var circleImageView: UIImageView!
    
    // MARK: - Properties
    
    var date: String?
    var selectedMood: AppEmotion?
    var sentenveViewUsage: SentenceViewUsage = .onboarding
    private let info: String = "감정과 어울리는 문장을\n매일 3개씩 소개해드릴게요"
    private let shadowOffsetButton: CGSize = CGSize(width: 4, height: 4)
    private var buttons: [MoodButton] = []
    private var firstSentence: AppSentence?
    private var secondSentence: AppSentence?
    private var thirdSentence: AppSentence?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeSentenceViewController()
        self.initializeNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showButtonsWithAnimation()
        
        switch self.sentenveViewUsage {
        case .onboarding:
            return
        case .upload:
            self.showImagesWithAnimation()
        }
    }
    
    // MARK: - Functions
    
    private func initializeSentenceViewController() {
        
        self.initializeButtons()
        self.infoLabel.text = self.info
        self.moodLabel.text = self.selectedMood?.toString()
        self.moodIcon.image = self.selectedMood?.toIcon()
        self.dateLabel.text = self.date
        guard let emotionId = self.selectedMood?.rawValue else { return }
        
        switch self.sentenveViewUsage {
        case .onboarding:
            self.hideImages()
            self.getOnboardingSentenceWithAPI(emotionId: emotionId, completion: updateSentenceLabel)
        case .upload:
            self.getSentencesWithAPI(emotionId: String(emotionId), userId: String(APIConstants.userId), completion: updateSentenceLabel)
        }
    }
    
    private func initializeNavigationBar() {
        self.navigationItem.hidesBackButton = true
        
        switch self.sentenveViewUsage {
        case .onboarding:
            return
        case .upload:
            self.addNavigationRightButton()
            self.addNavigationLeftButton()
        }
    }
    
    private func initializeButtons() {
        self.buttons = [
            MoodButton(button: firstButton, shadowOffset: shadowOffsetButton),
            MoodButton(button: secondButton, shadowOffset: shadowOffsetButton),
            MoodButton(button: thirdButton, shadowOffset: shadowOffsetButton)
        ]
        
        for button in buttons {
            button.buttonsRoundedUp()
            button.buttonsAddShadow()
        }
        
        self.hideButtons()
    }
    
    private func updateSentenceLabel() {
        self.firstAuthorLabel.text = self.firstSentence?.author
        self.firstBookTitleLabel.text = self.changeToformattedText("<", self.firstSentence?.bookTitle, ">")
        self.firstPublisherLabel.text = self.changeToformattedText("(", self.firstSentence?.publisher, ")")
        self.firstSentenceLabel.text = self.firstSentence?.sentence
            
        self.secondAuthorLabel.text = self.secondSentence?.author
        self.secondBookTitleLabel.text = self.changeToformattedText("<", self.secondSentence?.bookTitle, ">")
        self.secondPublisherLabel.text = self.changeToformattedText("(", self.secondSentence?.publisher, ")")
        self.secondSentenceLabel.text = self.secondSentence?.sentence
            
        self.thirdAuthorLabel.text = self.thirdSentence?.author
        self.thirdBookTitleLabel.text = self.changeToformattedText("<", self.thirdSentence?.bookTitle, ">")
        self.thirdPublisherLabel.text = self.changeToformattedText("(", self.thirdSentence?.publisher, ")")
        self.thirdSentenceLabel.text = self.thirdSentence?.sentence
    }
    
    private func changeToformattedText(_ start: String, _ message: String?, _ end: String) -> String {
        guard let safeMessage = message else { return "" }
        return "\(start)\(safeMessage)\(end)"
    }
    
    private func touchBotton(sentence: AppSentence) {
        switch self.sentenveViewUsage {
        case .onboarding:
            pushToOnboardingWriteViewController(sentence: sentence)
        case .upload:
            guard let mood = selectedMood, let date = self.dateLabel.text else { return }
            pushToDiaryWriteViewController(date: date, mood: mood, sentence: sentence)
        }
    }
    
    @IBAction func touchFirstButton(_ sender: UIButton) {
        guard let firstSentence = self.firstSentence else { return }
        self.touchBotton(sentence: firstSentence)
    }
    
    @IBAction func touchSecondButton(_ sender: UIButton) {
        guard let secondSentence = self.secondSentence else { return }
        self.touchBotton(sentence: secondSentence)
    }
    
    @IBAction func touchThirdButton(_ sender: UIButton) {
        guard let thirdSentence = self.thirdSentence else { return }
        self.touchBotton(sentence: thirdSentence)
    }
    
    private func pushToOnboardingWriteViewController(sentence: AppSentence) {
        
        guard let onboardingWriteViewController = self.storyboard?.instantiateViewController(identifier: Constants.Identifier.onboardingWriteViewController) as? OnboardingWriteViewController else { return }
        
        onboardingWriteViewController.selectedSentence = sentence
        onboardingWriteViewController.selectedMood = self.selectedMood
        
        self.navigationController?.pushViewController(onboardingWriteViewController, animated: true)
        
    }
    
    private func pushToDiaryWriteViewController(date: String, mood: AppEmotion, sentence: AppSentence) {
        let diaryWriteStoryboard = UIStoryboard(name: Constants.Name.diaryWriteStoryboard, bundle: nil)
        guard let diaryWriteViewController = diaryWriteStoryboard.instantiateViewController(identifier: Constants.Identifier.diaryWriteViewController) as? DiaryWriteViewController else {
            return
        }
        let diaryInfo = AppDiary(
            date: AppDate(formattedDate: date, with: ". "),
            mood: mood,
            depth: nil,
            sentence: sentence,
            diary: nil
        )
        diaryWriteViewController.diaryInfo = diaryInfo
        diaryWriteViewController.isFromDiary = false
        
        self.navigationController?.pushViewController(diaryWriteViewController, animated: true)
    }
    
    private func hideButtons() {
        for button in self.buttons {
            button.button?.alpha = 0.0
        }
    }
    
    private func hideImages() {
        self.circleImageView.alpha = 0.0
    }
    
    private func showButtonsWithAnimation() {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            animations: {
                for button in self.buttons {
                    button.button?.alpha = 1.0
                }
            }
        )
    }
    
    private func showImagesWithAnimation() {
        UIView.animate(
            withDuration: 1.0,
            animations: {
                self.circleImageView.alpha = 1.0
                self.circleImageView.transform = CGAffineTransform(translationX: 0, y: 30)
            }
        )
    }
    
    private func addNavigationRightButton() {
        let rightButton = UIBarButtonItem(image: Constants.Design.Image.btnCloseBlack, style: .plain, target: self, action: #selector(touchCloseButton))
        self.navigationItem.rightBarButtonItems = [rightButton]
    }
    
    private func addNavigationLeftButton() {
        let leftButton = UIBarButtonItem(image: Constants.Design.Image.btnBackBlack, style: .plain, target: self, action: #selector(touchBackButton))
        leftButton.tintColor = .black
        self.navigationItem.leftBarButtonItems = [leftButton]
    }
    
    private func popToHomeViewController() {
        guard let homeViewController = self.navigationController?.viewControllers.filter({$0 is HomeViewController}).first! as? HomeViewController else {
            return
        }
        self.navigationController?.popToViewController(homeViewController, animated: true)
    }
    
    @objc func touchCloseButton() {
        self.popToHomeViewController()
    }
    
    @objc func touchBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - APIServices

extension SentenceViewController {
    
    private func getSentencesWithAPI(emotionId: String, userId: String, completion: @escaping () -> Void) {
        SentencesService.shared.getSentences(emotionId: emotionId, userId: userId) { networkResult in
            switch networkResult {
            case .success(let data):
                if let serverData = data as? [Sentence] {
                    self.firstSentence = AppSentence(
                        id: serverData[0].id,
                        author: serverData[0].writer,
                        bookTitle: serverData[0].bookName,
                        publisher: serverData[0].publisher,
                        sentence: serverData[0].contents
                    )
                    self.secondSentence = AppSentence(
                        id: serverData[1].id,
                        author: serverData[1].writer,
                        bookTitle: serverData[1].bookName,
                        publisher: serverData[1].publisher,
                        sentence: serverData[1].contents
                    )
                    self.thirdSentence = AppSentence(
                        id: serverData[2].id,
                        author: serverData[2].writer,
                        bookTitle: serverData[2].bookName,
                        publisher: serverData[2].publisher,
                        sentence: serverData[2].contents
                    )
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            case .requestErr(let errorMessage):
                print(errorMessage)
            case .pathErr:
                print("pathErr in getSentencesWithAPI")
            case .serverErr:
                print("serverErr in getSentencesWithAPI")
            case .networkFail:
                print("networkFail in getSentencesWithAPI")
            }
        }
    }
    
    private func getOnboardingSentenceWithAPI(emotionId: Int, completion: @escaping () -> Void) {
        OnboardingService.shared.getOnboardingWithEmotionId(emotionId: emotionId) { (result) in
            switch result {
            case .success(let data):
                if let sentences = data as? OnboardingSentence {
                    self.firstSentence = AppSentence(
                        author: sentences.sentence01.writer,
                        bookTitle: sentences.sentence01.bookName,
                        publisher: sentences.sentence01.publisher,
                        sentence: sentences.sentence01.contents
                    )
                    self.secondSentence = AppSentence(
                        author: sentences.sentence02.writer,
                        bookTitle: sentences.sentence02.bookName,
                        publisher: sentences.sentence02.publisher,
                        sentence: sentences.sentence02.contents
                    )
                    self.thirdSentence = AppSentence(
                        author: sentences.sentence03.writer,
                        bookTitle: sentences.sentence03.bookName,
                        publisher: sentences.sentence03.publisher,
                        sentence: sentences.sentence03.contents
                    )
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            case .requestErr(let errorMessage):
                print(errorMessage)
            case .pathErr:
                print("pathErr in getOnboardingSentenceWithAPI")
            case .serverErr:
                print("serverErr in getOnboardingSentenceWithAPI")
            case .networkFail:
                print("networkFail in getOnboardingSentenceWithAPI")
            }
        }
    }
}
