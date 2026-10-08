# Contributors

## Creator and maintainer

- **SacredTrees** ([@SacredTrees](https://github.com/SacredTrees)): created openamigamedialibrary, the Amiga build of libwebp and libvpx, designs it and maintains it.

## The AmigaChrome team

We are the AI agents who build AmigaChrome alongside SacredTrees:

- **Agnus**, our coordinator, who keeps every thread moving.
- **Thufir**, **Kynes** and **Galen**, the earlier agents who started the work on SacredTrees's x86 cores.
- **The Claude Code threads**, each one taking a piece of the work from design to release.

## Copyright holder

Our build script, patches and tests are Copyright (c) 2026 Dalsin Limited,
released under the MIT licence (`LICENSE`). A patch to libwebp or libvpx stays
under that library's licence.

## Third-party work in this repository

All credit for the libraries goes to their authors. Their notices are kept
here; the sources themselves are not.

| Component | Where | Authors | Licence |
| --- | --- | --- | --- |
| libwebp's notices | `upstream/libwebp/` (`AUTHORS`, `COPYING`, `PATENTS`) | Google Inc. and the contributors in `AUTHORS` | BSD 3-clause, with Google's patent grant |
| libvpx's notices | `upstream/libvpx/` (`AUTHORS`, `LICENSE`, `PATENTS`) | The WebM Project authors, listed in `AUTHORS` | BSD 3-clause, with Google's patent grant |
| Our patch to libwebp 1.6.0 | `patches/libwebp-1.6.0-no-float.patch` | Dalsin Limited, to Google's files | libwebp's licence |
| Our patch to libvpx 1.17.0 | `patches/libvpx-1.17.0-amiga-align.patch` | Dalsin Limited, to the WebM Project's files | libvpx's licence |

## Fetched at build time, not committed

`SOURCES` pins each tarball by its SHA-256 sum:

- **libwebp 1.6.0** (`libwebp-1.6.0.tar.gz`, from downloads.webmproject.org), by Google Inc. and the libwebp contributors; BSD 3-clause with a patent grant.
- **libvpx 1.17.0** (`v1.17.0.tar.gz`, from github.com/webmproject/libvpx), by the WebM Project authors; BSD 3-clause with a patent grant.

Amiga, AmigaOS and other product names are trademarks of their respective
owners.
