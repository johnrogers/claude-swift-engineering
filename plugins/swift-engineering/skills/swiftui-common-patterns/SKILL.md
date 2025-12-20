---
description: Common SwiftUI patterns (iOS 17+) — MVVM, navigation, performance, UIKit interop, accessibility
---

# SwiftUI Common Patterns

Essential UI patterns for modern SwiftUI development (iOS 17+). Use these patterns for maintainable, performant, accessible applications.

## MVVM with @Observable (iOS 17+)

**Use for:** View models with reactive state

**Problem:** Need reactive view models without @Published boilerplate.

**Solution:**
```swift
import Observation

@Observable
@MainActor
final class ArticleListViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String?

    private let articleService: ArticleService

    init(articleService: ArticleService) {
        self.articleService = articleService
    }

    func loadArticles() async {
        isLoading = true
        errorMessage = nil

        do {
            articles = try await articleService.fetchArticles()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ArticleListView: View {
    @State private var viewModel: ArticleListViewModel

    init(articleService: ArticleService) {
        _viewModel = State(wrappedValue: ArticleListViewModel(articleService: articleService))
    }

    var body: some View {
        List(viewModel.articles) { article in
            ArticleRow(article: article)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
        .task {
            await viewModel.loadArticles()
        }
    }
}
```

**Benefits:**
- No `@Published` needed
- Fine-grained observation (only tracks accessed properties)
- Better performance than ObservableObject
- Less boilerplate

## NavigationStack Patterns (iOS 16+)

**Use for:** Type-safe programmatic navigation

**Problem:** Need programmatic navigation with deep linking support.

**Solution:**
```swift
// Navigation coordinator
@Observable
@MainActor
final class NavigationCoordinator {
    var path = NavigationPath()

    func navigateTo(_ article: Article) {
        path.append(article)
    }

    func navigateToAuthor(_ author: Author) {
        path.append(author)
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

// App navigation
struct AppNavigationView: View {
    @State private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ArticleListView()
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
                .navigationDestination(for: Author.self) { author in
                    AuthorProfileView(author: author)
                }
                .environment(coordinator)
        }
    }
}

// Usage in views
struct ArticleListView: View {
    @Environment(NavigationCoordinator.self) private var coordinator

    var body: some View {
        List(articles) { article in
            Button {
                coordinator.navigateTo(article)
            } label: {
                ArticleRow(article: article)
            }
        }
    }
}
```

**Benefits:**
- Type-safe navigation
- Programmatic control
- Deep linking ready
- Centralized navigation logic

## Performance Optimization Patterns

### Lazy Loading

**Use for:** Long scrollable lists

```swift
// Bad: Loads all items immediately
ScrollView {
    VStack {
        ForEach(articles) { article in
            ArticleCard(article: article)
        }
    }
}

// Good: Loads items on-demand
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(articles) { article in
            ArticleCard(article: article)
                .onAppear {
                    // Pagination trigger
                    if article == articles.last {
                        loadMoreArticles()
                    }
                }
        }
    }
}
```

### View Identity

**Use for:** Efficient list rendering

```swift
// Ensure all items are Identifiable
struct Article: Identifiable {
    let id: String
    let title: String
}

// SwiftUI can efficiently diff changes
ForEach(articles) { article in
    ArticleRow(article: article)
}

// Or provide manual ID
ForEach(articles, id: \.id) { article in
    ArticleRow(article: article)
}
```

### Equatable Views

**Use for:** Skipping unnecessary re-renders

```swift
struct ArticleRow: View, Equatable {
    let article: Article

    static func == (lhs: ArticleRow, rhs: ArticleRow) -> Bool {
        lhs.article.id == rhs.article.id
    }

    var body: some View {
        HStack {
            Text(article.title)
            Spacer()
            Text(article.author)
                .foregroundColor(.secondary)
        }
    }
}

// Usage: SwiftUI skips re-rendering if article ID unchanged
ForEach(articles) { article in
    ArticleRow(article: article)
        .equatable()
}
```

### Debounced Search

**Use for:** Search fields with live filtering

```swift
@Observable
@MainActor
final class SearchViewModel {
    var searchText = ""
    var results: [Article] = []

    private var searchTask: Task<Void, Never>?

    func updateSearch(_ text: String) {
        searchText = text

        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            results = await performSearch(text)
        }
    }

    private func performSearch(_ query: String) async -> [Article] {
        // Search logic
        []
    }
}

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.searchText)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    viewModel.updateSearch(newValue)
                }

            List(viewModel.results) { article in
                ArticleRow(article: article)
            }
        }
    }
}
```

## UIKit Interoperability

### UIViewRepresentable

**Use for:** Wrapping UIKit views in SwiftUI

```swift
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }
    }
}

// Usage
struct ArticleWebView: View {
    let url: URL
    @State private var isLoading = false

    var body: some View {
        WebView(url: url, isLoading: $isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
    }
}
```

### UIViewControllerRepresentable

**Use for:** Presenting UIKit view controllers

```swift
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image, dismiss: dismiss)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var image: UIImage?
        let dismiss: DismissAction

        init(image: Binding<UIImage?>, dismiss: DismissAction) {
            _image = image
            self.dismiss = dismiss
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.image = image as? UIImage
                    }
                }
            }
        }
    }
}

// Usage
struct ProfileEditView: View {
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            }

            Button("Choose Photo") {
                showImagePicker = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}
```

