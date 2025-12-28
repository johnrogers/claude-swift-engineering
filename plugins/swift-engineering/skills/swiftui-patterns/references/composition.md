# View Composition Patterns

## ViewBuilder for Conditional Content

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

## Custom View Modifiers

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
