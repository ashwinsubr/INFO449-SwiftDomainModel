struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        
        if currency == "USD" || currency == "GBP" || currency == "CAN" || currency == "EUR" {
            self.currency = currency
        } else {
            self.amount = 0
            self.currency = "Invalid currency"
        }
    }
    
    public func convert(_ to: String) -> Money {
        if self.currency == to {
            return Money(amount: self.amount, currency: to)
        }
        
        var amountInUSD: Int
        switch self.currency {
        case "USD":
            amountInUSD = self.amount
        case "GBP":
            amountInUSD = self.amount * 2
        case "EUR":
            amountInUSD = Int(Double(self.amount) / 1.5)
        case "CAN":
            amountInUSD = Int(Double(self.amount) / 1.25)
        default:
            amountInUSD = self.amount
        }
       
        // USD : to
        var convertedAmount: Int
        switch to {
        case "USD":
            convertedAmount = amountInUSD
        case "GBP":
            convertedAmount = amountInUSD / 2
        case "EUR":
            convertedAmount = Int(Double(amountInUSD) * 1.5)
        case "CAN":
            convertedAmount = Int(Double(amountInUSD) * 1.25)
        default:
            convertedAmount = amountInUSD
        }
       
        return Money(amount: convertedAmount, currency: to)
    }
    
    public func add(_ other: Money) -> Money {
        if self.currency == other.currency {
            return Money(amount: self.amount + other.amount, currency: self.currency)
        }
        
        let convertedSelf = self.convert(other.currency)
        return Money(amount: convertedSelf.amount + other.amount, currency: other.currency)
    }
    
    public func subtract(_ other: Money) -> Money {
        if self.currency == other.currency {
            return Money(amount: self.amount - other.amount, currency: self.currency)
        }
        
        let convertedMoney = other.convert(self.currency)
        return Money(amount: self.amount - convertedMoney.amount, currency: self.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    public var title: String
    public var type: JobType
    
    public init(title: String, type: JobType){
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int) -> Int {
        switch self.type {
        case .Hourly(let hourlyWage):
            return Int(hourlyWage * Double(hours))
        case .Salary(let yearlyAmount):
            return Int(yearlyAmount)
        }
    }
    
    public func raise(byAmount amount: Double) {
        switch self.type {
        case .Hourly(let hourlyWage):
            self.type = .Hourly(hourlyWage + amount)
        case .Salary(let yearlyAmount):
            self.type = .Salary(UInt(Double(yearlyAmount) + amount))
        }
    }
    
    public func raise(byPercent percent: Double) {
        switch self.type {
        case .Hourly(let hourlyWage):
            let raise = hourlyWage * percent
            self.type = .Hourly(hourlyWage + raise)
        case .Salary(let yearlyAmount):
            let raise = Double(yearlyAmount) * percent
            self.type = .Salary(UInt(Double(yearlyAmount) + raise))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    
    public var job: Job? {
        didSet {
            if age < 16 {
                job = nil
            }
        }
    }
    
    public var spouse: Person? {
        didSet {
            if age < 18 {
                spouse = nil
            }
        }
    }
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public init(firstName: String, age: Int) {
        self.firstName = firstName
        self.lastName = ""
        self.age = age
    }
    
    public func toString() -> String {
        var jobString = "nil"
        if let job = job {
            switch job.type {
            case .Hourly(let amount):
                jobString = "Hourly(\(amount))"
            case .Salary(let amount):
                jobString = "Salary(\(amount))"
            }
        }
        
        var spouseString = "nil"
        if let spouse = spouse {
            spouseString = spouse.firstName
        }
        
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobString) spouse:\(spouseString)]"
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person] = []
    
    public init(spouse1: Person, spouse2: Person) {
        if spouse1.spouse == nil && spouse2.spouse == nil {
            spouse1.spouse = spouse2
            spouse2.spouse = spouse1
            members.append(spouse1)
            members.append(spouse2)
        }
    }
    
    public func haveChild(_ child: Person) -> Bool {
        for member in members where member.spouse != nil {
            if member.age >= 21 {
                members.append(child)
                return true
            }
        }
        return false
    }
    
    public func householdIncome() -> Int {
        var total = 0
        
        for member in members {
            if let job = member.job {
                total += job.calculateIncome(2000)
            }
        }
        
        return total
    }
}
