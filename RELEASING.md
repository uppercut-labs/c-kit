# Releasing

Every package is versioned and released on its own. A release only goes out after the release gate passes on the source tree, the git history and the exact tarball that the release carries.

C libraries are not uploaded to a package index. A release is a tag `<name>@<version>` on the commit the gate passed, with the source tarball optionally attached to a GitHub release. Projects take the library at that tag.

Everything below runs in PowerShell on Windows or Bash on macOS and Linux, except the gate, which is Python 3 and runs the same everywhere. The commands are written once because `git`, `python` and `gh` take the same arguments in both shells; where a line differs, both are shown.

1. Bump the version in `packages/<name>/include/<header>.h`, in the package README (its install snippet's `GIT_TAG`, its tested-systems table) and in `examples/consumer/CMakeLists.txt`. Commit.
2. Run the full check, which builds each package, runs its tests and builds the example consumer:

   ```powershell
   .\tools\check.ps1                 # Windows, PowerShell
   ```
   ```bash
   ./tools/check.sh                  # macOS, Linux, Bash
   ```

   Run it on all three systems for a release (the README's tested-systems table says which versions were run).
3. Pack the package's source into a tarball from the committed tree:

   ```bash
   mkdir -p dist
   git -c core.autocrlf=false archive --format=tar.gz --prefix=<name>-<version>/ -o dist/<name>-<version>.tar.gz HEAD:packages/<name>
   ```

   The `-c core.autocrlf=false` matters on Windows: without it `git archive` can write CRLF line endings into the shell scripts, which then fail on macOS and Linux. Each package carries its own `.gitattributes` for the same reason, because `git archive` of a subfolder does not read the repository's. Extract the tarball into a new empty folder and run its own `build-and-test` script there. A package that only builds inside this repository is not releasable.
4. Run the gate on the tarball:

   ```bash
   python tools/release_gate.py --artifact dist/<name>-<version>.tar.gz
   ```

   - The gate needs `RELEASE_GATE_DENYLIST` (a private file of strings that must never ship, kept outside this repo) and `gitleaks` on `PATH` or in `GITLEAKS`.
   - The gate also needs `RELEASE_GATE_ALLOWED_EMAILS`, a comma-separated list of the commit author and committer emails it accepts. Any other address in the history fails the gate. For this repository: `packages@uppercut-labs.com` (the commit identity), the maintainer's GitHub `users.noreply.github.com` address, and `noreply@github.com` (the committer GitHub records on merged pull requests).
   - Exit code 0 is the only passing result.
5. Tag the commit `<name>@<version>` and push the tag. Optionally attach the tarball the gate scanned:

   ```bash
   git tag <name>@<version>
   git push origin <name>@<version>
   gh release create <name>@<version> dist/<name>-<version>.tar.gz --title "<name> <version>" --notes "<what changed>"
   ```

Releases are made from a maintainer machine. This repository does not use hosted CI.
