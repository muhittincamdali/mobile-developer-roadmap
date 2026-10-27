## What does this change?

## How was it checked?

- [ ] `swift run roadmap lint` reports 0 problems
- [ ] `swift test` passes
- [ ] `lychee roadmap/*.md` reports no broken links, if links changed
- [ ] New links are primary sources accepted by `SourcePolicy`
- [ ] No published topic ID was renamed
- [ ] `roadmap/README.md` and the README counts are updated if topics were added or removed
- [ ] Screenshots regenerated with `scripts/capture-screens.sh` if the app changed
- [ ] README translations updated, or noted here if `README.md` changed
