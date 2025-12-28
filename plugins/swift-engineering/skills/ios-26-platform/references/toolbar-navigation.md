# Toolbar & Navigation

**iOS 26+**

## Toolbar Spacer API

### Separate Button Groups
```swift
.toolbar {
    ToolbarItemGroup(placement: .topBarTrailing) {
        // Navigation group
        Button("Up") { }
        Button("Down") { }

        Spacer(.fixed) // Separates groups visually

        // Action group
        Button("Settings") { }
    }
}
```

**Visual Effect**: Items within group share Liquid Glass background. `.fixed` creates clear separation.

### Flexible Spacer
```swift
.toolbar {
    ToolbarSpacer(.flexible, placement: .topBarTrailing)

    ToolbarItem(placement: .topBarTrailing) {
        Button(role: .close) {
            dismiss()
        }
    }
}
```

## Prominent Toolbar Buttons

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button("Add Trip") {
            addTrip()
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue) // Tinting works with Liquid Glass
    }
}
```

**Best Practice**: Use for primary actions. Don't over-tint.

## Close & Confirm Buttons

```swift
.sheet(isPresented: $showSheet) {
    NavigationStack {
        VStack { }
            .navigationTitle("Info")
            .toolbar {
                ToolbarSpacer(.flexible, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) { // X icon with glass
                        showSheet = false
                    }
                }
            }
    }
    .presentationDetents([.medium])
}
```

## Search Placement

### Automatic Platform Placement
```swift
NavigationSplitView {
    List { }
        .searchable(text: $searchText)
}
// iPhone: Bottom-aligned (ergonomic)
// iPad: Top trailing corner
```

### Search Tab Role
```swift
TabView {
    SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
        .tabRole(.search) // Separated, morphs into search field

    TripsView()
        .tabItem { Label("Trips", systemImage: "map") }
}
```

### Compact Search Toolbar
```swift
List { ... }
    .navigationTitle("Search Users")
    .searchable(text: $searchText)
    .searchToolbarBehavior(.minimize) // Compact when unfocused
    .toolbar {
        ToolbarSpacer(.flexible, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
```

### Prevent Title Hiding (iOS 17.1+)
```swift
.searchable(text: $searchText)
.searchPresentationToolbarBehavior(.avoidHidingContent)
```

## Tab Bar Adaptations

### Sidebar Adaptable
```swift
TabView {
    ContentView()
        .tabItem { Label("Home", systemImage: "house") }
}
.tabViewStyle(.sidebarAdaptable)
// iPad: Can switch to sidebar
// iPhone: Remains tab bar
```

### Tab Bar Minimization
```swift
TabView { ... }
    .tabBarMinimizationBehavior(.onScrollDown)
// .onScrollDown - Minimize when scrolling down
// .onScrollUp - Minimize when scrolling up
// .automatic - System decides
// .never - Always visible
```

## Navigation Hierarchy

### Clear Layer Separation
```
Navigation Layer (Liquid Glass)
├── Tab bar
├── Navigation bar
├── Toolbar
└── Floating controls

Content Layer (No Glass)
└── Lists, tables, images, text
```

### Split Views
```swift
NavigationSplitView {
    // Sidebar (gets glass automatically)
    List(folders, selection: $selectedFolder) {
        Label($0.name, systemImage: $0.icon)
    }
} content: {
    // Main content
    List(items, selection: $selectedItem) { ... }
} detail: {
    // Inspector
    InspectorView(item: selectedItem)
}
```

## Menus

### Standard Actions Get Icons Automatically
```swift
Menu("Actions") {
    Button(action: cut) { Text("Cut") }    // Gets scissors icon
    Button(action: copy) { Text("Copy") }   // Gets documents icon
    Button(action: paste) { Text("Paste") } // Gets clipboard icon
}
```

### Match Swipe and Context Menu Actions
```swift
List(emails) { email in
    EmailRow(email)
        .swipeActions(edge: .trailing) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete(email)
            }
        }
        .contextMenu {
            // Same actions at top of menu
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete(email)
            }
            Divider()
            // Additional actions below
        }
}
```

## iPad Menu Bar

```swift
.commands {
    TextEditingCommands()

    CommandGroup(after: .newItem) {
        Button("Add Note") {
            addNote()
        }
        .keyboardShortcut("n", modifiers: [.command, .shift])
    }
}
// Creates menu bar on iPad via swipe down
```

## Icons vs Text in Toolbars

### Consistent Style Per Group
```swift
// Correct: All icons in group
.toolbar {
    ToolbarItemGroup {
        Button { share() } label: {
            Image(systemName: "square.and.arrow.up")
        }
        Button { save() } label: {
            Image(systemName: "square.and.arrow.down")
        }
    }
}

// Wrong: Mixed icons and text
.toolbar {
    ToolbarItemGroup {
        Button("Save") { } // Text
        Button { } label: { Image(systemName: "...") } // Icon
    }
}
```

### Accessibility Labels Required
```swift
Button {
    share()
} label: {
    Image(systemName: "square.and.arrow.up")
}
.accessibilityLabel("Share")
```
