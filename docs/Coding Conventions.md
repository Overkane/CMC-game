# Godot Coding Conventions

## Useful links

- [GDScript style guide](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_styleguide.html#)
- [Godot Best Practices](https://docs.godotengine.org/en/latest/tutorials/best_practices/index.html#best-practices)

---
## General Guidelines

- Use explicit strict typing whenever possible. E.g. `var my_int_var: int = 5`, `func myFunc() -> void`.
- Set node properties before adding it to the node tree whenever possible.
- Array - use PackedArrays whenever possible for big arrays (expected more than 1000 elements).
- Array - prefer to add and remove elements from the end, since it is the fastest.

---
## Naming Conventions

| Type              | Convention                | Example                       |
| ----------------- | ------------------------- | ----------------------------- |
| File names        | snake_case                | `yaml_parser.gd`              |
| Class names       | PascalCase                | `class_name YAMLParser`       |
| Node names        | PascalCase                | `Camera3D`, `Player`          |
| Functions         | camelCase                 | `func loadLevel():`           |
| Private Functions | _camelCase                | `func _loadLevel():`          |
| Variables         | camelCase                 | `var particleEffect`          |
| Private Variables | _camelCase                | `var _particleEffect`         |
| Signals           | camelCase                 | `signal doorOpened`           |
| Signal functions  | on{NodeName}_{signalName} | `onArea2D_bodyEntered`        |
| Constants         | CONSTANT_CASE             | `const MAX_SPEED = 200`       |
| Private Constants | _CONSTANT_CASE            | `const _MAX_SPEED = 200`      |
| Enum names        | PascalCase                | `enum Element`                |
| Enum members      | CONSTANT_CASE             | `{ EARTH, WATER, AIR, FIRE }` |

---
## Project Structure

- `/addons/` - godot plugins.
- `/assets/` - sounds, music, art and etc. For each asset type another sub-folder should be created. E.g. `/assets/music/`.
- `/docs/` - project documentation, except README.md.
- `/scenes/` - godot scenes goes there with their scripts. E.g. `/scenes/main/main.tscn` and `/scenes/main/main.gd`.
- `/autoloads/` - autoloads.

---
## Formatting

- Always use one space around operators and after commas. Also, avoid extra spaces in dictionary references and function calls. One exception to this is for single-line dictionary declarations, where a space should be added after the opening brace and before the closing brace. This makes the dictionary easier to visually distinguish from an array, as the `[]` characters look close to `{}` with most fonts. E.g.
 ```
position.x = 5
position.y = target_position.y + 10
dict["key"] = 5
my_array = [4, 5, 6]
my_dictionary = { key = "value" }
print("foo")
```
- Use 2 empty lines separator: between variables and functions block; between functions blocks, e.g. public and private functions or built-in overridable functions and custom methods.
- Don't omit the leading or trailing zero in floating-point numbers. Otherwise, this makes them less readable and harder to distinguish from integers at a glance. E.g. `0.234`not `.234`
- Use `and`, `or` and `not` instead of their analogues.
- Keep maximum line length between 80 and 100. _(code editor default vertical guidelines)_
- Use line feed (**LF**) characters to break lines, not CRLF or CR. _(editor default)_
- Use one line feed character at the end of each file. _(editor default)_
- Use **UTF-8** encoding without a [byte order mark](https://en.wikipedia.org/wiki/Byte_order_mark). _(editor default)_
- Use **Tabs** instead of spaces for indentation. _(editor default)_

---
## Code order
```
1. @tool, @icon, @static_unload
2. class_name
3. extends
4. ## doc comment

5. signals
6. enums
7. constants
8. static variables
9. @export variables
10. remaining regular variables
11. @onready variables

12. _static_init()
13. remaining static methods
14. overridden built-in virtual methods:
	1. _init()
	2. _enter_tree()
	3. _ready()
	4. _process()
	5. _physics_process()
	6. remaining virtual methods
15. overridden custom methods
16. remaining methods
17. subclasses
```
And put the class methods and variables in the following order depending on their access modifiers:
```
1. public
2. private
```
