# Security policy

## What to report

- A link in `roadmap/` that now leads to a malicious, hijacked or phishing page, for example after a
  domain changed owner.
- A topic that recommends an insecure practice, such as storing tokens in plain preferences or
  disabling transport security without a reason.
- A way to make the `roadmap` command or `RoadmapKit` crash, hang, use unbounded memory, or write
  terminal control sequences when reading a roadmap folder or a known-topics file.

## How to report

Do not open a public issue. Use GitHub's
[private vulnerability reporting](https://github.com/muhittincamdali/mobile-developer-roadmap/security/advisories/new)
for this repository, or the private address in the
[security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) of all
`muhittincamdali` repositories. Include the topic ID or the input that triggers the problem.

You can expect a first answer within seven days. A malicious link is removed as soon as it is
confirmed; other fixes ship in the next release.

## Supported versions

Only the latest release and `main` receive fixes.

## What the tool protects against

`RoadmapKit` and the `roadmap` command treat every roadmap folder and known-topics file as
untrusted input:

- Files are read up to 1 MiB, folders up to 64 entries, with at most 500 topics per file, 32 needs
  and 16 links per topic, a 120-character title and 100 reported problems per file.
- Symbolic links in the roadmap folder are skipped. A known-topics file must be a regular file of
  at most 64 KiB and 2,000 IDs, so a named pipe or a device cannot make the command wait forever.
- Loops of needs are found with an explicit stack and planned with Kahn's algorithm, so a long or
  circular chain cannot overflow the stack or loop.
- Everything printed passes through a filter that removes C0 and C1 control characters and
  bidirectional controls.

The tool does not log, collect or send any data, and the example app keeps the known topics on the
device only.
