//
//  CalendarView.swift
//  YakCare+
//
//  Created by 이효주 on 7/26/25.
//

import SwiftUI

struct CalendarView: View {
    // MARK: - Environment
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    // MARK: - State
    @State private var displayMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var selectedTime: String = "10:00"
    @State private var input: String = ""
    
    // MARK: - Constants
    private let pharmacyName = "00약국"
    private let openHours = "10:00 - 19:00"
    private let address = "주소"
    private let weekDays = ["일","월","화","수","목","금","토"]
    private var times: [String] {
        var slots: [String] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let calendar = Calendar.current
        guard let start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
              let end = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) else {
            return slots
        }
        var current = start
        while current <= end {
            slots.append(formatter.string(from: current))
            guard let next = calendar.date(byAdding: .minute, value: 30, to: current) else { break }
            current = next
        }
        return slots
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NearbyPharmacyNavBar(title: "언제 갈까요?") {
                dismiss()
            }
            .padding(.vertical, 12)
            
            Spacer().frame(height: 15)
            
            ScrollView {
                // MARK: - Pharmacy Card
                HStack(spacing: 0) {
                    HStack {
                        Spacer().frame(width: 35)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pharmacyName).font(.subheadline)
                            HStack(spacing: 4) {
                                Image("TimeCircle")
                                    .resizable()
                                    .frame(width:12, height: 12)
                                Text(openHours).font(.subheadline)
                            }
                            HStack(spacing: 4) {
                                Image("Location")
                                    .resizable()
                                    .frame(width:12, height: 12)
                                Text(address).font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedCorner(radius: 16, corners: [.topRight]))
                    Spacer()
                }
                
                // MARK: - Date Picker
                VStack(spacing: 0) {
                    HStack {
                        Text("날짜 선택").font(.system(size: 10))
                        Spacer()
                    }
                    .padding(.top, 25)
                    
                    HStack {
                        Button { changeMonth(by: -1) } label: { Image(systemName: "chevron.left").foregroundStyle(.black) }
                        Spacer().frame(width: 10)
                        Text(monthYearString(from: displayMonth)).font(.headline)
                        Spacer().frame(width: 10)
                        Button { changeMonth(by: 1) } label: { Image(systemName: "chevron.right").foregroundStyle(.black) }
                    }
                    .padding()
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        ForEach(weekDays, id: \.self) { wd in
                            Text(wd)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 12) {
                        ForEach(generateDays(for: displayMonth), id: \.self) { date in
                            let day = Calendar.current.component(.day, from: date)
                            let inMonth = Calendar.current.isDate(date, equalTo: displayMonth, toGranularity: .month)
                            let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
                            
                            Text("\(day)")
                                .frame(maxWidth: .infinity, minHeight: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color.blue.opacity(0.5) : .clear, lineWidth: 2)
                                )
                                .foregroundColor(inMonth ? .black : .gray.opacity(0.4))
                                .onTapGesture {
                                    if inMonth { selectedDate = date }
                                }
                        }
                    }
                    .padding(.bottom)
                }
                .background(Color.white)
                .padding(.horizontal, 30)
                
                Divider()
                    .padding(.vertical, 8)
                    .padding(.horizontal, 30)
                
                // MARK: - Time Slots & Message Input
                VStack(alignment: .leading) {
                    Spacer().frame(height: 20)
                    Text("방문 시간").font(.system(size: 10))
                    Spacer().frame(height: 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(times, id: \.self) { t in
                                Text(t)
                                    .frame(width: 72, height: 33)
                                    .background(selectedTime == t ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                                    .onTapGesture { selectedTime = t }
                            }
                        }
                    }
                    Spacer().frame(height: 20)
                    // Label
                    Text("약사에게 전할 말").font(.system(size: 12))
                    Spacer().frame(height: 26)
                    // Inline Message Input Field
                    TextEditor(text: $input)
                        .padding(12)
                        .font(.system(size: 14))
                        .frame(height: 66)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if input.isEmpty {
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "pencil").foregroundColor(.gray)
                                        Text("예시문구").foregroundColor(.gray).font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                }
                            }
                        )
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 26)
            }
            Button(action: {
                // 확인 액션
                router.push(.home)
            }) {
                Text("확인")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Helper Functions
    private func changeMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: displayMonth) {
            displayMonth = newDate
            selectedDate = nil
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "M월"
        return df.string(from: date)
    }
    
    private func generateDays(for month: Date) -> [Date] {
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .month, for: month),
              let firstWeek = cal.dateInterval(of: .weekOfMonth, for: interval.start) else { return [] }
        let start = firstWeek.start
        let daysCount = 6 * 7
        guard let end = cal.date(byAdding: .day, value: daysCount - 1, to: start) else { return [] }
        return cal.generateDatesArray(from: start, through: end)
    }
}

fileprivate extension Calendar {
    func generateDatesArray(from start: Date, through end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            guard let next = date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environment(NavigationRouter())
    }
}
