# Model-ViewModel-View Pattern (SwiftUI)

**Use for:** Complex views with computed properties based on environment

**Problem:** Need to compute view data from model + environment without re-computation.

**Solution:**
```swift
struct ArticleCard: View {
    // Immutable model (passed down)
    struct Model: Sendable {
        let article: Article
        let style: CardStyle
    }

    // Environment-reactive ViewModel (computed once)
    @Environment(\.designSystem) private var designSystem

    var viewModel: ViewModel {
        ViewModel(model: model, designSystem: designSystem)
    }

    struct ViewModel {
        let title: String
        let imageURL: URL?
        let backgroundColor: Color
        let foregroundColor: Color

        init(model: Model, designSystem: DesignSystem) {
            self.title = model.article.title
            self.imageURL = model.article.imageURL
            self.backgroundColor = designSystem.colorTokens.semanticBackgroundBase.color
            self.foregroundColor = designSystem.colorTokens.semanticForegroundBase.color
        }
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = viewModel.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }

            Text(viewModel.title)
                .foregroundColor(viewModel.foregroundColor)
        }
        .background(viewModel.backgroundColor)
    }
}
```

**Benefits:**
- Clear separation: Model (data) → ViewModel (presentation) → View (rendering)
- ViewModel recomputes when environment changes
- No business logic in View
- Testable ViewModels
