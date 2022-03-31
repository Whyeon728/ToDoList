//
//  ViewController.swift
//  ToDoList
//
//  Created by Whyeon on 2022/03/30.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    var doneButton: UIBarButtonItem?
    
    var tasks = [Task]() {
        didSet { // tasks에 할일이 추가될때마다 유저디폴츠에 저장이됨.
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //MARK: - 바 버튼 객체 생성(Done)
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                          action: #selector(doneButtonTap))
        self.doneButton?.style = .plain
        self.tableView.dataSource = self
        
        self.tableView.delegate = self
        self.loadTasks()
    }
    
    // edit 버튼 누르면 Done 버튼으로 바뀌는데 바뀐 Done버튼의 기능
    @objc func doneButtonTap() {
        self.navigationItem.leftBarButtonItem = self.editButton // Done 버튼 누르면 다시 edit 버튼으로 바뀜.
        self.tableView.setEditing(false, animated: false) // 편집모드 빠져나오기
    }

    @IBAction func tabEditButton(_ sender: UIBarButtonItem) {
        
        guard !self.tasks.isEmpty else { return } // 테이블이 비어있지 않을때 밑에 코드 수행
        // edit 버튼 누르면 Done 버튼으로 바뀜.
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true) // 왼쪽에 에딧모양 - 아이콘이 생김.
        
    }
    
    //MARK: - add 버튼 알람 동작

    @IBAction func tabAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: "할 일을 입력해주세요", preferredStyle: .alert)
        
        
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            //weak 키워드를 통해 참조가 아닌 값으로 접근한다 메모리 누수방지; 뷰컨트롤러의 핸들러를 계속해서 가져와야하기 떄문에 누수발생
            // 가져오는 이유는 뷰컨트롤러의 핸들러에 접근해서 tasks프로퍼티에 task를 추가하기위함
            
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData() // 할일이 추가될때마다 테이블을 다시 그려준다.
        })
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 알람창 버튼 두개일시 취소가 기본적으로 왼쪽으로오고
        //액션버튼의 스타일이 모두 디폴트면 addAction한 순서로 생김,
        //3개면 리스트형식으로 나온다.
        alert.addAction(registerButton) //알림창내 등록 버튼 추가
        alert.addAction(cancelButton) //알림창내 취소 버튼 추가
        
        //알람에 텍스트 필드 추가
        // addTextField는 클로저 함수를 매개변수로 받고 configurationHandler는 텍스트필드 객체에 접근
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요" // 안내글씨
        })
        
        //add 버튼 누를시 알림창 발생
        self.present(alert, animated: true, completion: nil) // completion : 프레젠테이션이 끝나고 실행할 블록
    }

    //MARK: - 유저디폴츠 싱글톤 패턴
    //앱에 단 하나만 존재함. 앱종료에도 데이터 살아있게함.
    func saveTasks() {
        let data = self.tasks.map { //tasks 배열을 딕셔너리로 맵핑
            [
                "title":  $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard // 유저디폴츠 인스턴스를 가져옴
        userDefaults.set(data, forKey: "tasks") // 데이터를 세팅해주고 해당 데이터를 "tasks" 라고 부르겠음
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard // 유저디폴츠 인스턴스를 가져옴
        
        // "tasks" 라는 데이터를 불러오고 딕셔너리 형태로 타입 캐스팅한다. 다시 구조체형태로 리턴해준다.
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else {return}
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil}
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
}

//MARK: - 테이블뷰 데이터 소스에 들어갈 내용
extension ViewController: UITableViewDataSource {
    
    // 각 섹션에 표시할 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count // tasks 배열에 등록될 갯수 만큼 행이 생기도록함.
    }
    
    // 특정 섹션의 n번째 로우를 그리는데 필요한 셀을 반환하는 함수
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell 이라는 식별자 이름을 가진 재사용할 셀을 찾고,
        //indexPath 위치에 찾은 셀을 재사용하기 위해 사용.
        // 만약 천개의 셀을 그려야할때, 1000개 셀모두 메모리 할당하면 불필요한 메모리 낭비가 생긴다.
        // 화면에 보일만큼만 dequeue를 하여 셀을 재사용하도록한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row] // indexPath[ section , row ] 현재 한개 섹션에서 작업이 이루어지므로
                                             //  numberOfRowsInSection 에서 정의; row 값은 tasks 배열의 개수 만큼 늘어남.
        
        cell.textLabel?.text = task.title
        
        // 체크 표시 활성화
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        // 작성후 등록 버튼에서 다시 리로드 되도록 코드작성.
    }
    
    //MARK: - 편집모드에서 동작정의
    
    // 편집모드에서 삭제버튼이 눌려진 셀이 어떤 셀인지 알려주는 메소드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row) // 배열에 할일이 삭제되도록함.
        tableView.deleteRows(at: [indexPath], with: .automatic) // 테이블뷰도 행이 삭제되도록함. 스와이프삭제가능
        
        if self.tasks.isEmpty { //배열이 모두 비어있으면 done 버튼 빠져나오기
            self.doneButtonTap()
        }
    }
    
    // 편집모드에서 행을 이동시킬수 있음; 함수만 추가해도 재정렬 아이콘 생성되고 움직일수 있음.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //실데이터 배열도 재정렬되도록 해줌.
        var tasks = self.tasks // 실데이터를 건드리지 않도록 따로 저장
        let task = tasks[sourceIndexPath.row] // 임시로 지금 잡고있는 셀을 복사
        tasks.remove(at: sourceIndexPath.row) // 원래 배열에서 삭제
        tasks.insert(task, at: destinationIndexPath.row) // 이동한 위치로 insert 시켜줌
        self.tasks = tasks // 재정렬 된 값을 저장
    }

}

extension ViewController: UITableViewDelegate { //셀의 액션처리, 섹션 헤더뷰, 푸터뷰 관리; 삭제 편집등 기능제공
    
    // 셀을 선택했을때 어떤 셀을 선택했는지 알려줌
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row] // 배열의 요소에 접근. 첫번째 셀 선택시 indexPath.row 값은 0이됨.
        task.done = !task.done // true 일시 false로 false시 true로 변경시켜줌
        self.tasks[indexPath.row] = task // 실제 데이터에 값을 변경해줌
        self.tableView.reloadRows(at: [indexPath], with: .automatic) // 선택된 셀만 테이블뷰에 리로드 애니메이션 시스템자동.
    }
}
