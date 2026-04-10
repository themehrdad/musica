import SwiftUI
import SwiftData
import PhotosUI

struct ProfileFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var profileToEdit: Profile?

    @State private var name = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarData: Data?
    @State private var beginner = true
    @State private var clefMode: ClefMode = .treble

    private var isEditing: Bool { profileToEdit != nil }

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

                Toggle(isOn: $beginner) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Beginner")
                            .font(.body.weight(.medium))
                        Text("Only notes on the staff lines")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 40)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Clef")
                        .font(.body.weight(.medium))
                    Picker("Clef", selection: $clefMode) {
                        ForEach(ClefMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle(isEditing ? "Edit Profile" : "New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespaces)
                        if let profile = profileToEdit {
                            profile.name = trimmedName
                            profile.avatarData = avatarData
                            profile.beginner = beginner
                            profile.clefMode = clefMode
                        } else {
                            let profile = Profile(name: trimmedName, avatarData: avatarData, beginner: beginner, clefMode: clefMode)
                            context.insert(profile)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let profile = profileToEdit {
                    name = profile.name
                    avatarData = profile.avatarData
                    beginner = profile.beginner
                    clefMode = profile.clefMode
                }
            }
        }
    }
}
