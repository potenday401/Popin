//
//  DateTab.swift
//  fourpin
//
//  Created by Jihaha kim on 2024/01/30.
//

import UIKit
import SnapKit
import FSCalendar

final class DateView: BaseView {
    
    let calendar: FSCalendar = {
        let view = FSCalendar()
        let appearance = view.appearance
        
        view.setCurrentPage(Date(), animated: true)
       // view.today = nil
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.scrollEnabled = true
        view.scrollDirection = .vertical
        view.headerHeight = 60
        view.locale = Locale(identifier: "ko_KR")
        view.allowsMultipleSelection = false
        view.scope = .month
        view.placeholderType = .none
        appearance.selectionColor = .clear
        appearance.headerTitleColor = .white
        appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        appearance.headerTitleAlignment = .center
        appearance.weekdayTextColor = .white
        appearance.titleDefaultColor = .white
        appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        appearance.headerMinimumDissolvedAlpha = 0.0
        
        view.register(DateCell.self, forCellReuseIdentifier: DateCell.description())
        
        return view
    }()
    
    
    override func configure() {
        self.addSubview(calendar)
    }
    
    override func constraints() {
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.trailing.leading.equalTo(safeAreaLayoutGuide)
            make.height.equalToSuperview().multipliedBy(0.52)
        }
    }
}

