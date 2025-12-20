# Interaction

Apple Human Interface Guidelines for touch targets, input, navigation, layout, and hierarchy.

## Table of Contents
1. [Touch Targets and Input](#touch-targets-and-input)
2. [Navigation and Flows](#navigation-and-flows)
3. [Layout, Hierarchy, and Grouping](#layout-hierarchy-and-grouping)

## Touch Targets and Input

### Critical Rules

- Use system controls (`Button`, `Toggle`, `TextField`, `Picker`) rather than custom hit-testing
- Ensure **comfortable hit targets**; avoid tiny icons-only tap areas
- Prefer **clear labels** over icon-only actions; use SF Symbols consistently with text where appropriate
- Use appropriate keyboard/input behaviors (submit labels, autocorrection/capitalization) for the field's purpose
- Avoid gesture-only interactions for primary actions; make actions discoverable

### Examples

```swift
// ✅ Tappable control with label + icon; clear intent
Button("Add item", systemImage: "plus") {
    model.add()
}
.buttonStyle(.borderedProminent)

// ✅ TextField with appropriate keyboard
TextField("Email", text: $email)
    .keyboardType(.emailAddress)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()

// ❌ Tiny icon-only tap target; poor discoverability
Image(systemName: "plus")
    .onTapGesture {
        model.add()
    }
```

## Navigation and Flows

### Critical Rules

- Prefer **NavigationStack + navigationDestination** for drill-in flows; keep navigation shallow where possible
- Use **modals** for short, self-contained tasks (create, edit, pick); always provide a clear way to dismiss
- Keep **back behavior predictable**: don't override system expectations; preserve navigation state when reasonable
- Avoid "choice paralysis": limit top-level destinations; group related settings and utilities
- Prefer system placements: `.confirmationAction` for Save/Done, `.cancellationAction` for Cancel

### Examples

```swift
// ✅ Predictable drill-in navigation; modal only for creation
NavigationStack {
    List(items) { item in
        NavigationLink(item.title, value: item.id)
    }
    .navigationDestination(for: Item.ID.self) { id in
        ItemDetailView(id: id)
    }
    .toolbar {
        ToolbarItem(placement: .primaryAction) {
            Button("Add", systemImage: "plus") { model.isPresentingCreate = true }
        }
    }
    .sheet(isPresented: $model.isPresentingCreate) {
        NavigationStack { CreateItemView() }
    }
}

// ✅ Modal with clear dismiss path
NavigationStack {
    CreateItemView()
        .navigationTitle("New Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: model.save)
            }
        }
}

// ❌ Everything is a modal; unclear back/exit paths
VStack {
    Button("Open item") { model.showItem.toggle() }
}
.sheet(isPresented: $model.showItem) {
    ItemDetailView(id: model.selectedID)
        .toolbar { Button("Save") {} } // no Cancel, no navigation context
}
```

### Navigation Guidelines

**Use NavigationStack for**:
- Browsing hierarchical content
- Drill-down patterns
- Main app navigation

**Use Modals (.sheet, .fullScreenCover) for**:
- Creating new content
- Editing existing content
- Short, self-contained tasks
- Pickers and selections

**Always provide**:
- Clear dismiss buttons for modals
- Consistent back button behavior
- Confirmation for destructive actions

## Layout, Hierarchy, and Grouping

### Critical Rules

- Design around **content first**: prioritize the primary task and content; remove decorative UI that doesn't help comprehension
- Create **clear hierarchy**: one primary action per screen; secondary actions are visually subordinate
- Use **consistent spacing and alignment** to communicate grouping; avoid "random" padding values across the app
- Prefer system containers (`List`, `Form`, `Section`, `Toolbar`, `NavigationStack`) that encode platform layout conventions
- Avoid dense UI: keep line lengths readable and allow whitespace for scanning

### Examples

```swift
// ✅ Hierarchy + grouping via Sections; one primary action in toolbar
NavigationStack {
    List {
        Section("Details") {
            TextField("Title", text: $model.title)
            TextField("Notes", text: $model.notes, axis: .vertical)
        }

        Section("Metadata") {
            Toggle("Pinned", isOn: $model.isPinned)
        }
    }
    .navigationTitle("New item")
    .toolbar {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", action: model.save)
        }
    }
}

// ✅ Clear visual hierarchy with system components
VStack(spacing: 16) {
    // Primary action
    Button("Continue", action: model.continue)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

    // Secondary action
    Button("Skip for now", action: model.skip)
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
}

// ❌ Flat wall-of-controls with unclear priority
VStack(spacing: 3) {
    Text("New item").font(.title2)
    TextField("Title", text: $model.title).padding(1)
    TextField("Notes", text: $model.notes).padding(23)
    Toggle("Pinned", isOn: $model.isPinned)
    Button("Save", action: model.save)
    Button("Delete", action: model.delete)
}
```

### Layout Guidelines

**Visual Hierarchy**:
- One primary action per screen (prominent button style)
- Secondary actions are visually subordinate (borderless, smaller)
- Destructive actions are clearly marked (`.destructive` role)

**Spacing and Grouping**:
- Use `Section` in `List` or `Form` to group related controls
- Consistent spacing values (8, 12, 16, 20, 24)
- Whitespace communicates relationships

**System Containers**:
- `List` for browsable content
- `Form` for data entry
- `Section` for grouping
- `Toolbar` for actions
- `NavigationStack` for hierarchies

## Summary

**Key Principles**:
1. Use system controls with comfortable hit targets
2. NavigationStack for drill-down, modals for tasks
3. Always provide clear dismiss paths
4. One primary action per screen
5. Use sections and spacing for grouping
6. Prefer system containers over custom layouts
