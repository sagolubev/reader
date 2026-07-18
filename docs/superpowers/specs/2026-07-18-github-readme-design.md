# GitHub README Presentation Design

## Goal

Present Reader as a polished native iOS application with a concise,
developer-friendly GitHub landing page and an authentic product screenshot.

## Direction

Use a product-minimal English README. Keep the page visually restrained and
lead with the running application rather than decorative graphics.

## Screenshot

- Capture the actual Reader app running in an iPhone Simulator.
- Use the warm light theme.
- Show the primary reader screen in a stable ready or paused state.
- Keep representative RSVP text, progress, and controls visible.
- Do not add a device mockup, synthetic UI, or marketing overlay.
- Store the image at `docs/assets/reader-screenshot.png`.

## README Structure

1. Project title and one-sentence product description.
2. Compact platform and technology badges.
3. One centered application screenshot.
4. Focused feature summary.
5. Import safety and supported-format notes.
6. Architecture overview.
7. Build and test commands.
8. Links to detailed project documentation.

## Repository Presentation

- Preserve the existing technical accuracy improvements.
- Use relative repository paths so GitHub renders the screenshot and links.
- Avoid unsupported status badges, inflated claims, and decorative sections
  that require ongoing external services.
- Keep release signing guidance accurate and account-neutral.

## Verification

- Build and run the app in an iPhone Simulator.
- Visually inspect the captured screenshot.
- Run the documentation source test.
- Run strict OpenSpec validation.
- Run `git diff --check`.
- Confirm the screenshot renders through its README-relative path.
