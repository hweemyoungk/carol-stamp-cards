# expense_tracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Lecture Mote

### *class* Icon

#### *class* IconData

- Predefined IconData in *class* Icons

### *class* Opacity

- Gives its child an opcaity
- *Not to be abused*: can be performance issue
- Use *property* Color.alpha instead, whenever possible.

### Lifting up State

Child widget handles parent widget state.

#### @override void initState

- Called only once after object being instantiated.

### Widget Lifecycle

1. initState: after initialization
2. build: after first build or after `setState()` was called
3. dispose: after widget is deleted

### Data Model and Data

Non-flutter objects

### Custom font

Font packages available in pub.dev

`flutter pub add ...`

### `State.widget`: Access to State's Widget

In this way, **State does not need custom Constructor** that accepts args from Widget.

### *class* Expanded

Prevents overflow **of child** in Column or Row.

> Creates a widget that expands a child of a [Row], [Column], or [Flex] so that the child fills the available space along the flex widget's main axis.

### *class* SingleChildScrollView

Scroll the child `Column`.

### *class* ListView

For unknown length of (potentially too many) items, use instead of `Column`.

- ListView is scrollable by default.

#### ListView.builder

parameters are:
- `itemCount`: How many items rendered eventually. `index` of `itemBuilder` increments up to `itemCount - 1`.

### *class* Card

Useful properties like

- `margin`
- `shape`
- `clipBehavior`: How to deal with its child overflow from card boundary.

### *class* Spacer

Takes up all possible space between widgets in Row or Column.

### package `intl`

Just like `Intl` in JS, supports DateTime internationalization.

### *class* AppBar

Something like NavBar

#### AppBar.actions

Usually accepts Buttons

### Context of a Widget

Every Widget has its own `context` property in which its parent widget is specified.

### *class* TextField

Input field for text.

#### TextField.maxLength

#### TextField.keyboardType

### *class* InputDecoration

Decoration for input widgets

#### InputDecoration.label

Similar to `<label>` for `input`

#### InputDecoration.prefixText

Text preceding the input text.

### *class* TextEditingController

Stores editable text input within it.
Can access current text with `TextEditingController.text`

**Composite controllers should be explicitly disposed** in widget's `@override dispose` method.

### *global function* showModalBottomSheet

Modal from bottom.

- showModalBottomSheet.isScrollControlled: When true, takes full screen.
- showModalBottomSheet.useSafeArea: When true, avoids area occupied by device.

### *class* Navigator

#### Navigator.pop(BuildContext)

Closes widget of the context. (e.g., Modal)

#### Navigator.pop(BuildContext, result)

Returns result to lower widget when pops

#### Navigator.push(BuildContext, Route)

Push a screen on top of context screen.
New screen's AppBar has Back button, which pops the current screen.

#### Navigator.pushReplacement(BuildContext, Route)

pop and push (Replace active screen)

### *global function* showDatePicker

### *global function* showDialog

### *class* AlertDialog

- AlertDialog.title
- AlertDialog.content
- AlertDialog.actions

### *class* Dismissible

Can remove(e.g., swipe away) key widget from UI. 
**onDismissed handler must remove key widget from tree.**

- Dismissible.onDismissed:
- Dismissible.key: To identify widget to be deleted. Supply with `ValueKey()`. 

### *class* ScaffoldMessenger

- ScaffoldMessenger.of(BuildContext): Create ScaffoldMessenger on widget of the context.
- ScaffoldMessenger.showSnackBar(SnackBar): Display snackbar
- ScaffoldMessenger.clearSnackBars(): Clear all snackbars being displayed.


### *class* SnackBar

- SnackBar.content
- SnackBar.duration
- SnackBar.action

### *class* MaterialApp

#### MaterialApp.colorScheme

Accepts ColorScheme.

### *class* ColorScheme

#### ColorScheme.fromSeed(Color)

### *class* Theme

#### Theme.of(BuildContext)

Gets `ThemeData` object in current context.

