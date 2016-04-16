import UIKit

//: ## Saving Data in iOS: Challenge 8 - JSON
//:
//: JSON is another format that is used extensively in apps. It's particularly useful when working with web services as it can communicate a lot of information without using a lot of code.
//:
//: ----
//:
//: In this tutorial, you're going to piggy back off the work you did in the past XML tutorial. First the code will parse the rwdevcon.xml into actual swift objects. You'll convert these objects to JSON and then read them back.

//: Since this challenge will be piggy backing off of the last challenge, all the code has been provided for you. If you have questions about the code, see the previous challenge.

class RWDevConSession: CustomStringConvertible {
  var sessionId = 0
  var name = ""
  var instructor = ""
  var track = ""
  
  var description: String {
    return "Session \(sessionId): \(name) by \(instructor) - \(track) Track"
  }
}

class SessionsParser: NSObject, NSXMLParserDelegate {
  
  let xmlParser: NSXMLParser
  var sessions = [RWDevConSession]()
  var currentSession: RWDevConSession?
  var xmlText = ""
  
  init(withXML xml: NSData) {
    self.xmlParser = NSXMLParser(data: xml)
  }
  
  func parse() -> [RWDevConSession] {
    xmlParser.delegate = self
    xmlParser.parse()
    return sessions
  }
  
  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    if elementName == "session" {
      currentSession = RWDevConSession()
    }
    if elementName == "name" || elementName == "instructor" || elementName == "track" || elementName == "sessionId" {
      xmlText = ""
    }
  }
  
  func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "name" {
      currentSession?.name = xmlText
    }
    if elementName == "instructor" {
      currentSession?.instructor = xmlText
    }
    if elementName == "track" {
      currentSession?.track = xmlText
    }
    if elementName == "sessionId" {
      let text = xmlText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      if let sessionId = Int(text) {
        currentSession?.sessionId = sessionId
      }
    }
    if elementName == "session" {
      if let session = currentSession {
        sessions.append(session)
      }
    }
  }
  
  func parser(parser: NSXMLParser, foundCharacters string: String) {
    xmlText += string
  }
  
}

//: This is where the actual parsing takes place. The first part of the challenge converts the xml to swift objects.

var sessions = [RWDevConSession]()

if let xmlUrl = NSBundle.mainBundle().URLForResource("rwdevcon", withExtension: "xml") {
  do {
    let xmlText = try String(contentsOfURL: xmlUrl)
    if let xmlData = xmlText.dataUsingEncoding(NSUTF8StringEncoding) {
      let parser = SessionsParser(withXML: xmlData)
      let sessions = parser.parse()
        var topLevel : [AnyObject] = []
    
//: First thing you need to do is create a dictionary of a String and an AnyObject.
        for session in sessions {
            var dictSessions:[String: AnyObject] = [:]
            dictSessions["sessionID"] = NSNumber(integer:session.sessionId)
        dictSessions["name"] = session.name
        dictSessions["instructor"] = session.instructor
        dictSessions["track"] = session.track
        topLevel.append(dictSessions)
        }
//: Next, loop through all the session objects. Take each property and store it in the dictionary. For example: ["sessionId" : session.sessionId]

//: Once you create your dictionary, add it to your array.

      
//: Next create another dictionary. It should have a property called sessions and add your array to it.
        var sessionsDict = ["Sessions":topLevel]


//: At this pont you will serialize your JSON. On the NSJSONSerialization object, call the static method dataWithJSONObject(:). This will convert it to an NSData.
    let sessionData = try NSJSONSerialization.dataWithJSONObject(sessionsDict, options: .PrettyPrinted)
//        print(sessionData)
      
//: At this point you're going to read the JSON back. Since JSON is just string, initialize a new string based off the JSON data. This is done by: String(data:, encoding:NSUTF8StringEncoding)
        let sessionString = String(data: sessionData, encoding:NSUTF8StringEncoding)
//        print(sessionString)


//: Convert this string into an NSData by using the method dataUsingEncoding on the jsonString

        let jsonData = sessionString?.dataUsingEncoding(NSUTF8StringEncoding)
//: Next convert the data into JSON by calling JSONObjectWithData on the NSJSONSerialization object
       let newData = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: .MutableContainers)
        
            print(newData)


//: Finally, print out the serialized JSON object.

    }
  } catch {
    print(error)
  }

}
