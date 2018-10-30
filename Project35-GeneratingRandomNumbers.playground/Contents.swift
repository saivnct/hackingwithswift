import UIKit
import GameplayKit

//Generating random numbers without GameplayKit
let int1 = Int.random(in: 0...10)
let int2 = Int.random(in: 0..<10)
let double1 = Double.random(in: 1000...10000)
let float1 = Float.random(in: -100...100)
let bool1 = Bool.random()

//Generating random numbers with GameplayKit: GKRandomSource
//produces a number between -2,147,483,648 and 2,147,483,647
print(GKRandomSource.sharedRandom().nextInt())
// Apple includes a warning that it's not guaranteed to be random for very specific situations, so for both these reasons it's not likely you'll want to use nextInt() much
//As an alternative, try using the nextInt(upperBound:) method
print(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) //return a random number from 0 to 5

print(GKRandomSource.sharedRandom().nextUniform())
print(GKRandomSource.sharedRandom().nextBool())

//GameplayKit has three sources of random numbers
//1. GKLinearCongruentialRandomSource: has high performance but the lowest randomness
//2. GKMersenneTwisterRandomSource: has high randomness but the lowest performance
//3. GKARC4RandomSource: has good performance and good randomness – in the words of Apple, "it's going to be your Goldilocks random source."
//Honestly, the performance difference between the three of these is all but insignificant unless you're generating vast quantities of random numbers.
let arc4 = GKARC4RandomSource()
arc4.nextInt(upperBound: 20)

let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 20)

//Apple recommends you force flush its ARC4 random number generator before using it for anything important, otherwise it will generate sequences that can be guessed to begin with. Apple suggests dropping at least the first 769 values, so I suspect most coders will round up to the nearest pleasing value: 1024. To drop values, use this code
arc4.dropValues(1024)

//GameplayKit lets you shape the random sources in various interesting ways using random distributions
//This is very similar to Swift’s Int.random(in:) method, but using GameplayKit means you can create the random distribution as a property then re-use it again and again without having to specify the range each time
let d6 = GKRandomDistribution.d6()  //generating a random number between 1 and 6
d6.nextInt()

let d20 = GKRandomDistribution.d20()    //generating a random number between 1 and 20
d20.nextInt()

let crazy = GKRandomDistribution(lowestValue: 1, highestValue: 11539) //generating a random number between 1 and 11539
crazy.nextInt()

//When you create a random distribution in this way, iOS automatically creates a random source for you using an unspecified algorithm. If you want one particular random source, there are special constructors for you
let rand = GKMersenneTwisterRandomSource()
let distribution = GKRandomDistribution(randomSource: rand, lowestValue: 10, highestValue: 20)
print(distribution.nextInt())

//using GKRandomDistribution to shape a random source, either created automatically or specified in its constructor. GameplayKit provides two other distributions: GKShuffledDistribution ensures that sequences repeat less frequently, and GKGaussianDistribution ensures that your results naturally form a bell curve where results near to the mean average occur more frequently
//GKShuffledDistribution - This is an anti-clustering distribution, which means it shapes the distribution of random numbers so that you are less likely to get repeats. This means it will go through every possible number before you see a repeat, which makes for a truly perfect distribution of numbers
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

//GKGaussianDistribution (tip: "Gauss" rhymes with "House"), which causes the random numbers to bias towards the mean average of the range. So if your range is from 0 to 20, you'll get more numbers like 10, 11 and 12, fewer numbers like 8, 9, 13 and 14, and decreasing amounts of any numbers outside that.
let shuffled2 = GKGaussianDistribution.d6()
print(shuffled2.nextInt())
print(shuffled2.nextInt())
print(shuffled2.nextInt())
print(shuffled2.nextInt())
print(shuffled2.nextInt())
print(shuffled2.nextInt())


//Shuffling an array with GameplayKit: arrayByShufflingObjects(in:)
let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])
