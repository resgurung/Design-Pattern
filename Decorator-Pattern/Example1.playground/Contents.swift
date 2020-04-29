import UIKit

//Structural patterns
// Decorator

/*
    Define
    The decorator pattern dynamically modifies the behavior of a core object without changing its existing class definition.
 
    1. The Decorator allows you to modify an object dynamically
    2. More flexible than inheritance
    3. Rather than rewrite code, you can extend with new code
    4. Adds functionality on run time
 
    Note: Composition over inheritance
 */

// ------------------------------------------------------------------------------------------------------- //
// 1. Pizza Topping
// abstract
protocol Pizza {
    
    var description: String { get }
    var cost: Double { get }
}

// Concrete type
class SicilianPizza: Pizza {
    
    var description: String
    var cost: Double
    
    init(description: String, cost: Double) {
        self.description = description
        self.cost = cost
    }
}

class NeapolitanPizza: Pizza {
    
    var description: String
    var cost: Double
    
    init(description: String, cost: Double) {
        self.description = description
        self.cost = cost
    }
}

class ChicagoPizza: Pizza {
   
    var description: String
    var cost: Double
    
    init(description: String, cost: Double) {
        self.description = description
        self.cost = cost
    }
}

// Decorator
class ToppingDecorator: Pizza {
    
    var description: String {
        
        return instancePizza.description
    }
    
    var cost: Double {
        
        return instancePizza.cost
    }
    
    var instancePizza: Pizza
    
    init(pizza: Pizza) {
        
        self.instancePizza = pizza
    }
}


enum Topping {

    case pepperoni(Double)
    case mushrooms(Double)
    case onions(Double)
    case sausage(Double)
    case extraCheese(Double)
    case blackOlives(Double)
    case greenPeppers(Double)
    
    var toppingPrice: Double {
        
        switch self {
        case .pepperoni(let price):
            return price
        case .mushrooms(let price):
            return price
        case .onions(let price):
            return price
        case .sausage(let price):
            return price
        case .extraCheese(let price):
            return price
        case .blackOlives(let price):
            return price
        case .greenPeppers(let price):
            return price
        }
    }
}



var toppingsPriceSet: [String: Topping] = [
    "Pepperoni": .pepperoni(0.50),
    "Mushrooms": .mushrooms(0.50),
    "Onions": .onions(0.30),
    "Sausage": .sausage(1.20),
    "Extra Cheese": .extraCheese(0.30),
    "Black Olives": .blackOlives(0.70),
    "Green Peppers": .greenPeppers(0.40)
]



class DecoratorToppingPizza: ToppingDecorator {

    override var cost: Double {

        return instancePizza.cost + toppings.values.reduce(0) { $0 + $1.toppingPrice }
    }

    override var description: String {

        return  instancePizza.description + " \nToppings: \(toppings.keys.joined(separator: ", "))"
    }

    var toppings: [String: Topping]

    init(pizza: Pizza, toppings: [String: Topping]) {

        self.toppings = toppings

        super.init(pizza: pizza)
    }
}
// create type of pizza
let plainSicilianPizza = SicilianPizza(description: "Plain Pizza", cost: 2.00)

let plainNeapolitanPizza = NeapolitanPizza(description: "Neapolitan Pizza", cost: 3.00)

let plainChicagoPizza = ChicagoPizza(description: "Chicago Pizza", cost: 3.50)

// Decorated Pizza
let chicagoToppingPizza = DecoratorToppingPizza(pizza: plainChicagoPizza,
                                                toppings: [
                                                    "Pepperoni": .pepperoni(0.50),
                                                    "Mushrooms": .mushrooms(0.50),
                                                    "Onions": .onions(0.30)
                                                    ])

let neapolitanToppingPizza = DecoratorToppingPizza(pizza: plainNeapolitanPizza,
                                                   toppings: [
                                                            "Sausage": .sausage(1.20),
                                                            "Extra Cheese": .extraCheese(0.30),
                                                            "Black Olives": .blackOlives(0.70)
                                                    ])

let sicilianToppingPizza = DecoratorToppingPizza(pizza: plainSicilianPizza,
                                                 toppings: [
                                                    "Onions": .onions(0.30),
                                                    "Sausage": .sausage(1.20),
                                                    "Extra Cheese": .extraCheese(0.30),
                                                    "Black Olives": .blackOlives(0.70),
                                                    "Green Peppers": .greenPeppers(0.40)
                                                    ])


print("-----\nDescription: \(chicagoToppingPizza.description) \nCost: £\(chicagoToppingPizza.cost) \n-----\n")

print("-----\nDescription: \(neapolitanToppingPizza.description) \nCost: £\(neapolitanToppingPizza.cost) \n-----\n")

print("-----\nDescription: \(sicilianToppingPizza.description) \nCost: £\(sicilianToppingPizza.cost) \n-----\n")


// ------------------------------------------------------------------------------------------------------- //
// 2. Car


protocol Transporting {
    
  func getSpeed() -> Double
  func getTraction() -> Double
}

// Core Component
final class RaceCar: Transporting {
    
  private let speed = 10.0
  private let traction = 10.0
  
  func getSpeed() -> Double {
    return speed
  }
  
  func getTraction() -> Double {
    return traction
  }
}

// Abstract Decorator
class TireDecorator: Transporting {
  // 1
  private let transportable: Transporting
  
  init(transportable: Transporting) {
    self.transportable = transportable
  }
  
  // 2
  func getSpeed() -> Double {
    return transportable.getSpeed()
  }
  
  func getTraction() -> Double {
    return transportable.getTraction()
  }
}

class OffRoadTireDecorator: Transporting {
  private let transportable: Transporting
  
  init(transportable: Transporting) {
    self.transportable = transportable
  }
  
  func getSpeed() -> Double {
    return transportable.getSpeed() - 3.0
  }
  
  func getTraction() -> Double {
    return transportable.getTraction() + 3.0
  }
}

class ChainedTireDecorator: Transporting {
  private let transportable: Transporting
  
  init(transportable: Transporting) {
    self.transportable = transportable
  }
  
  func getSpeed() -> Double {
    return transportable.getSpeed() - 1.0
  }
  
  func getTraction() -> Double {
    return transportable.getTraction() * 1.1
  }
}

// Create Race Car
let defaultRaceCar = RaceCar()
defaultRaceCar.getSpeed() // 10
defaultRaceCar.getTraction() // 10

// Modify Race Car
let offRoadRaceCar = OffRoadTireDecorator(transportable: defaultRaceCar)
offRoadRaceCar.getSpeed() // 7
offRoadRaceCar.getTraction() // 13

// Double Decorators
let chainedTiresRaceCar = ChainedTireDecorator(transportable: offRoadRaceCar)
chainedTiresRaceCar.getSpeed() // 6
chainedTiresRaceCar.getTraction() // 14.3
