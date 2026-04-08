import SwiftUI
import SwiftData

struct ProfileListView: View {
    @Query(sort: \Profile.createdAt) private var profiles: [Profile]
    @State private var showCreateProfile = false
    @State private var selectedProfile: Profile?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Musica")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .blue],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .padding(.top, 60)

                if profiles.isEmpty {
                    ContentUnavailableView(
                        "No Profiles Yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Create a profile to start practicing")
                    )
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 24) {
                        ForEach(profiles) { profile in
                            Button { selectedProfile = profile } label: {
                                VStack(spacing: 8) {
                                    AvatarView(name: profile.name,
                                               imageData: profile.avatarData,
                                               size: 80)
                                    Text(profile.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                Button {
                    showCreateProfile = true
                } label: {
                    Label("New Profile", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showCreateProfile) {
                CreateProfileView()
            }
            .fullScreenCover(item: $selectedProfile) { profile in
                PracticeView(profile: profile)
            }
        }
    }
}
