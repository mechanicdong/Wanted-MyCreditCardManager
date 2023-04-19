//
//  main.swift
//  MyCreditManager
//
//  Created by 이동희 on 2023/04/17.
//

import Foundation

final class MyCreditManager {
    let studentManager = StudentManager()
    static let shared = MyCreditManager()
    
    public func start() {
        var userInput = ""
        
        while userInput != UserInputCase.exit.rawValue {
            print("원하는 기능을 입력해주세요")
            print("1: 학생추가, 2: 학생삭제, 3: 성적추가(변경), 4: 성적삭제, 5: 평점보기, X: 종료")
            userInput = readLine() ?? ""
            
            guard let type = UserInputCase(rawValue: userInput) else {
                print("잘못된 입력입니다.")
                return
            }
            
            if validateInput(type.rawValue) {
                switch type {
                case .addStudent:
                    studentManager.addStudent()
                case .removeStudent:
                    studentManager.removeStudent()
                case .addGrade:
                    studentManager.addGrade()
                case .removeGrade:
                    studentManager.removeGrade()
                case .getAllGrade:
                    studentManager.getAverageGrade()
                case .exit:
                    print("프로그램을 종료합니다...")
                    break
                }
            }
        }
    }
    
    private func validateInput(_ input: String) -> Bool {
        return input.range(of: "[^0-9a-zA-Z]", options: .regularExpression) == nil && !input.isEmpty
    }
}

final class StudentManager {
    var studentList: [Student] = []
    
    /// Input Error 커스텀
    /// StudentManager 내부에서만 사용하므로 private
    private enum InputError: Error {
        case invalidStudentName
        case invalidInfos(String)
    }
    
    // MARK: 학생 추가
    public func addStudent() {
        print("추가할 학생의 이름을 입력해주세요")
        let studentName = readStudentName()
        addStudentName(studentName)
    }
    
    // MARK: 학생 삭제
    public func removeStudent() {
        print("삭제할 학생의 이름을 입력해주세요")
        let studentName = readStudentName()
        removeStudentWhenAdded(studentName)
    }
    
    // MARK: 성적 추가
    public func addGrade() {
        print("성적을 추가할 학생의 이름, 과목 이름, 성적(A+, A, F 등)을 띄어쓰기로 구분하여 차례로 작성해주세요.")
        guard let studentInfos = readStudentInfos(3) else { return }
        setGrade(studentInfos)
    }
    
    // MARK: 성적 삭제
    public func removeGrade() {
        print("성적을 삭제할 학생의 이름, 과목 이름을 띄어쓰기로 구분하여 차례로 작성해주세요.")
        guard let subject = readStudentInfos(2) else { return }
        removeGrade(subject)
    }
    
    // MARK: 평점 보기
    public func getAverageGrade() {
        print("평점을 알고싶은 학생의 이름을 입력해주세요")
        let studentName = readStudentName()
        startCheckAverage(studentName)
    }
    
    /// 성적 추가 할 경우 Input 정합성 체크
    /// - Parameters:
    ///   - count: 입력 개수
    /// - Returns:
    ///   - Student: 성적이 입력된 Student 객체
    private func readStudentInfos(_ count: Int) -> Student? {
        let input = readLine() ?? ""
        let infos = input.components(separatedBy: " ") // [String]
        do {
            return try validateInfos(infos, count)
        } catch {
            print("\(error)")
        }
        return nil
    }
    
    /// 성적 추가 / 성적 삭제 시 입력받은 문자열 체크
    /// - Parameters:
    ///   - infos: 입력받은 문자열
    ///   - count: 확인할 개수
    ///   - 성적 추가면 3개(이름, 과목, 성적)
    ///   - 성적 삭제면 2개(이름, 과목)
    private func validateInfos(_ infos: [String], _ count: Int) throws -> Student? {
        guard infos.count == count else { throw InputError.invalidInfos("입력 개수가 맞지 않습니다.") }
        do {
            try validateStudentName(infos[0])
            if checkStudentIsAdded(infos[0]) {
                throw InputError.invalidInfos("존재하지 않는 학생은 성적을 추가할 수 없습니다.")
            }
            try validateStudentName(infos[1])
        } catch {
            throw InputError.invalidInfos("이름 혹은 과목의 입력이 잘못되었습니다. 다시 확인해주세요.")
        }
        
        if count >= 3 {
            if Rating(rawValue: infos[2])?.rawValue == nil  {
                throw InputError.invalidInfos("성적의 입력이 잘못되었습니다. 다시 확인해주세요.")
            }
            return Student(name: infos[0], grade: [Grade(subject: infos[1], rating: Rating(rawValue: infos[2]))])
        }
        return Student(name: infos[0], grade: [Grade(subject: infos[1], rating: nil)])
    }
    
