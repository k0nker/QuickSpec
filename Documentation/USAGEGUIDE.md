# QuickSpec — Usage Guide

QuickSpec is a lightweight specialization switcher for World of Warcraft. It gives you a clean popup frame for switching specs with a click, a full suite of slash commands for keyboard or macro use, and support for macro conditionals so you can bind multiple specs to a single button.

---

## Opening the Frame

Press your keybind or use the slash command with no arguments:

```
/qs
/quickspec
```

The popup shows your **current spec** as a large artwork card at the top. Your other available specs appear as pillar-style artwork panels below. Click any alternate spec to switch to it immediately. Click your current spec card to close the frame (you are already on that spec).

Hovering over the active spec card shows a tooltip confirming it is currently active. Hovering over an alternate spec shows its name.

---

## Slash Commands

Both `/qs` and `/quickspec` are equivalent.

| Command | Effect |
|---|---|
| `/qs` | Toggle the popup frame open/closed |
| `/qs <spec name>` | Switch directly to the named spec |
| `/qs classcolor` | Toggle class-colored UI borders on/off |

**Spec names are case-insensitive.** You can type them in any capitalisation.

### Examples

```
/qs fire
/qs Frost
/qs Beast Mastery
/qs retribution
```

If the name does not match any of your specs, QuickSpec will print an error in chat.

---

## Keybind

QuickSpec registers a keybind called **"Open/Close QuickSpec"** under the **QuickSpec** header in the standard Key Bindings interface (`Esc → Key Bindings → QuickSpec`).

Binding a key there is equivalent to running `/qs` with no arguments — it toggles the frame open and closed.

---

## Macros

Because QuickSpec supports WoW macro conditionals inside the slash command, you can pack multiple spec switches into a single macro button using modifier keys.

### Syntax

Each conditional line takes the form:

```
/qs [conditional] spec name
```

Supported conditionals:

| Conditional | Triggers when… |
|---|---|
| `[mod:ctrl]` | Ctrl is held |
| `[mod:alt]` | Alt is held |
| `[mod:shift]` | Shift is held |
| `[nomod]` | No modifier key is held |

Lines are evaluated **top to bottom**. The first matching conditional wins. A line with no conditional at all acts as the **default fallback** if nothing above matched.

### Example — Two specs on one button

```
/qs [mod:shift] protection
/qs retribution
```

- Press the button normally → switch to Retribution  
- Hold **Shift** and press → switch to Protection

### Example — Three specs across three modifiers

```
/qs [mod:ctrl] balance
/qs [mod:shift] restoration
/qs feral
```

- No modifier → Feral  
- Shift → Restoration  
- Ctrl → Balance

### Example — Explicit nomod fallback

```
/qs [mod:alt] shadow
/qs [nomod] holy
```

- Alt held → Shadow  
- No modifier → Holy  
- (Other modifiers do nothing)

---

## Class Color Borders

By default the frame uses a deep amber gold accent for all chrome (borders, title, spec name, close button, divider).

Running `/qs classcolor` switches the borders and divider to your character's class color. Running it again reverts to gold. The preference is saved **per character**.

---

## Chat Feedback

QuickSpec prints status messages to your chat in gold text with a `QuickSpec:` prefix:

- Confirming a spec switch: `QuickSpec: Switching spec to Frost.`
- Already on the selected spec: `QuickSpec: Spec is already set to Frost.`
- Invalid spec name entered: `QuickSpec: Shadow is not a valid spec choice`
- Class color toggle: `QuickSpec: Class color borders: ON` / `OFF`

A large fade-out message also appears on screen briefly whenever a spec switch is initiated, matching the style of raid warning text.
