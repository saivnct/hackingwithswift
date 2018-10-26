//: Playground - noun: a place where people can play

//If you want to see what super-charging Swift's built-in data types can look like, look up the ExSwift extension catalog on GitHub at https://github.com/pNre/ExSwift.
//The main reason is extensibility: extensions work across all data types, and they don't conflict when you have more than one. That is, we could make a UIView subclass that adds fadeOut(), but what if we find some open source code that contains a spinAround() method? We would have to copy and paste it in to our subclass, or perhaps even subclass again.
//With extensions you can have ten different pieces of functionality in ten different files – they can all modify UIView directly, and you don't need to subclass anything. A common naming scheme for naming your extension files is Type+Modifier.swift, for example String+RandomLetter.swift.
//If you find yourself wanting to make views fade out often, an extension is perfect for you



import UIKit


//extension Int tells Swift that we want to add functionality to its Int struct. We could have used String, Array, UIButton or whatever instead, but Int is a nice easy one to start.
extension Int {
    func plusOne() -> Int {
        return self + 1
    }
    
    mutating func increaseOne() {   //Swift forces you to declare the method mutating, meaning that it will change its input
        self += 1
    }
}


//we want squared() to apply to all types of integer, we can’t very well make it return Int - that’s not big enough to hold the full range of a UInt64, so Swift will refuse to build. Instead, we need to make the method return Self, which means “I’ll return whatever data type I was used with.”
//This time I’ve made it apply to Integer, which is the protocol applied to Int, Int8, UInt64, and so on. This means all integer types get access to the squared() method, and work as expected.
extension Integer {
    
    func squared() -> Self {
        return self * self
    }
}

var str = "Hello, playground"
var myInt = 10
myInt.plusOne() //unchanged value
myInt
myInt.increaseOne() //changed value
myInt

let otherInt = 10
//otherInt.increaseOne() //this will fail because Swift won't let you modify constants

let i: UInt = 8
i.squared()