### SystemChrome.setPreferredOrientations(List<DeviceOrientation>)

Determines available orientations for current app.
`WidgetsFlutterBinding.ensureInitialized();` must be preceded.

### *class* MediaQuery

Stores device information.

#### MediaQuery.viewInsets

> The parts of the display that are completely obscured by system UI, typically by the device's keyboard.

### Switching device orientation re-renders UI in Flutter!

### Widget size preference & constraint

- Scaffold **contrains** child's height, width to those of max device.
- Column **prefers** infinite height and width just needed by children.

### *class* LayoutBuilder

Builds widget with help of accessing constraints from parent widget

### *class* Platform in `dart:io`

Contains current platform.

- Platform.isIOS
- Platform.isAndroid
- ...

### Three Trees

- Widget tree
- Element tree: In-memory representation of widgets
- Render tree: visible UI building block

### Key

`State` is bound to element, so even if element changes widget to reference, state stays unchanged.
If we set *key* to widget, corresponding element is bound to widget, so element tree synces to widget tree change, hence widget references the same state object.
So creating `StatefulWidget` where its state is bound to a specific data model, assign widget a key with data model's ID(`ValueKey`) or data model itself as a key(`ObjectKey`).

Typical key type is:
- ValueKey(dynamic)
- ObjectKey(Object)

### *class* GridView

Creates grid. Similar to `ListView`.
- Main axis is top to bottom.
- Cross axis is left to right.

#### GridView.builder

Similar to `ListView.builder`. Constrains itemCount.

### *class* SilverGridDelegate

Controls the layout of GridView.

### *class* SliverGridDelegateWithFixedCrossAxisCount

Extends `SilverGridDelegate`. Sets column count.

- `crossAxisCount`: Column count
- `childAspectRatio`: (Vertical) / (Horizontal)
- `crossAxisSpacing`, `mainAxisSpacing`: Spaces between axes

### *class* InkWell

Gives a variety of color feedback for interactions

### *class* Stack

Widget that overlaps children widgets

- `children`: defines stack of widgets **from bottom to top**

#### *class* Positioned

In `Stack`, `Positioned` widget controls its coord relative to the lower widget.

### *class* FadeInImage

Image widget that fades in.

- `placeholder`: Image while loading
- `fit`: How image should deal with empty space

### *class* MemoryImage

Image provider reading byte array from memory.

### *class* NetworkImage

Image provider through network IO.

### *class* BottomNavigationBar

`Scaffold.bottomNavigationBar` accepts this.

- `BottomNavigationBar.onTap`: accepts function that provides index of tapped item.
- `BottomNavigationBar.currentIndex`: index of item to be highlighted.

#### *class* BottomNavigationBarItem

### *class* Drawer

`Scaffold.drawer` accepts this.
`Drawer.child` can take `Column`.

#### *class* DrawerHeader

### *class* ListTile

- ListTile.leading
- ListTile.title

### *class* SwitchListTile

- SwitchListTile.value: initial switch value
- SwitchListTile.onChanged
- SwitchListTile.title
- SwitchListTile.subtitle

### *class* WillPopScope

A way for screen to return data when pop.

- WillPopScope.onWillPop: invoked when user pops. `Future` of `false` will prevent pop. `Future` of `true` will invoke pop.

### *package* Riverpod

Cross-widget state management

Alternatives: Provider, ...

Install: `flutter pub add flutter_riverpod`

### *class* ConsumerStatefulWidget

`StatefulWidget` for Riverpod

### *class* ConsumerState<T>

- `ConsumerState.ref.watch(Provider)`: When called in `ConsumerState.build`, invokes `ConsumerState.build` whenever `Provider` changes.

### *class* ProviderScope

Accepts child where it and its nested children use `Provider`.
e.g.,

```dart
void main() {
  runApp(const ProviderScope(
    child: App(),
  ));
}
```

### *class* StateNotifierProvider<NotifierT extends StateNotifier<T>, T>

Positional argument returns `StateNotifier` object.

