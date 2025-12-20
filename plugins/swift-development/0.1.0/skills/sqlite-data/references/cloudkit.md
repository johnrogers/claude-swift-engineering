# CloudKit Sync

Patterns for syncing database records with CloudKit private database.

## SyncEngine Setup

### Basic Setup

```swift
let syncEngine = try SyncEngine(
  for: database,
  tables: Counter.self
)
```

### Multiple Tables

```swift
let syncEngine = try SyncEngine(
  for: database,
  tables: SyncUp.self, Attendee.self, Meeting.self
)
```

### With Delegate

```swift
let syncEngine = try SyncEngine(
  for: database,
  tables: RemindersList.self,
  RemindersListAsset.self,
  Reminder.self,
  Tag.self,
  ReminderTag.self,
  delegate: syncEngineDelegate
)
```

## Bootstrap Database with Sync

```swift
extension DependencyValues {
  mutating func bootstrapDatabase(
    syncEngineDelegate: (any SyncEngineDelegate)? = nil
  ) throws {
    defaultDatabase = try appDatabase()
    defaultSyncEngine = try SyncEngine(
      for: defaultDatabase,
      tables: RemindersList.self,
      RemindersListAsset.self,
      Reminder.self,
      Tag.self,
      ReminderTag.self,
      delegate: syncEngineDelegate
    )
  }
}
```

### In App Init

```swift
@main
struct MyApp: App {
  @State var syncEngineDelegate = MySyncEngineDelegate()

  init() {
    try! prepareDependencies {
      try $0.bootstrapDatabase(syncEngineDelegate: syncEngineDelegate)
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

## Sharing Records

### Share a Record

```swift
@Dependency(\.defaultSyncEngine) var syncEngine

func shareButtonTapped() {
  Task {
    sharedRecord = try await syncEngine.share(record: counter) { share in
      share[CKShare.SystemFieldKey.title] = "Join my counter!"
    }
  }
}
```

### Present Share Sheet

```swift
struct CounterRow: View {
  let counter: Counter
  @State var sharedRecord: SharedRecord?
  @Dependency(\.defaultSyncEngine) var syncEngine

  var body: some View {
    HStack {
      Text("\(counter.count)")
      Button {
        shareButtonTapped()
      } label: {
        Image(systemName: "square.and.arrow.up")
      }
    }
    .sheet(item: $sharedRecord) { sharedRecord in
      CloudSharingView(sharedRecord: sharedRecord)
    }
  }

  func shareButtonTapped() {
    Task {
      sharedRecord = try await syncEngine.share(record: counter) { share in
        share[CKShare.SystemFieldKey.title] = "Join my counter!"
      }
    }
  }
}
```

## Accepting Shares

### In SceneDelegate

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  @Dependency(\.defaultSyncEngine) var syncEngine
  var window: UIWindow?

  func windowScene(
    _ windowScene: UIWindowScene,
    userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
  ) {
    Task {
      try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
    }
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let cloudKitShareMetadata = connectionOptions.cloudKitShareMetadata
    else { return }

    Task {
      try await syncEngine.acceptShare(metadata: cloudKitShareMetadata)
    }
  }
}
```

### Register SceneDelegate

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role
    )
    configuration.delegateClass = SceneDelegate.self
    return configuration
  }
}

@main
struct MyApp: App {
  @UIApplicationDelegateAdaptor var delegate: AppDelegate
  // ...
}
```

## SyncEngineDelegate

### Account Change Handling

```swift
@MainActor
@Observable
class MySyncEngineDelegate: SyncEngineDelegate {
  var isDeleteLocalDataAlertPresented = false

  func syncEngine(
    _ syncEngine: SQLiteData.SyncEngine,
    accountChanged changeType: CKSyncEngine.Event.AccountChange.ChangeType
  ) async {
    switch changeType {
    case .signIn:
      // User signed into iCloud
      break
    case .signOut, .switchAccounts:
      // Prompt user to reset local data
      isDeleteLocalDataAlertPresented = true
    @unknown default:
      break
    }
  }
}
```

### Delete Local Data on Sign Out

```swift
@main
struct MyApp: App {
  @Dependency(\.defaultSyncEngine) var syncEngine
  @State var syncEngineDelegate = MySyncEngineDelegate()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .alert(
          "Reset local data?",
          isPresented: $syncEngineDelegate.isDeleteLocalDataAlertPresented
        ) {
          Button("Reset", role: .destructive) {
            Task {
              try await syncEngine.deleteLocalData()
            }
          }
        } message: {
          Text(
            """
            You are no longer logged into iCloud. Would you like to reset your local data to the \
            defaults? This will not affect your data in iCloud.
            """
          )
        }
    }
  }
}
```

## Querying Sync Metadata

### Check Share Status

```swift
@FetchAll(
  RemindersList
    .group(by: \.id)
    .leftJoin(SyncMetadata.all) { $0.syncMetadataID.eq($1.id) }
    .select {
      ReminderListState.Columns(
        remindersList: $0,
        share: $1.share
      )
    }
)
var remindersLists

@Selection
struct ReminderListState {
  var remindersList: RemindersList
  @Column(as: CKShare?.self)
  var share: CKShare?
}
```

### Display Share Status

```swift
if let share = reminderListState.share {
  if share.currentUserParticipant?.role == .owner {
    Text("Shared by you")
  } else {
    Text("Shared with you")
  }
}
```

## Database Configuration for Sync

```swift
var configuration = Configuration()
configuration.foreignKeysEnabled = true
configuration.prepareDatabase { db in
  try db.attachMetadatabase()  // Required for CloudKit sync
}

let database = try SQLiteData.defaultDatabase(configuration: configuration)
```

## Best Practices

1. **Always use `try db.attachMetadatabase()`** in database configuration
2. **Register all synced tables** in `SyncEngine` init
3. **Handle account changes** with `SyncEngineDelegate`
4. **Prompt before `deleteLocalData()`** - it's destructive
5. **Use `@Column(as: CKShare?.self)`** for share status in queries
6. **Configure `SceneDelegate`** for accepting shares
7. **Foreign keys must be enabled** for proper sync relationships
