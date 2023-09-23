//
//  ContentView.swift
//  Farmacine Now
//
//  Created by ABDELWAHAB on 23/09/23.
//

import SwiftUI

struct ContentView: View {
    @State private var age = ""
    @State private var gender = 0
    @State private var weight = ""
    @State private var height = ""
    @State private var result = ""
    @State private var target = ""
    @State private var isWeightGain = true
    @State private var bmi = ""
    @State private var bmiColor: Color = .white
    
    var body: some View {
        NavigationView {
            Form {
                PersonalInfoSection(age: $age, gender: $gender, weight: $weight, height: $height)
                GoalSection(isWeightGain: $isWeightGain, target: $target)
                CalculateButtonSection(isWeightGain: $isWeightGain, age: $age, gender: $gender, weight: $weight, height: $height, target: $target, result: $result, bmi: $bmi, bmiStateColor: $bmiColor)
                ResultSection(result: $result, bmi: $bmi, bmiColor: bmiColor)
            }
            .navigationBarTitle("Weight Management")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PersonalInfoSection: View {
    @Binding var age: String
    @Binding var gender: Int
    @Binding var weight: String
    @Binding var height: String

    var body: some View {
        Section(header: Text("Personal Information")) {
            TextField("Age", text: $age)
                .keyboardType(.numberPad)
            genderPicker
            TextField("Weight (kg)", text: $weight)
                .keyboardType(.decimalPad)
            TextField("Height (cm)", text: $height)
                .keyboardType(.decimalPad)
        }
    }

    private var genderPicker: some View {
        Picker("Gender", selection: $gender) {
            Text("Male").tag(0)
            Text("Female").tag(1)
        }
    }
}

struct GoalSection: View {
    @Binding var isWeightGain: Bool
    @Binding var target: String

    var body: some View {
        Section(header: Text("Goal")) {
            Toggle("Weight Gain", isOn: $isWeightGain)
            TextField(isWeightGain ? "Target Weight (kg)" : "Target Weight Loss (kg)", text: $target)
                .keyboardType(.decimalPad)
        }
    }
}

struct CalculateButtonSection: View {
    @Binding var isWeightGain: Bool
    @Binding var age: String
    @Binding var gender: Int
    @Binding var weight: String
    @Binding var height: String
    @Binding var target: String
    @Binding var result: String
    @Binding var bmi: String // Add BMI state variable
    @Binding var bmiStateColor: Color // Add BMI state Color

    var body: some View {
        Section {
            Button(action: calculate) {
                Text("Calculate")
            }
        }
    }

    private func calculate() {
        // Calculate BMR
        guard let ageValue = Double(age),
              let weightValue = Double(weight),
              let heightValue = Double(height),
              let targetValue = Double(target) else {
            result = "Please enter valid values."
            return
        }

        let isMale = gender == 0
        let bmr: Double

        if isMale {
            bmr = 88.362 + (13.397 * weightValue) + (4.799 * heightValue) - (5.677 * ageValue)
        } else {
            bmr = 447.593 + (9.247 * weightValue) + (3.098 * heightValue) - (4.330 * ageValue)
        }

        let dailyCaloriesNeeded: Double
        if isWeightGain {
            dailyCaloriesNeeded = bmr + 500 // Add 500 calories for weight gain
        } else {
            dailyCaloriesNeeded = bmr - 500 // Subtract 500 calories for weight loss
        }

        let caloriesDifference = (targetValue - weightValue) * 7700 // 7700 calories are approximately equal to 1 kg
        let daysToReachGoal = caloriesDifference / dailyCaloriesNeeded

        result = String(format: "Your daily caloric needs (BMR) are: %.2f calories.\nTo reach your goal, it will take approximately %.1f days.", bmr, daysToReachGoal)
        
        // Calculate BMI
        if let weightValue = Double(weight),
           let heightValue = Double(height) {
            let heightInMeters = heightValue / 100
            let bmiValue = weightValue / (heightInMeters * heightInMeters)
            bmi = String(format: "Your BMI is: %.2f", bmiValue)
            
            // Determine BMI color based on the BMI value
            let bmiColor: Color = {
                switch bmiValue {
                case ..<18.5:
                    return .blue // Underweight
                case 18.5..<24.9:
                    return .green // Normal weight
                case 24.9..<29.9:
                    return .orange // Overweight
                default:
                    return .red // Obese
                }
            }()
            
            bmiStateColor = bmiColor
            
            // Append BMI with color to the result
            result = String(format: "Your daily caloric needs (BMR) are: %.2f calories.\nTo reach your goal, it will take approximately %.1f days.", bmr, daysToReachGoal)
        }
    }
}

struct BMIColorView: View {
    var bmiColor: Color

    var body: some View {
        Circle()
            .foregroundColor(bmiColor)
            .frame(width: 50, height: 50) // Set the desired size of the color indicator
    }
}


struct ResultSection: View {
    @Binding var result: String
    @Binding var bmi: String // Add BMI state variable
    var bmiColor: Color // Add BMI color state variable

    var body: some View {
           Section(header: Text("Result")) {
               Text(result)
                   .foregroundColor(.white) // Set the text color to black
               if !bmi.isEmpty {
                   Text(bmi)
                       .foregroundColor(bmiColor) // Set the BMI text color to red (you can change this color)
                   BMIColorView(bmiColor: bmiColor) // Display the color indicator

               }
           }
       }
}
