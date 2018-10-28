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
    
    //Swift doesn't let you modify self inside an extension by default
    //Swift forces you to declare the method mutating, meaning that it will change its input
    mutating func increaseOne() {   //Swift forces you to declare the method mutating, meaning that it will change its input
        self += 1
    }
}

var myInt = 10
myInt.increaseOne()
myInt

//Once you have declared a method as being mutating, Swift knows it will change values so it won't let you use it with constants
let otherInt = 10
//otherInt.increaseOne()
//otherInt

//we want squared() to apply to all types of integer, we can’t very well make it return Int - that’s not big enough to hold the full range of a UInt64, so Swift will refuse to build. Instead, we need to make the method return Self, which means “I’ll return whatever data type I was used with.”
//This time I’ve made it apply to Integer, which is the protocol applied to Int, Int8, UInt64, and so on. This means all integer types get access to the squared() method, and work as expected.
extension Int {

    func squared() -> Int {
        return self * self
    }
}


let i: Int = 8
i.squared()


//Our extension modifies the Int data type specifically, rather than all variations of integers, which means code like this won’t work because UInt64 doesn’t have the extension
//let j: UInt64 = 8
//print(j.squared())



//This time I’ve made it apply to BinaryInteger, which is the protocol applied to Int, Int8, UInt64, and so on. This means all integer types get access to the squared() method
extension BinaryInteger {
    func squared() -> Self { //self means “my current value” and Self means “my current data type.”
        return self * self
    }
}

let j: UInt64 = 8
print(j.squared())
