# Tool Calling

## Why Tools Are Needed

The 3B model will hallucinate external data:

```swift
// BAD - Model will make up weather
let response = try await session.respond(to: "Weather in Tokyo?")
```

Tools let the model call your code to fetch real data.

## Tool Protocol

```swift
protocol Tool {
    var name: String { get }
    var description: String { get }
    associatedtype Arguments: Generable
    func call(arguments: Arguments) async throws -> ToolOutput
}
```

## Weather Tool Example

```swift
struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Get current weather for a city"

    @Generable
    struct Arguments {
        @Guide(description: "City name")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let places = try await CLGeocoder().geocodeAddressString(arguments.city)
        let weather = try await WeatherService.shared.weather(for: places.first!.location!)
        return ToolOutput("Temperature: \(weather.currentWeather.temperature.value)F")
    }
}
```

## Using Tools

```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help with weather forecasts."
)

let response = try await session.respond(to: "What's the temperature in Cupertino?")
// Model calls GetWeatherTool, uses real data in response
```

## How It Works

1. User prompt arrives
2. Model decides it needs external data
3. Model generates tool call with @Generable arguments
4. Framework calls your `call()` method
5. Tool output inserted into transcript
6. Model generates final response using real data

## Stateful Tools

Use `class` to track state across calls:

```swift
class FindContactTool: Tool {
    var pickedContacts = Set<String>()

    func call(arguments: Arguments) async throws -> ToolOutput {
        contacts.removeAll(where: { pickedContacts.contains($0.name) })
        guard let picked = contacts.randomElement() else {
            return ToolOutput("No more contacts")
        }
        pickedContacts.insert(picked.name)
        return ToolOutput(picked.name)
    }
}
```

## Multiple Tools

```swift
let session = LanguageModelSession(
    tools: [GetWeatherTool(), FindRestaurantTool(), FindHotelTool()],
    instructions: "Plan travel itineraries."
)
// Model autonomously decides which tools to call
```

## ToolOutput Options

```swift
// Natural language
return ToolOutput("Temperature is 71F")

// Structured
return ToolOutput(GeneratedContent(properties: ["temperature": 71]))
```

## Tool Naming

- Short, readable: `getWeather`, `findContact`
- Use verbs: `get`, `find`, `fetch`
- Concise descriptions (they're in the prompt)

## When to Use Tools

**Use for:** Weather, MapKit, Contacts, Calendar, external APIs
**Don't use for:** Data already in prompt, simple calculations
