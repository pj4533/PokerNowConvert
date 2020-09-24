import Vapor
import Leaf
import PokerNowKit
import SwiftCSV

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

    app.on(.POST, "logs", body: .collect(maxSize: "4mb")) { req -> EventLoopFuture<Vapor.View> in
        let log = try req.content.decode(Log.self)

        var converted : String = ""
        do {
            let csvFile: CSV = try CSV(string: log.raw)

            let game = Game(rows: csvFile.namedRows)
            for hand in game.hands {
                let pokerStarsLines = hand.getPokerStarsDescription(heroName: log.heroname, multiplier: Double(log.multiplier) ?? 0.01, tableName: "PokerNowConverter").joined(separator: "\n")
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
            "raw": log.raw,
            "converted": converted,
            "heroname": log.heroname,
            "multiplier": log.multiplier
        ])
    }
    
}
