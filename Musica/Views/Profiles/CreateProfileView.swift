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
    @State private var trebleKeys: Set<Int> = []
    @State private var bassKeys: Set<Int> = []
    @State private var dailyGoal = Config.dailyGoal
    @State private var showParentalGate = false
    @State private var showPaywall = false

    private var isEditing: Bool { profileToEdit != nil }

    // Grand-staff mode uses tighter key bounds (see Config).
    private var shownTrebleRange: ClosedRange<Int> {
        clefMode == .both ? Config.bothTrebleSelectableRange : Config.trebleSelectableRange
    }
    private var shownBassRange: ClosedRange<Int> {
        clefMode == .both ? Config.bothBassSelectableRange : Config.bassSelectableRange
    }

    // The beginner toggle only drives hands without custom keys.
    private var beginnerApplies: Bool {
        (clefMode != .bass && trebleKeys.isEmpty) || (clefMode != .treble && bassKeys.isEmpty)
    }

    private var selectorSubtitle: String {
        beginner ? "Using the beginner staff range — tap keys to customize"
                 : "Using the full range — tap keys to customize"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
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
                        Text(beginnerApplies ? "Only notes on the staff lines"
                                             : "Not used — custom practice keys override this")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(!beginnerApplies)
                .opacity(beginnerApplies ? 1 : 0.5)
                .padding(.horizontal, 40)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily goal")
                            .font(.body.weight(.medium))
                        Text("Notes to practice each day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(dailyGoal)")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.purple)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.25), value: dailyGoal)
                    Stepper("Daily goal", value: $dailyGoal, in: 5...100, step: 5)
                        .labelsHidden()
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
                    .onChange(of: clefMode) { previous, selected in
                        if !FreeTier.clefAllowed(selected, premium: StoreService.shared.isPremium) {
                            clefMode = FreeTier.clefAllowed(previous, premium: StoreService.shared.isPremium)
                                ? previous : .treble
                            showParentalGate = true
                        }
                    }
                    if FreeTier.limited(premium: StoreService.shared.isPremium) {
                        Text("Bass and grand staff are part of Premium")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 40)
                .sheet(isPresented: $showParentalGate) {
                    ParentalGateView { showPaywall = true }
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }

                // Per-hand practice keys: like a deck of flash cards — pick
                // the exact keys (a range, or scattered problem keys) the
                // child should drill. Empty selection = the default range.
                if clefMode == .treble || clefMode == .both {
                    KeySelectorView(
                        title: clefMode == .both ? "Right hand · Treble 𝄞" : "Practice keys · Treble 𝄞",
                        subtitle: selectorSubtitle,
                        selectableRange: shownTrebleRange,
                        staffOnlyRange: Config.trebleBeginnerRange,
                        selection: $trebleKeys
                    )
                    .padding(.horizontal, 24)
                }

                if clefMode == .bass || clefMode == .both {
                    KeySelectorView(
                        title: clefMode == .both ? "Left hand · Bass 𝄢" : "Practice keys · Bass 𝄢",
                        subtitle: selectorSubtitle,
                        selectableRange: shownBassRange,
                        staffOnlyRange: Config.bassBeginnerRange,
                        selection: $bassKeys
                    )
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 40)
            }
            .navigationTitle(isEditing ? "Edit Profile" : "New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(in: .whitespaces)
                        // Persist only what the parent could see at save time:
                        // hands hidden by the clef choice save as empty, and
                        // keys outside the shown keyboard are dropped.
                        let savedTreble = clefMode == .bass ? []
                            : trebleKeys.filter { shownTrebleRange.contains($0) }
                        let savedBass = clefMode == .treble ? []
                            : bassKeys.filter { shownBassRange.contains($0) }
                        if let profile = profileToEdit {
                            profile.name = trimmedName
                            profile.avatarData = avatarData
                            profile.beginner = beginner
                            profile.clefMode = clefMode
                            profile.trebleKeys = Array(savedTreble)
                            profile.bassKeys = Array(savedBass)
                            profile.dailyGoal = dailyGoal
                        } else {
                            let profile = Profile(name: trimmedName, avatarData: avatarData, beginner: beginner, clefMode: clefMode,
                                                  trebleKeys: Array(savedTreble), bassKeys: Array(savedBass),
                                                  dailyGoal: dailyGoal)
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
                    trebleKeys = Set(profile.trebleKeys)
                    bassKeys = Set(profile.bassKeys)
                    dailyGoal = profile.dailyGoal
                }
            }
        }
    }
}
