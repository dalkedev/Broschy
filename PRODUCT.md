# Broschy

<!-- impeccable:product-schema 1 -->

## Platform

Native macOS (SwiftUI and AppKit), macOS 14+, built with the macOS 26 SDK.

## Users and purpose

Broschy lives at the top edge of a Mac display. It keeps a focus timer, local agent activity, Spotify controls, GitHub Actions and short notes close at hand without requiring a full application window. Developer workflows are supported by the existing integrations; no broader audience or usage claims are assumed.

## Capabilities and constraints

Five modules: Agents, Focus, Music, Signals and Later. Hover opens without stealing keyboard focus; clicking enables interaction. Preserve the measured camera gap, pinning, visibility preferences, Quiet Focus and reduced motion/transparency. Keep the existing data location and bundle identifier for compatibility. Data stays local except documented Spotify artwork and opt-in GitHub requests. Never start integrations during previews.

## Brand commitments

The name is Broschy. The owner requested a modernist redesign, a better logo and presentable portfolio assets, and delegated design decisions and fixes to discovered bugs. The application retains its English interface. This session uses a code-first native implementation to validate actual AppKit/SwiftUI behavior.

## Evidence

README.md and docs/DEVELOPMENT.md document behavior. Existing screenshots in docs/assets are historical examples with sample data. New captures must come from the running native views and label demonstration content.
