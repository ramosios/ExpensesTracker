//
//  PhotoView.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 25/07/25.
//
import SwiftUI

struct PhotoView: View {
    // Image state
    @State private var selectedImage: UIImage?
    @State private var isImagePickerShowing = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    // Expense form state
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var date: Date = Date()
    @State private var selectedCategory: Category = .other

    // For showing an alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // Image selection section
                VStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .padding(.vertical)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding()
                    }

                    HStack {
                        Button("Take Photo") {
                            self.sourceType = .camera
                            self.isImagePickerShowing = true
                        }
                        .padding()
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                        Button("Choose from Library") {
                            self.sourceType = .photoLibrary
                            self.isImagePickerShowing = true
                        }
                        .padding()
                    }
                }

                // Expense details form
                Form {
                    Section(header: Text("Expense Details")) {
                        TextField("Description", text: $description)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(Category.allCases) { category in
                                Text(category.rawValue.capitalized).tag(category)
                            }
                        }
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveExpense)
                }
            }
            .sheet(isPresented: $isImagePickerShowing) {
                ImagePicker(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Form"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveExpense() {
        guard !description.isEmpty else {
            alertMessage = "Please enter a description."
            showAlert = true
            return
        }
        guard let priceDouble = Double(price) else {
            alertMessage = "Please enter a valid price."
            showAlert = true
            return
        }

        let newExpense = Expense(
            photo: selectedImage,
            description: description,
            price: priceDouble,
            date: date,
            category: selectedCategory
        )

        // For now, we just print the new expense.
        // Later, you can add code here to save it to a database.
        print("Saved new expense: \(newExpense)")

        // Reset the form
        resetForm()
    }

    private func resetForm() {
        selectedImage = nil
        description = ""
        price = ""
        date = Date()
        selectedCategory = .other
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