```dart
final favoritesProvider = StateNotifierProvider<FavoriteMealsNotifier, List<Meal>>(
  (ref) {
    return FavoriteMealsNotifier();
  },
);
```

### *class* StateNotifier<T>

1. Initial state

```dart
class FavoriteMealsNotifier extends StateNotifier<List<Meal>> {
  FavoriteMealsNotifier() : super([]);
}
```

2. All methods for changing state

`StateNotifier.state` stores current state.
**Never** use in-place operation. Always bind a new object.

### *class* ConsumerWidget

`StatelessWidget` for Riverpod.

### *class* WidgetRef

- WidgetRef.watch(Provider): Called in `build` method, gets current state and rebuilds widget.
- WidgetRef.read(Provider.notifier).notifierMethod(): Called in event handler, changes the state of provider

### Explicit Animation

### *class* AnimationController

- `AnimationController.vsync`: Accepts TickerProvider (usually, `this`).
- `AnimationController.duration`: Duration of animation
- `AnimationController.value`: Current tick between `lowerbound` and `upperbound`
- `AnimationController.lowerbound`: Initial `AnimationController.value`
- `AnimationController.upperbound`: Last `AnimationController.value`
- `AnimationController.forward()`: Starts animation.
- `AnimationController.drive(Tween)`

### *mixin* SingleTickerProviderStateMixin

Mixin for `State` with single `AnimationController` property.

### *class* AnimatedBuilder

Widget that renders animated child widget

- `AnimatedBuilder.animation`: Accepts `AnimationController`
- `AnimatedBuilder.child`: Final widget that is not rebuilt during animation
- `AnimatedBuilder.builder`: returns widget that is rebuilt during animation.

### *class* ...Transition

#### *class* SlideTransition

### *class* Tween

- `Tween.begin`, `Tween.end`: Accepts Offset
- `Tween.animate(Animation)`: Similart to `AnimationController.drive(Tween)`

### Implicit Animation

[List of implicit animation widgets](https://docs.flutter.dev/ui/widgets/animation).
Plays animation whenever child widget is rebuilt.
Child widget **must** have `key` set for animation to detect state change.

#### *class* AnimatedSwitcher

Animation between two states.

`AnimatedSwitcher.transitionBuilder`

#### *class* Hero

Multiple `Hero`es with same `tag` renders animation between screens.

- `Hero.tag`: 

### *class* Form

Utilizes `...FormField` widgets.

- `Form.key`: Usually accepts `GlobalKey<FormState>()` to prevent rebuild and always store internal state.

#### *class* FormState

- `_formKey.currentState!.validate()`: Call this method in event handler where **all** validation should run.
- `_formKey.currentState!.save()`: Invokes every `...FormField.onSaved` in current `Form` **synchronously**. `onSaved` usually stores current value to a state.
- `_formKey.currentState!.reset()`: Call this method in event handler where all FormField should be reset.

#### *class* TextFormField

Use this under `Form` instead of `TextField`

- `TextFormField.validator`: returns message if validation failed, otherwise null.

#### *class* DropdownButtonFormField

Use this under `Form` instead of `DropdownButton`

- `DropdownButtonFormField.items`
- `DropdownButtonFormField.value`: Unlike `TextFormField`, `DropdownButtonFormField` stores value as internal state. Must invoke `setState()` (?)

##### *class* DropdownMenuItem

- `DropdownMenuItem.value`
- `DropdownMenuItem.child`

### *package* http

### *class* BuildContext

- `BuildContext.mounted`: Where this widget is mounted on Widget tree. Check `.mounted` before controlling `context` in async function.

### *class* CircularProgressIndicator

### *class* FutureBuilder

- `FutureBuilder.future`: `Future` which `builder` listens to.
- `FutureBuilder.builder`: Invoked when `Future` is completed.

#### *class* AsyncSnapshot<T>

- `AsyncSnapshot.connectionState`
- `AsyncSnapshot.hasError` & `AsyncSnapshot.error`
- `AsyncSnapshot.hasData` & `AsyncSnapshot.data`


