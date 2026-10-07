# Restart: openamigamedialibrary

_Written 6 October 2026 at about 23:55 UTC, while all work is paused on @SacredTrees's word (23:28 UTC). Read this first when work resumes; the newest capsule and the live PR list win if they disagree._

## What this repo is

libwebp and libvpx for AmigaOS 3.x (m68k) as static link libraries. openamigaimage's webp and webm datatypes are built on them.

## Where it stands

Working: both libraries build and decode on the bench exactly as on a PC. Only CONTRIBUTORS.md landed today.

## Merged lately

- #1 (b5bb568, 2026-10-06): Credit who made openamigamedialibrary: CONTRIBUTORS.md

## Open pull requests

- None.

## Next step

1. Animated WebP (only the first frame shows today) is a datatype change in openamigaimage.

## Waiting on @SacredTrees

- Nothing.

## Who owns it

Datatypes thread.

## Capsules

Restart capsules for this repo's workstreams, in amigachrome's `capjumps/` shelf:

- [`20261006_AmigaChrome_Datatypes_OpenPlay_Restart_Capsule.zip`](https://github.com/DalsinAI/amigachrome/tree/main/capjumps)

Team rules that still hold: commits as SacredTrees with no co-author lines; third-party code only on "yes with review" (licence checked, commit and sha256 pinned, fetched at build, never committed); deploys with deploy_dev.py only, on a typed line.
