import Vapor
import Leaf
import PokerNowKit
import SwiftCSV

#if swift(>=4.1)
     #if canImport(FoundationNetworking)
         import FoundationNetworking
     #endif
 #endif
 
func routes(_ app: Application) throws {

    app.get { req in
        req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "multiplier": "1.0"
        ])
    }

    app.get("logs") { req in
        req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "multiplier": "1.0"
        ])
    }

    app.on(.POST, "download") { req -> EventLoopFuture<Vapor.View> in
        let log = try req.content.decode(Log.self)
        let tableId = log.tableurl?.replacingOccurrences(of: "https://www.pokernow.club/games/", with: "") ?? ""
        var csvText = ""
        if let skipToken = Environment.get("SKIP_TOKEN") {
            do {
                if let url = URL(string: "https://www.pokernow.club/games/\(tableId)/poker_now_log_\(tableId).csv?skip_captcha_token=\(skipToken)") {
                    csvText = try String(contentsOf: url)                    
                }
            } catch let error {
                print("Error loading file")
            }
        } else {
            print("Error: no skip token found")
        }
         return req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "raw": csvText,
            "converted": "",
            "heroname": log.heroname ?? "",
            "multiplier": log.multiplier ?? "1.0"
        ])
    }

    app.on(.POST, "logs", body: .collect(maxSize: "4mb")) { req -> EventLoopFuture<Vapor.View> in
        let log = try req.content.decode(Log.self)

        var converted : String = ""
        do {
            let csvFile: CSV = try CSV(string: log.raw ?? "")

            let game = Game(rows: csvFile.namedRows)
            for hand in game.hands {
                let pokerStarsLines = hand.getPokerStarsDescription(heroName: log.heroname ?? "", multiplier: Double(log.multiplier ?? "1.0") ?? 1.0, tableName: "PokerNowConverter").joined(separator: "\n")
                converted.append(pokerStarsLines)
                converted.append("\n")
            }
        } catch let parseError as CSVParseError {
            print(parseError)
        } catch {
            print("Error loading file")
        }
        
         return req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "raw": log.raw ?? "",
            "converted": converted,
            "heroname": log.heroname ?? "",
            "multiplier": log.multiplier ?? "1.0"
        ])
    }
    
}
