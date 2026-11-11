# App icon

The modernist Broschy icon was created for this project with the built-in image generation tool. A warm ivory geometric lowercase **b** sits on a graphite tile, with an orange notch at the top edge. The simple silhouette remains recognizable at small sizes and relates directly to the app's place on the screen. The canvas outside the tile has transparent alpha.

Source: `Resources/AppIcon.png`

Bundle: `Resources/Broschy.icns`

Documentation copy: `docs/assets/app-icon.png`

The generated square source was normalized to 1024 × 1024 pixels using macOS `sips`. Rebuild the ICNS representations (16 through 1024 pixels, including Retina variants) and refresh the documentation copy with:

```sh
bash scripts/build-icon.sh
```

The script uses `sips` and `iconutil`, supplied by macOS. It preserves the source PNG and its alpha. The menu-bar icon remains a separate native monochrome template so macOS can adapt it to the menu-bar appearance.

## Generation prompt

```text
Use case: logo-brand. Asset type: final macOS application icon for Broschy, a native companion that lives around the MacBook notch. Create one extremely polished modernist app icon. Front-facing orthographic square composition, 1024 by 1024. A deep graphite charcoal rounded-square tile, inset 9% from the canvas on every side, with smooth native macOS continuous corners. Center a single strong warm ivory geometric lowercase b monogram, constructed from a thick perfectly straight vertical stem and one generous circular bowl/counter. The silhouette should be unmistakably a lowercase b and beautifully legible at 32 pixels. Integrate one small vivid warm orange horizontal notch-shaped inset into the top of the graphite tile, centered at its upper edge, a precise tiny echo of a laptop camera notch. The mark is crisp and flat with subtly tactile matte surfaces, like premium modernist industrial design. Quiet warm ivory #F4F1E9, graphite #222321, orange #F2763D only. Huge confident monogram, optical balance, immaculate negative space. The outer canvas must be genuinely transparent alpha, no checkerboard. Only one tile and one b glyph; no wordmark, no text, no other symbols. No glass, no glow, no chrome, no gradients behind the tile, no glossy bevels, no perspective, no mockup scene, no decorative particles, no shadow extending beyond the tile.
```
