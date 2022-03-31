//
//  ViewController.swift
//  ToDoList
//
//  Created by Whyeon on 2022/03/30.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
    }

    @IBAction func tabEditButton(_ sender: UIBarButtonItem) {
        
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
        return cell
        // 작성후 등록 버튼에서 다시 리로드 되도록 코드작성.
    }
}

