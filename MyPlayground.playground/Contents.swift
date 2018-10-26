import UIKit

var str = "Hello, playground"
print(str)

//normal way
func countLetter(string: String){
    print("the String \(string) has \(string.count) letters")
}
countLetter(string: "giangdaika")

//name the varibale
func countLetter2(in string: String){
    print("the String \(string) has \(string.count) letters")
}
countLetter2(in: "giangdaika")

func add(a: Int, b:Int) -> Int {
    return a+b;
}
var c=add(a: 10, b: 5)

//OPTIONAL
func getStatus(weather: String) -> String? {
    if (weather == "sunny"){
        return nil
    }
    else{
        return "Hate!"
    }
}
var status = getStatus(weather: "rainny");
var status2 = getStatus(weather: "sunny")
//Unwrap OPTIONAL
if let unwrapStatus = status{
    print("Status: \(unwrapStatus)")
}else{
    print("No status")
}

if let unwrapStatus2 = status2{
    print("Status2: \(unwrapStatus2)")
}else{
    print("No status2")
}

//FORCE UNWRAP OPTIONAL with !
var status3 = getStatus(weather: "rainny");
print("Status3: \(status3!)")   //we are sure that status3 has value

//OPTION CHAINNING
let status4 = getStatus(weather: "rain")?.uppercased();
print("Status4: \(status4!)")

//coalescing operator - use value A if you can, but if value A is nil then use value B.
let status5 = getStatus(weather: "sunny") ?? "unknown"
print("Status5 \(status5)")


//ENUM
enum WeatherType{
    case sunny, cloudy, rainny, windy, snowy
}

func getStatus2(weather: WeatherType) -> String? {
    switch weather {
    case .sunny:
        return nil
    case .cloudy, .windy:
        return "dislike"
    default:
        return "hate"
    
    }
}
var status6 = getStatus2(weather: WeatherType.rainny)
var status7 = getStatus2(weather: .windy)


//ENUM with additional values
enum WeatherType2{
    case sunny
    case cloudy
    case rainny
    case windy(speed: Int)
    case snowy
}
func getStatus3(weather: WeatherType2) -> String? {
    switch weather {
    case .sunny:
        return nil
    case .windy(let speed) where speed < 10:
        return "meh"
    case .cloudy, .windy:
        return "dislike"
    default:
        return "hate"
        
    }
}
var status8 = getStatus3(weather: .windy(speed: 5))
var status9 = getStatus3(weather: .windy(speed: 11))
var status10 = getStatus3(weather: .cloudy)


//STRUCT
//IF ASSIGN ONE STRUCT TO ANOTHER -> SWIFT CREATE A DUPLICATE OF THE ORIGINAL
//When you copy a struct, the whole thing is duplicated, including all its values
struct Person{
    var name: String
    var age: Int
}

var person1 = Person(name: "teo", age: 10)
var person2 = person1
person2.name = "ti"
print(person1)
print(person2)

//CLASS
//CLASS copy => REFERENCE   =>BIG DIFFERENT FROM STRUCT
class Singer {
    var name: String
    var age: Int
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func sing(){
        print("la la la")
    }
}

class CountrySinger: Singer{
    var nickname: String
    init(name: String, age: Int, nickname: String) {
        self.nickname = nickname
        super.init(name: name, age: age)
    }
    
    override func sing() {
        print("test test test")
    }
}


//PROPERTY OBSERVERS
struct Animal{
    var name: String {
        willSet {   //before changing value
            print("name wil be changed from \(name) to \(newValue)")
        }
        
        didSet{     //after changing value
            print("name's changed form \(oldValue) to \(name)")
        }
    }
}

var animal1 = Animal(name: "cat")
animal1.name = "dog";


//TYPE CASTING as? - optional | as! - force
class Album {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func getPerformance() -> String {
        return "The album \(name) sold lots"
    }
}

class StudioAlbum: Album {
    var studio: String
    
    init(name: String, studio: String) {
        self.studio = studio
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The studio album \(name) sold lots"
    }
}

class LiveAlbum: Album {
    var location: String
    
    init(name: String, location: String) {
        self.location = location
        super.init(name: name)
    }
    
    override func getPerformance() -> String {
        return "The live album \(name) sold lots"
    }
}

var taylorSwift = StudioAlbum(name: "Taylor Swift", studio: "The Castles Studios")
var fearless = StudioAlbum(name: "Speak Now", studio: "Aimeeland Studio")
var iTunesLive = LiveAlbum(name: "iTunes Live from SoHo", location: "New York")

var allAlbums: [Album] = [taylorSwift, fearless, iTunesLive]

for album in allAlbums {
    print(album.getPerformance())
    
    if let studioAlbum = album as? StudioAlbum {    //TYPE CASTING as? as!
        print(studioAlbum.studio)
    } else if let liveAlbum = album as? LiveAlbum {
        print(liveAlbum.location)
    }
}


//CLOSURE -> A closure can be thought of as a variable that holds code
