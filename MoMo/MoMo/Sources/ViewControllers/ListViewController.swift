//
//  ListViewController.swift
//  MoMo
//
//  Created by 이정엽 on 2020/12/29.
//

import UIKit

class ListViewController: UIViewController {

    // MARK: - Properities
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningPlusButton: UIButton!
    @IBOutlet weak var filterWarningLabel: UILabel!
    
    // MARK: - Constant
    
    let zeplinWidth: Int = 375
    
    // MARK: - Property
    
    var filteredEmotion: Int?
    var filteredDepth: Int?
    var widthSize: CGFloat = 0.0
    var secondWidthSize: CGFloat = 0.0
    var receivedData: [Diary] = []
    var date = ""
    var filter: [String] = []
    var pattern: Bool = false
    var standardYear: Int = 0
    var standardMonth: Int = 0
    var year: Int = 2010
    var month: Int = 5
    var listFilterModalView: ListFilterModalViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        registerXib()
        initializeProperty()
        initializeTableView()
        assignDataSource()
        assignDelegate()
        updateNavigationBarButton()
        initializeWarningLabel()
        getDiariesWithAPI(userID: String(APIConstants.userId), year: String(year), month: String(month), order: "filter", day: nil, emotionID: nil, depth: nil)
    }
    
    // MARK: - Register TableView Cell
    
    private func registerXib() {
        let listcellnib = UINib(nibName: "ListTableViewCell", bundle: nil)
        listTableView.register(listcellnib, forCellReuseIdentifier: "ListTableViewCell")
        listTableView.register(UINib(nibName: "ListDateTableViewCell", bundle: nil), forCellReuseIdentifier: "ListDateTableViewCell")
        listTableView.register(UINib(nibName: "ListFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "ListFilterTableViewCell")
        listTableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
    }
    
    // MARK: - Private Functions
    
    private func initializeProperty() {
//        widthSize = self.view.bounds.width * CGFloat((261/zeplinWidth))
//        secondWidthSize = self.view.bounds.width * CGFloat((237/zeplinWidth))
        widthSize = CGFloat(self.view.bounds.width * (325/414))
        secondWidthSize = CGFloat(self.view.bounds.width * (237/414))
        self.listFilterModalView = ListFilterModalViewController()
        // 홈에서 받은 데이트 변수에 대입
        date = "\(year)년 \(month)월"
        // 필터에서 기준으로 잡을 년과 월 저장
        standardYear = year
        standardMonth = month
    }
    
    private func initializeWarningLabel() {
        filterWarningLabel.text = "검색된 결과가 없습니다"
        warningLabel.text = "아직 작성된 일기가 없습니다.\n새로운 문장을 만나러 가볼까요?"
    }
    
    private func assignDelegate() {
        guard let modalView = listFilterModalView else {
            return
        }
        modalView.modalPassDataDelegate = self
    }
    
    private func assignDataSource() {
        self.listTableView.dataSource = self
    }
    
    private func initializeTableView() {
        self.listTableView.rowHeight  = UITableView.automaticDimension
        self.listTableView.estimatedRowHeight = 266
        self.listTableView.separatorStyle = .none
    }
    
    private func initializeHiddenStatus() {
        warningLabel.isHidden = true
        warningPlusButton.isHidden = true
        filterWarningLabel.isHidden = true
    }
    
    private func updateNavigationBarButton() {
        let statButton = UIBarButtonItem(image: Constants.Design.Image.listBtnGraph, style: .plain, target: self, action: #selector(touchStatButton))
        statButton.tintColor = .black
        let backButton = UIBarButtonItem(image: Constants.Design.Image.btnBackBlack, style: .plain, target: self, action: #selector(touchBackButton))
        backButton.tintColor = .black
        let filterButton: UIBarButtonItem
        if year == standardYear && month == standardMonth && filter.count == 0 {
            filterButton = UIBarButtonItem(image: Constants.Design.Image.listBtnFilterBlack, style: .plain, target: self, action: #selector(touchFilterButton))
            filterButton.tintColor = .black
        } else {
            filterButton = UIBarButtonItem(image: Constants.Design.Image.listBtnFilterBlue, style: .plain, target: self, action: #selector(touchFilterButton))
        }
        self.navigationItem.rightBarButtonItems = [statButton, filterButton]
        self.navigationItem.leftBarButtonItem = backButton
    }
    // MARK: - 서버 통신
    func getDiariesWithAPI(userID: String,
                           year: String,
                           month: String,
                           order: String,
                           day: Int?,
                           emotionID: Int?,
                           depth: Int?) {
        DiariesService.shared.getDiaries(userId: userID,
                                         year: year,
                                         month: month,
                                         order: order,
                                         day: day,
                                         emotionId: emotionID,
                                         depth: depth) {
            (networkResult) -> Void in
            switch networkResult {

            case .success(let data):
                if let diary = data as? [Diary] {
                    print(self.pattern)
                    print(self.receivedData.count)
                    self.receivedData = diary
                    self.listTableView.reloadData()
                    if self.pattern == false && diary.count == 0 && self.year == self.standardYear && self.month ==  self.standardMonth {
                        self.filterWarningLabel.isHidden = true
                        self.warningLabel.isHidden = false
                        self.warningPlusButton.isHidden = false
                    } else if self.pattern == true && diary.count == 0 {
                        self.filterWarningLabel.isHidden = false
                        self.warningLabel.isHidden = true
                        self.warningPlusButton.isHidden = true
                    } else {
                        self.warningLabel.isHidden = true
                        self.warningPlusButton.isHidden = true
                        self.filterWarningLabel.isHidden = true
                    }
                }
                
            case .requestErr(let msg):
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    // MARK: - Selector Functions
    
    // 필터 라벨 외 부분을 터치했을 때 실행되는 함수
    @objc func tapEmptySpace(_ sender: UITapGestureRecognizer) {
        guard let tagNumber = sender.view?.tag else {
            return
        }
        let indexPath = IndexPath(row: 0, section: 1)
        guard let cell = listTableView.cellForRow(at: indexPath) as? ListFilterTableViewCell else {
            return
        }
        filter.remove(at: tagNumber)
        cell.filterCollectionView.reloadData()
        
        if filter.count == 0 {
            pattern.toggle()
            listTableView.reloadData()
            updateNavigationBarButton()
        }
    }
    
    @objc func touchFilterButton() {
        presentToListFilterModalView()
    }
    
    @objc func touchStatButton() {
    }
    
    @objc func touchBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentToListFilterModalView() {
        guard let modalView = listFilterModalView else {
            return
        }
        modalView.selectedYear = self.year
        modalView.selectedMonth = self.month
        modalView.width = view.bounds.width
        modalView.height = view.bounds.height
        modalView.emotion = self.filteredEmotion
        modalView.depth = self.filteredDepth
        modalView.modalPresentationStyle = .custom
        modalView.transitioningDelegate = self
        
        self.present(modalView, animated: true, completion: nil)
    }
    
    // filter x버튼 클릭시 발생하는 함수
    @objc func touchCancelButton(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 1)
        guard let buttonAccessibilityLabel = sender.accessibilityIdentifier else {
            return
        }
        if buttonAccessibilityLabel.contains("m") || buttonAccessibilityLabel == "심해" {
            filteredDepth = nil
        } else {
            filteredEmotion = nil
        }
        guard let cell = listTableView.cellForRow(at: indexPath) as? ListFilterTableViewCell else {
            return
        }
        filter.remove(at: sender.tag)
        if filter.count == 0 {
            pattern.toggle()
            updateNavigationBarButton()
        }
        getDiariesWithAPI(userID: String(APIConstants.userId),
                      year: String(year),
                      month: String(month),
                      order: "filter",
                      day: nil,
                      emotionID: filteredEmotion,
                      depth: filteredDepth)
        cell.filterCollectionView.reloadData()
        
    }
    
    @objc func touchMoreButton(sender: UIButton) {
        pushToDiaryView(sender.tag)
    }
    
    func pushToDiaryView(_ diaryId: Int) {
        let diaryStoryboard = UIStoryboard(name: Constants.Name.diaryStoryboard, bundle: nil)
        
        guard let diaryViewController = diaryStoryboard.instantiateViewController(identifier: Constants.Identifier.diaryViewController) as? DiaryViewController else {
            return
        }
        
        diaryViewController.diaryId = diaryId
        
        self.navigationController?.pushViewController(diaryViewController, animated: true)
    }
    
    @IBAction func touchWarningPlusButton(_ sender: Any) {
        pushToMoodView()
    }
    
    func pushToMoodView() {
        let onboardingStoryboard = UIStoryboard(name: Constants.Name.onboardingStoryboard, bundle: nil)
        
        guard let moodViewController = onboardingStoryboard.instantiateViewController(identifier: Constants.Identifier.moodViewController) as? MoodViewController else {
            return
        }
        moodViewController.listNoDiary = true
        
        self.navigationController?.pushViewController(moodViewController, animated: true)
    }
    
}

// MARK: - TableViewDataSource

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? receivedData.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListDateTableViewCell") as? ListDateTableViewCell else {
                return UITableViewCell()
            }
            cell.setDate(date)
            cell.selectionStyle = .none
            return cell
        case 1:
            if pattern {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListFilterTableViewCell") as? ListFilterTableViewCell else {
                return UITableViewCell()
                }
                cell.filterCollectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
                cell.filterCollectionView.delegate = self
                cell.filterCollectionView.dataSource = self
                cell.selectionStyle = .none
                return cell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell") as? EmptyTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
                
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell") as? ListTableViewCell else {
                return UITableViewCell()
            }
            
            cell.setCell(diary: self.receivedData[indexPath.row])
            cell.quoteSpacing(self.receivedData[indexPath.row].sentence.contents)
            cell.journalView.round(corners: [.topLeft, .bottomLeft], cornerRadius: 20)
            cell.journaltext(self.receivedData[indexPath.row].contents, self.widthSize)
            cell.setLabelUnderline(self.widthSize, self.secondWidthSize)
            cell.moreButton.tag = self.receivedData[indexPath.row].id
            cell.moreButton.addTarget(self, action: #selector(touchMoreButton(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
                
            return cell
        default:
            return UITableViewCell()
            }
        }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let filterOptionCellWidth = filter[indexPath.row].size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)]).width + 34
        return CGSize(width: Int(filterOptionCellWidth), height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.view.frame.width * 8/CGFloat(zeplinWidth)
    }
}

