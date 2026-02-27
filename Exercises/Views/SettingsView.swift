import SwiftUI

struct SettingsView: View {
    @AppStorage("exercises_base_url") private var baseURL: String = "http://kevin224.mikrus.xyz:40191"
    private let productionURL = "http://kevin224.mikrus.xyz:20224"
    private let devURL = "http://kevin224.mikrus.xyz:40191"

    private var tableURL: URL? {
        URL(string: baseURL + "/table")
    }

    private var isProductionBinding: Binding<Bool> {
        Binding(
            get: { baseURL == productionURL },
            set: { useProd in
                baseURL = useProd ? productionURL : devURL
            }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Server")) {
                    Toggle(isOn: isProductionBinding) {
                        HStack {
                            Text("Environment")
                            Spacer()
                            Text(isProductionBinding.wrappedValue ? "Production" : "Dev")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Current Base URL")
                        Spacer()
                        Text(baseURL)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                Section(header: Text("Table")) {
                    if let url = tableURL {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.blue)
                                Text("Open Table")
                            }
                        }
                    } else {
                        Text("Invalid URL").foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
