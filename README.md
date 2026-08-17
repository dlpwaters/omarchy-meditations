# Omarchy Meditations

An offline Omarchy bar plugin that opens a random passage from Marcus Aurelius's
*Meditations*. The bundled collection contains all 415 sections from the local
Meditations reader in Familiar, Abbreviated, and Original editions.

The shuffle bag shows every section once before reshuffling. It makes no network
requests, uses no images, and runs no background service.

## Controls

- Click the book icon: open a passage; click again for another
- **Another page**, Space, Enter, N, or R: show another passage
- Use the three always-visible **Familiar**, **Abbreviated**, and **Original** buttons,
  or press E to cycle editions without changing the passage
- **Copy** or C: copy the passage and citation
- Escape: close

## Install

```bash
omarchy plugin add https://github.com/dlpwaters/omarchy-meditations.git --enable --yes
```

## Remove

```bash
omarchy plugin remove dlpwaters.meditations
```

Runtime requirements (`jq`, `shuf`, `flock`, and `wl-copy`) are included in a
standard Omarchy installation.

## Sources and license

Plugin code is MIT licensed. The bundled text collection is covered separately;
see `DATA-LICENSE` for attribution and terms.
