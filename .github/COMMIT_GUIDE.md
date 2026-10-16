# Commit Guide

Use one emoji, a commit type, and a short action in each title:

`<emoji> <type>(<optional scope>): <imperative summary>`

Keep the summary specific, start it with a verb, and omit the final period. Use a scope when it helps identify the affected area, such as `networking`, `design-system`, or `search`.

| Emoji | Type | Use for |
| --- | --- | --- |
| 🍕 | `feat` | New user-facing behavior or functionality |
| 🐛 | `fix` | Bug fixes |
| 📝 | `docs` | Documentation only |
| 🎨 | `style` | Formatting or visual styling without behavior changes |
| 🧑‍💻 | `refactor` | Code structure changes without behavior changes |
| 🔥 | `perf` | Performance improvements |
| ✅ | `test` | Tests only |
| 🤖 | `build` | Dependencies, package manifests, and build configuration |
| 🔁 | `ci` | Continuous integration workflows |
| 📦 | `chore` | Maintenance and release tasks |
| ⏩ | `revert` | Reverts of earlier commits |

Examples:

- `🍕 feat(search): add property filters`
- `🐛 fix(networking): handle unauthorized responses`
- `🧑‍💻 refactor(design-system): move shared UI into the package`
- `📝 docs: add a pull request template`

For changes that need explanation, leave a blank line after the title and add a body describing the reason and any important behavior. Reference related issues in the body with `Refs #123` or `Closes #123` when applicable.

Keep each commit focused on one change. Split unrelated changes into separate commits.