    /// 학생의 이름 입력
    private func readStudentName() -> String {
        let input = readLine() ?? ""
        do {
            try validateStudentName(input)
        } catch {
            print("입력이 잘못되었습니다. 다시 확인해주세요.")
            manager.start()
        }
        return input
    }
    
    /// 학생의 이름을 입력받을 때 정합성 체크
    private func validateStudentName(_ input: String) throws {
        guard input.range(of: "[^0-9a-zA-Z]", options: .regularExpression) == nil && !input.isEmpty else {
            throw InputError.invalidStudentName
        }
    }
    
    /// 학생 추가
    /// - Parameters:
    ///   - name: 추가할 학생의 이름
    ///   - 학생이 있는지 확인 후 등록
    private func addStudentName(_ name: String) {
        if checkStudentIsAdded(name) {
            studentList.append(Student(name: name, grade: nil))
            print("\(name) 학생을 추가했습니다.")
        } else {
            print("\(name)은 이미 존재하는 학생입니다. 추가하지 않습니다.")
        }
    }
    
    /// 학생 삭제
    /// - Parameters:
    ///   - name: 삭제할 학생의 이름
    private func removeStudentWhenAdded(_ name: String) {
        if checkStudentIsAdded(name) {
            print("\(name) 학생을 찾지 못했습니다.")
        } else {
            studentList = studentList.filter { $0.name != name }
            print("\(name) 학생을 삭제하였습니다.")
        }
    }
    
    /// 학생 유무 판단
    /// - Parameters:
    ///   - name: 확인할 학생의 이름
    /// - Returns: 학생이 없다면 true
    private func checkStudentIsAdded(_ name: String) -> Bool {
        return studentList.filter { $0.name == name }.count == 0 ? true : false
    }
    
    /// 성적 추가
    /// - Parameters:
    ///   - infos: 학생 객체(이름/과목)
    ///   - 성적이 하나도 없다면 덮어씌우고
    ///   - 성적이 있다면 추가
    private func setGrade(_ infos: Student) {
        if studentList.filter({ $0.name == infos.name }).first!.grade == nil
        {
            studentList.filter({ $0.name == infos.name}).first?.grade = infos.grade
        } else {
            guard let willAddedGrade = infos.grade else { return }
            studentList.filter({ $0.name == infos.name}).first?.grade?.append(willAddedGrade[0])
        }
    }
    
    /// 성적 제거
    /// - Parameters:
    ///   - infos: 학생 객체(이름/과목)
    ///   - 현재 특정 학생이 등록된 경우에만 삭제
    ///   - 삭제하려는 과목이 없다면 리턴
    private func removeGrade(_ infos: Student) {
        guard let removedGrade = infos.grade else { return }
        if let index = studentList.firstIndex(where: {
            $0.name == infos.name
        }) {
            guard let targetGradeIndex = studentList[index].grade?.firstIndex(where: {
                $0.subject == removedGrade[removedGrade.startIndex].subject
            }) else { return }
            studentList[index].grade?.remove(at: targetGradeIndex)
        }
    }
    
    /// 학생의 평점 Entry
    /// - Parameters:
    ///   - student: 학생의 이름
    private func startCheckAverage(_ student: String) {
        if checkStudentIsAdded(student) {
           print("\(student) 학생을 찾지 못했습니다.")
        } else {
            guard let grades = checkHasGrades(student) else { return }
            let average = calculateGradeAverage(grades)
            print("\(student)")
            grades.forEach {
                print("\($0.subject): \($0.rating!.rawValue)")
            }
            print("평점: \(average)")
        }
    }
    
    /// 성적 유무 판단
    /// - Parameters:
    ///    - student: 학생의 이름
    /// - Returns: 해당 학생의 성적 / 없으면 프로그램 초기로 돌아감
    private func checkHasGrades(_ student: String) -> [Grade]? {
        guard let targetStudent = studentList.first(where: { $0.name == student }),
              let grades = targetStudent.grade else {
            print("\(student) 학생은 보유중인 성적이 없습니다.")
            manager.start()
            return nil
        }
        return grades
    }
    
    /// 성적 평점 계산
    ///  - Parameters:
    ///     - grades: 해당 학생이 가진 성적
    ///  - Returns: 소수점 2자리까지의 평점
    private func calculateGradeAverage(_ grades: [Grade]) -> String {
        var sum: Double = 0
        grades.forEach {
            switch $0.rating {
            case .APlus:
                sum += 4.5
            case .A:
                sum += 4.0
            case .BPlus:
                sum += 3.5
            case .B:
                sum += 3.0
            case .CPlus:
                sum += 2.5
            case .C:
                sum += 2.0
            case .F:
                sum += 0
            default:
                break
            }
        }
        return String(format: "%.2f", sum/Double(grades.count))
    }
}


let manager = MyCreditManager.shared
manager.start()

