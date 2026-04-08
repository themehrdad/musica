import SwiftUI
import SwiftData
import PhotosUI

struct CreateProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarData: Data?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    AvatarView(name: name.isEmpty ? "?" : name,
                               imageData: avatarData, size: 120)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                            .background(Circle().fill(.white).padding(2))
                    }
                }
                .onChange(of: selectedPhoto) { _, item in
                    Task {
                        avatarData = try? await item?.loadTransferable(type: Data.self)
                    }
                }

                TextField("Name", text: $name)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespaces)
                        let profile = Profile(name: trimmedName, avatarData: avatarData)
                        context.insert(profile)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
