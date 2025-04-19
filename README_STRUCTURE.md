# day_tracker Project Structure

The project has been reorganized according to a feature-based architecture with Clean Architecture principles.

## Core Components

Core components are shared across different features and define the foundation of the application.

- **Core/Database**: Contains database-related base classes and utilities
- **Core/Encryption**: Encryption services
- **Core/Log**: Logging functionalities
- **Core/Navigation**: Navigation-related components
- **Core/Settings**: App settings components
- **Core/Theme**: Theme definition and services
- **Core/Utils**: Common utilities
- **Core/Provider**: Core providers like theme

## Feature Components

Each feature follows a Clean Architecture structure:

- **data**: Contains models and repositories
  - **models**: Data classes
  - **repositories**: Implementation of data access
- **domain**: Business logic layer
  - **providers**: State management
- **presentation**: UI layer
  - **pages**: Screen definitions
  - **widgets**: UI components

### Features

1. **about**: About page
2. **app**: Main application structure
3. **authentication**: User authentication functionality
4. **calendar**: Calendar feature
5. **dashboard**: Home page and dashboard components
6. **day_rating**: Diary day rating functionality
7. **notes**: Notes functionality
8. **synchronization**: Data synchronization features

## Benefits of This Structure

1. **Maintainability**: Each feature is isolated and can be maintained independently
2. **Testability**: Clear separation of concerns makes testing easier
3. **Scalability**: Easy to add new features without affecting existing code
4. **Organization**: Code is organized by feature rather than by technical layer, making it easier to understand

## Import Convention

Use the following import pattern:
```dart
// Core components
import 'package:day_tracker/core/[component]/[file].dart';

// Feature components
import 'package:day_tracker/features/[feature]/[layer]/[type]/[file].dart';
``` 