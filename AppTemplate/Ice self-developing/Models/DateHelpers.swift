import Foundation

enum DateHelpers {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = .current
        return calendar
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func startOfWeek(for date: Date) -> Date {
        let day = startOfDay(date)
        let weekday = calendar.component(.weekday, from: day)
        let distanceFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -distanceFromMonday, to: day) ?? day
    }

    static func addingDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(date)) ?? date
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        let start = startOfDay(from)
        let end = startOfDay(to)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    static func date(daysAgo: Int, hour: Int, minute: Int) -> Date {
        let day = addingDays(-daysAgo, to: .now)
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    static func helmString(_ date: Date) -> String {
        formatted(date, "EEEE, MMMM d")
    }

    static func ritualDayString(_ date: Date) -> String {
        "Today · \(helmString(date))"
    }

    static func journalStamp(_ date: Date) -> String {
        let time = formatted(date, "HH:mm")
        if calendar.isDateInToday(date) {
            return "Today, \(time)"
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday, \(time)"
        }
        return "\(formatted(date, "MMM d")), \(time)"
    }

    static func weekdayLabel(_ date: Date) -> String {
        formatted(date, "EEE")
    }

    private static func formatted(_ date: Date, _ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
