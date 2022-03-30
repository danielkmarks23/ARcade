//
//  Logger.swift
//  ARcade
//
//  Created by Daniel Marks on 29/03/2022.
//

import Foundation

enum LogType: String {
    case error = "[🛑 Error]"
    case info = "[ℹ️ Info]"
    case debug = "[Debug]"
    case warning = "[⚠️ Warning]"
    case fatal = "[🔥 Fatal]"
    case success = "[✅ Success]"
}

final class Logger {
    
    class func log(type: LogType, message: String, fileName: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
#if DEBUG
        print(formattedDate(date: Date()) + " \(type.rawValue)[\(sourceFileName(filePath: fileName))]: line: \(line), column: \(column) func: \(function) -> \(message)")
#endif
    }
    
    private class func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        
        return formatter.string(from: date)
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}