// MARK: - UICollectionViewDataSource

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapEmptySpace(_:)))
        cell.filterLabel.text = filter[indexPath.row]
        // index 값을 tag에 넣어서 배열에 쉽게 접근
        cell.cancelButton.tag = indexPath.row
        cell.cancelButton.accessibilityIdentifier = filter[indexPath.row]
        cell.cancelButton.addTarget(self, action: #selector(touchCancelButton(sender:)), for: .touchUpInside)
        cell.filterTouchAreaView.tag = indexPath.row
        cell.filterTouchAreaView.accessibilityIdentifier = filter[indexPath.row]
        cell.filterTouchAreaView.addGestureRecognizer(tapRecognizer)
        return cell
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ListViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - ListFilterModalViewDelegate
extension ListViewController: ListFilterModalViewDelegate {
    func sendData(year: Int, month: Int, emotion: Int?, depth: Int?, filterArray: [String], filteredStatus: Bool) {
        self.year = year
        self.month = month
        self.filter = filterArray
        self.pattern = filterArray.count == 0 ? false : true
        if year == standardYear && month == standardMonth && filterArray.count == 0 {
            updateNavigationBarButton()
            getDiariesWithAPI(userID: String(APIConstants.userId),
                          year: String(year),
                          month: String(month),
                          order: "filter",
                          day: nil,
                          emotionID: nil,
                          depth: nil)
            let indexPath = IndexPath(row: 0, section: 1)
            guard let cell = listTableView.cellForRow(at: indexPath) as? ListFilterTableViewCell else {
                return
            }
            cell.filterCollectionView.reloadData()
        } else {
            self.filteredDepth = depth
            self.filteredEmotion = emotion
            updateNavigationBarButton()
            getDiariesWithAPI(userID: String(APIConstants.userId),
                          year: String(year),
                          month: String(month),
                          order: "filter",
                          day: nil,
                          emotionID: emotion,
                          depth: depth)
            self.listTableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 1)
            guard let cell = listTableView.cellForRow(at: indexPath) as? ListFilterTableViewCell else {
                return
            }
            cell.filterCollectionView.reloadData()
        }
        self.listFilterModalView = ListFilterModalViewController()
        self.assignDelegate()
    }
}
