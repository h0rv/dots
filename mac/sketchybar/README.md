# SketchyBar — notch-extending bar

A minimal [SketchyBar](https://felixkratz.github.io/SketchyBar/) config that turns
the MacBook Pro notch into a usable status bar: [AeroSpace](https://nikitabobko.github.io/AeroSpace/)
workspaces to the **left** of the notch, the date to the **right**, both as black
boxes that meet at screen center so they read as one continuous "extended notch."

On external displays (no physical notch) the same two boxes meet at center,
mimicking the look.

```
        ┌──────────────┐   ┌──────────────────┐
········│ 1 2 3 4 5    │███│  Tue Jun 2 13:44 │········
        └──────────────┘ ▲ └──────────────────┘
          workspaces   notch        date
```

## The four tricks

Everything here is pure config — no background images or asset files.

1. **`notch_width=0`** — `q` (left of notch) and `e` (right of notch) items
   normally leave a reserved gap the width of the notch. Setting it to `0` lets
   the two boxes meet exactly at screen center, behind the notch. The notch is
   physically black, so the seam disappears under it.

2. **Clip the top corners off-screen** — SketchyBar's `corner_radius` rounds all
   four corners and there's no per-corner control. So each box's background is
   drawn `2*R` taller than the bar (`background.height`) and shifted up by `R`
   (`background.y_offset`). The rounded top corners land above the bar and get
   clipped, leaving a square top edge and only the bottom corners rounded.

3. **A spacer holds text clear of the notch** — a zero-label `*.fill` item is
   added *first* on each side (so it sits nearest the notch) with `width=FILL`
   (≈ half the notch width). The black background covers it and reaches center,
   while the actual text is pushed out past the physical notch.

4. **Reversed `q` order** — `q` items stack from the notch *outward*
   (right-to-left), so the workspace list is written `5 4 3 2 1` once to render
   `1 2 3 4 5` left-to-right.

## Why none of these can be "cleaned up"

Audited against the official [bar](https://felixkratz.github.io/SketchyBar/config/bar)
and [item](https://felixkratz.github.io/SketchyBar/config/items) property tables —
don't remove these thinking there's a tidier API; there isn't.

- **Trick 1 is not a hack** — `notch_width` exists precisely to control the
  reserved notch gap. `0` is correct, intended usage. No alternative knob.

- **Trick 2 is the only real hack.** `corner_radius` is a single value with *no
  per-corner option*, so "round only the bottom" has no native API. The clip
  relies on background clipping mechanics the docs *don't* formally specify, so a
  SketchyBar update could in theory break it. The one supported alternative is a
  pre-rendered `background.image` PNG (how `crissNb/Dynamic-Island` does it) —
  heavier and fixed-size, deliberately not used here.

- **Trick 3 exists only because of Trick 1.** `notch_width` natively holds text
  clear of the notch — but setting it to `0` (needed so the boxes meet at center)
  gives that up, so the spacer restores it. No single property does both
  meet-at-center *and* clear-the-notch.

- **Trick 4 is the shortest of several options.** There's no `order=` property;
  `--reorder`/`--move`/`--clone` exist but are strictly more verbose than writing
  the list reversed once.

## Tuning

All knobs are at the top of [`sketchybarrc`](./sketchybarrc):

| Var     | Meaning                                                        |
| ------- | ------------------------------------------------------------- |
| `BAR_H` | Visible bar height — match the notch height so boxes sit flush |
| `R`     | Corner radius of the visible bottom corners                   |
| `FILL`  | Spacer width on the notch side (≈ half the notch width)       |

If text hides behind the notch, raise `FILL`. If a box dips below the notch,
lower `BAR_H`.

## AeroSpace integration

`aerospace.toml` triggers a SketchyBar event on workspace change:

```toml
exec-on-workspace-change = [
  '/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE',
]
```

Each `space.N` item subscribes to that event and runs
[`plugins/aerospace_workspace.sh`](./plugins/aerospace_workspace.sh), which
highlights the focused workspace.
