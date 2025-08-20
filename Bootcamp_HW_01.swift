import Foundation

struct PersonalCard {
    var name: String
    var age: Int
    var isStudent: Bool
    var height: Double
    var weight: Double?
    var phoneNumber: String?
    var email: String?
    var gender: String?
    
    func displayInfo() {
        print("👤 Personal Information Card")
        print("Name: \(name)")
        print("Age: \(age)")
        print("Studentship: \(isStudent)")
        print("Height: \(height) meter")
        
        if let weight = weight {
            print("Weight: \(weight) kg")
        } else {
            print("Weight: N/A")
        }
        
        if let phone = phoneNumber {
            print("Phone: \(phone)")
        } else {
            print("Phone: N/A")
        }
        
        print("E-mail: \(email ?? "NA")")
        
        if let gender = gender {
            print("Gender: \(gender)")
        } else {
            print("Gender: N/A")
        }
    }
}


let myCard = PersonalCard(
    name: "Cuma Aktaş",
    age: 38,
    isStudent: true,
    height: 1.78
    
)

myCard.displayInfo()