## Accessibility Patterns

### VoiceOver Support

**Use for:** Screen reader accessibility

```swift
struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack {
            AsyncImage(url: article.imageURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .accessibilityHidden(true) // Decorative image

            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.headline)
                Text(article.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title), by \(article.author)")
        .accessibilityHint("Double tap to read article")
    }
}
```

### Dynamic Type Support

**Use for:** Text that scales with user preferences

```swift
struct ArticleContent: View {
    let article: Article
    @ScaledMetric private var imageHeight: CGFloat = 200

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: article.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: imageHeight) // Scales with Dynamic Type
                .clipped()

                Text(article.title)
                    .font(.title)

                Text(article.content)
                    .font(.body)
            }
        }
    }
}
```

### Accessibility Actions

**Use for:** Custom VoiceOver actions

```swift
struct ArticleCard: View {
    let article: Article
    @State private var isSaved = false
    @State private var isShared = false

    var body: some View {
        VStack {
            Text(article.title)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
        .accessibilityAction(named: "Save") {
            isSaved.toggle()
        }
        .accessibilityAction(named: "Share") {
            isShared = true
        }
    }
}
```

## Async Operation Patterns

### Task Modifier

**Use for:** Loading data when view appears

```swift
struct ArticleDetailView: View {
    let articleId: String
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let article {
                ArticleContent(article: article)
            } else if isLoading {
                ProgressView()
            } else {
                ContentUnavailableView("Article Not Found", systemImage: "doc.text")
            }
        }
        .task {
            await loadArticle()
        }
    }

    private func loadArticle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            article = try await articleService.fetchArticle(id: articleId)
        } catch {
            print("Error loading article: \(error)")
        }
    }
}
```

### Refreshable Content

**Use for:** Pull-to-refresh lists

```swift
struct ArticleListView: View {
    @State private var articles: [Article] = []

    var body: some View {
        List(articles) { article in
            ArticleRow(article: article)
        }
        .refreshable {
            await refreshArticles()
        }
    }

    private func refreshArticles() async {
        do {
            articles = try await articleService.fetchArticles()
        } catch {
            print("Error refreshing: \(error)")
        }
    }
}
```

### Background Tasks

**Use for:** Non-blocking async operations

```swift
struct ArticleDetailView: View {
    let article: Article
    @State private var isSaved = false

    var body: some View {
        ArticleContent(article: article)
            .toolbar {
                Button(isSaved ? "Saved" : "Save") {
                    Task {
                        await saveArticle()
                    }
                }
            }
    }

    private func saveArticle() async {
        do {
            try await articleService.saveArticle(article)
            isSaved = true
        } catch {
            print("Error saving: \(error)")
        }
    }
}
```

## View Composition Patterns

### ViewBuilder for Conditional Content

**Use for:** Complex conditional UI

```swift
struct ArticleCard: View {
    let article: Article
    let style: CardStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            contentView
            footerView
        }
        .padding()
        .background(backgroundView)
    }

    @ViewBuilder
    private var headerView: some View {
        if let imageURL = article.imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .clipped()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        Text(article.title)
            .font(.headline)

        if style == .detailed {
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
    }

    @ViewBuilder
    private var footerView: some View {
        HStack {
            Text(article.author)
                .font(.caption)
            Spacer()
            Text(article.publishedAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.background)
            .shadow(radius: 2)
    }
}
```

### Custom View Modifiers

**Use for:** Reusable styling

```swift
struct CardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.background)
                    .shadow(radius: shadowRadius)
            )
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 2) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// Usage
struct ArticleRow: View {
    let article: Article

    var body: some View {
        VStack {
            Text(article.title)
        }
        .cardStyle()
    }
}
```

## When to Use Each Pattern

| Pattern | Use When | Don't Use When |
|---------|----------|----------------|
| @Observable | iOS 17+, reactive state | iOS 16 and earlier |
| NavigationStack | Programmatic navigation | Simple NavigationLink only |
| LazyVStack | Long lists (100+ items) | Short lists (<50 items) |
| Equatable | Complex views re-rendering | Simple views |
| UIViewRepresentable | UIKit features not in SwiftUI | SwiftUI equivalent exists |
| VoiceOver labels | All interactive elements | Pure decorative views |
| Task modifier | Async on appear | Immediate sync data |
| Custom modifiers | Repeated styling (3+ uses) | One-off styling |

## Quick Reference

```swift
// Observable view model
@Observable @MainActor final class ViewModel { var state: State }

// Navigation
@Observable final class Coordinator { var path = NavigationPath() }

// Performance
LazyVStack { ForEach(items, id: \.id) { item in Row(item) } }

// UIKit bridge
struct UIKitView: UIViewRepresentable { }

// Accessibility
.accessibilityLabel("Title")
.accessibilityHint("Action hint")

// Async
.task { await load() }
.refreshable { await refresh() }

// Composition
@ViewBuilder var content: some View { if condition { A } else { B } }

// Custom modifiers
extension View { func cardStyle() -> some View { modifier(CardStyle()) } }
```
