//
//  File.swift
//  Popin
//
//  Created by 나리강 on 2/3/24.
//

import UIKit
import FSCalendar

final class DateViewController: BaseViewController {

    let viewModel: DateViewModel?
    
    init(viewModel: DateViewModel?) {
        self.viewModel = viewModel
    }
    
    let mainView = DateView()
    override func loadView() {
        self.view = mainView
    }
    
    override func configure() {
        mainView.calendar.delegate = self
        mainView.calendar.dataSource = self
    }
}

extension DateViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    // 오늘 이후의 날짜는 선택이 불가능하다
    func maximumDate(for calendar: FSCalendar) -> Date {
        let max = Date(timeIntervalSinceNow: 10)
        return max
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        guard let cell = calendar.dequeueReusableCell(withIdentifier: DateCell.description(), for: date, at: position) as? DateCell else { return FSCalendarCell() }
        //let currentPageDate = calendar.currentPage
        
        // (viewModel) url을 받아서, 배경 이미지를 띄워준다
        
        return cell
    }
}
