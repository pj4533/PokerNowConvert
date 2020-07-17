import Vapor
import Leaf

func routes(_ app: Application) throws {

    app.get { req in
        req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter"
        ])
    }

    
    app.post("logs") { req -> EventLoopFuture<View> in//req -> HTTPResponseStatus in
        let log = try req.content.decode(Log.self)
        
         return req.view.render("index", [
            "title": "PokerNowConvert",
            "body": "PokerNow.club Log Converter",
            "raw": log.raw,
            "converted": "converted log"
        ])
    }


}
