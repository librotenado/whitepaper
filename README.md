# librotenado Whitepaper

The whitepaper of **librotenado** – an open protocol for accounting data in Europe. A [falkOSS](https://falkoss.org)
project.

| File | Content | Status |
|---|---|---|
| [whitepaper.md](whitepaper.md) | the whitepaper – the only source | v0.1, first full draft; OPEN points remain |
| [whitepaper.pdf](whitepaper.pdf) | set with Typst from the Markdown | generated |

The whitepaper explains why and how; the normative specification lives in
[librotenado](https://github.com/librotenado/librotenado). Its first implementation is
[spezado](https://github.com/spezado/spezado).

## Building

`whitepaper.md` is the only source. `whitepaper.typ` (Typst) and `whitepaper.pdf` are generated from it – rebuild
after every change and commit all three:

```sh
./build.sh               # all documents (needs pandoc 3.7.0.2 and typst 0.15.1, otherwise uses nix)
./build.sh whitepaper.md # only this one
```

Title, version and status come from the YAML front matter; with `status: Draft` a light DRAFT is drawn behind every
page. The footer shows status, the date of the document's last commit and the short hash of its content
(`git log --find-object=<hash>` finds the commit a PDF was made from). Author notes (`> [!NOTE]`, the section "Open
points") stay in the Markdown only. CI (`.github/workflows/pdf.yml`) rebuilds on every push, checks that the
committed `.typ` is current and, for a tag `v*`, attaches the PDF to a GitHub release.

The template (`template/librotenado.typ`) follows the librotenado brand kit (`librotenado/brand`); copy `assets/` and `fonts/` again when the kit changes.

## Licence

The text: [CC BY 4.0](LICENSES/CC-BY-4.0.txt) – like the specification, so that text can move freely between
whitepaper, specification and standards documents. The build tooling (`build.sh`, `template/`):
[AGPL-3.0-or-later](LICENSES/AGPL-3.0-or-later.txt). Fonts: Atkinson Hyperlegible Next and Mono, [SIL Open Font License 1.1](LICENSES/OFL-1.1.txt).

## Contributing

Issues and pull requests are welcome, with a [DCO](https://developercertificate.org) sign-off (`git commit -s`).
Every claim about an existing standard needs a source; unverified statements are marked **OPEN**.

© 2026 falkOSS – Falcon Lake Open Source Software gUG (haftungsbeschränkt) i. G. and the librotenado contributors
