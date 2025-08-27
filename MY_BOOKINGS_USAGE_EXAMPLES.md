# MyBookingsView Usage Examples

## Overview

The `MyBookingsView` now supports multiple usage patterns:

1. **Embedded View** - As part of another page (default)
2. **Full Page** - With AppBar for standalone pages
3. **Searchable Page** - With search and filter actions

## Usage Patterns

### 1. Embedded View (Default)

Use this when you want to include the bookings view as part of another page:

```dart
// In a TabBarView, Column, or any other widget
MyBookingsView()

// Or with custom key
MyBookingsView(key: Key('bookings'))
```

### 2. Full Page with AppBar

Use this when you want to show the bookings as a standalone page:

```dart
// Basic full page
MyBookingsView.createFullPage()

// With custom title
MyBookingsView.createFullPage(
  title: 'My Service Bookings',
)

// With custom actions
MyBookingsView.createFullPage(
  title: 'My Bookings',
  actions: [
    IconButton(
      icon: Icon(Icons.add),
      onPressed: () => print('Add new booking'),
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => print('Settings'),
    ),
  ],
)

// Without back button (for root pages)
MyBookingsView.createFullPage(
  automaticallyImplyLeading: false,
)
```

### 3. Searchable Page

Use this when you want search and filter functionality:

```dart
// Basic searchable page
MyBookingsView.createSearchablePage()

// With custom title
MyBookingsView.createSearchablePage(
  title: 'Search Bookings',
)

// Without back button
MyBookingsView.createSearchablePage(
  automaticallyImplyLeading: false,
)
```

## Navigation Examples

### Navigate to Full Page

```dart
// Navigate to bookings page
Get.to(() => MyBookingsView.createFullPage(
  title: 'My Bookings',
));

// Navigate and replace current page
Get.off(() => MyBookingsView.createFullPage(
  title: 'My Bookings',
));

// Navigate to root (no back button)
Get.offAll(() => MyBookingsView.createFullPage(
  title: 'My Bookings',
  automaticallyImplyLeading: false,
));
```

### Navigate to Searchable Page

```dart
// Navigate to searchable bookings page
Get.to(() => MyBookingsView.createSearchablePage(
  title: 'Search Bookings',
));
```

## Integration Examples

### In a TabBarView

```dart
TabBarView(
  children: [
    // Other tabs...
    MyBookingsView(), // Embedded view
    // Other tabs...
  ],
)
```

### In a Drawer

```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: Icon(Icons.book),
        title: Text('My Bookings'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Get.to(() => MyBookingsView.createFullPage(
            title: 'My Bookings',
          ));
        },
      ),
      // Other drawer items...
    ],
  ),
)
```

### In a Bottom Navigation

```dart
IndexedStack(
  index: _currentIndex,
  children: [
    // Other pages...
    MyBookingsView(), // Embedded view
    // Other pages...
  ],
)
```

## Customization

### Custom AppBar Styling

The AppBar uses the app's primary color by default. To customize:

```dart
// Create a custom version with different styling
class CustomMyBookingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Bookings'),
        backgroundColor: Colors.blue, // Custom color
        foregroundColor: Colors.white,
        elevation: 4, // Custom elevation
        // Other customizations...
      ),
      body: MyBookingsView(), // Use embedded view
    );
  }
}
```

### Custom Actions

```dart
MyBookingsView.createFullPage(
  title: 'My Bookings',
  actions: [
    // Search action
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () => _showSearchDialog(),
    ),
    // Filter action
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => _showFilterDialog(),
    ),
    // More options
    PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) => _handleMenuSelection(value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'export',
          child: Text('Export'),
        ),
        PopupMenuItem(
          value: 'share',
          child: Text('Share'),
        ),
      ],
    ),
  ],
)
```

## Best Practices

1. **Use embedded view** when the bookings are part of a larger page
2. **Use full page** when navigating to bookings as a standalone feature
3. **Use searchable page** when users need to find specific bookings
4. **Customize actions** based on your app's specific needs
5. **Handle navigation** appropriately (back button, drawer, etc.)

## Notes

- The embedded view maintains all existing functionality
- The full page versions add an AppBar with consistent styling
- Search and filter actions are placeholders - implement actual functionality as needed
- All versions use the same controller and data
- The view automatically handles loading, error, and empty states
