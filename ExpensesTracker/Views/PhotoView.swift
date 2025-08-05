//
//  PhotoView.swift
//  ExpensesTracker
//
//  Created by Jorge Ramos on 25/07/25.
//
import SwiftUI

struct PhotoView: View {
    private var viewModel: PhotoViewModel?

    // Image state
    @State private var selectedImage: UIImage?
    @State private var isImagePickerShowing = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImageSourceOptions = false

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
            ScrollView {
                VStack(spacing: 25) {
                    // MARK: - Image Section
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                            .frame(height: 250)

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Tap to add a photo")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onTapGesture {
                        self.showImageSourceOptions = true
                    }
                    .padding(.horizontal)

                    // MARK: - Expense Details Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.headline)
                            TextField("e.g., Coffee with friends", text: $description)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading) {
                            Text("Price")
                                .font(.headline)
                            TextField("0.00", text: $price)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Category")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Category.allCases) { category in
                                        Text(category.rawValue.capitalized)
                                            .font(.subheadline)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 15)
                                            .background(selectedCategory == category ? Color.accentColor : Color(.systemGray5))
                                            .foregroundColor(selectedCategory == category ? .white : .primary)
                                            .clipShape(Capsule())
                                            .onTapGesture {
                                                withAnimation(.spring()) {
                                                    selectedCategory = category
                                                }
                                            }
                                    }
                                }
                            }
                        }

                        DatePicker("Date", selection: $date)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveExpense)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $isImagePickerShowing) {
                ImagePicker(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
            .actionSheet(isPresented: $showImageSourceOptions) {
                ActionSheet(title: Text("Select Photo"), message: nil, buttons: [
                    .default(Text("Take Photo")) {
                        self.sourceType = .camera
                        self.isImagePickerShowing = true
                    },
                    .default(Text("Choose from Library")) {
                        self.sourceType = .photoLibrary
                        self.isImagePickerShowing = true
                    },
                    .cancel()
                ])
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Form"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    viewModel.processImage(image)
                }
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

        print("Saved new expense: \(newExpense)")
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
