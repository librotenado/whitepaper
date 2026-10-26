// SPDX-License-Identifier: AGPL-3.0-or-later
// librotenado document template: A4, Atkinson Hyperlegible Next and Mono (fonts/, OFL). Used by pandoc.typ for whitepaper.md; usable on its own:
//
//   #import "template/librotenado.typ": librotenado
//   #show: librotenado.with(title: "…", status: "Draft")
//
// Colours and the lockup (assets/) come from the librotenado brand kit (librotenado/brand) – ink text, grey rules,
// blue as the one accent. Copy assets/ and fonts/ again after brand/generate.py.

#let ink = rgb("#14213D")
#let accent = rgb("#1F5FAD")
#let steel = rgb("#4A5D70")
#let reed = rgb("#7D8590")
#let rule = rgb("#C9D1D9")
#let note = rgb("#EEF3FA")

#let org = "librotenado – a falkOSS project"
#let mono = "Atkinson Hyperlegible Mono"
#let sans = "Atkinson Hyperlegible Next"

/// title, subtitle, version, date: the title block on page 1 and the running header
/// status: "Draft" draws a light DRAFT behind every page; anything else prints only in the footer
/// stand, rev: shown in the footer (build.sh passes the last commit's date and revision)
#let librotenado(title: none, subtitle: none, version: none, date: none, status: "Draft", stand: none, rev: none, body) = {
  let draft = status == "Draft"
  set document(title: title, author: org)
  set text(font: sans, size: 10pt, lang: "en", fill: ink, hyphenate: true)
  set par(justify: true, leading: 0.68em, spacing: 1.15em)

  set page(
    paper: "a4",
    margin: (top: 30mm, bottom: 26mm, left: 24mm, right: 22mm),
    header: context {
      let first = counter(page).get().first() == 1
      grid(
        columns: (auto, 1fr),
        align: (left + horizon, right + horizon),
        image("assets/librotenado-lockup-name-on-light.svg", height: if first { 9mm } else { 5.5mm }),
        if not first { text(font: mono, size: 7.5pt, fill: reed, if title != none { title }) },
      )
      v(-2mm)
      line(length: 100%, stroke: 0.5pt + rule)
    },
    footer: context {
      line(length: 100%, stroke: 0.5pt + rule)
      v(-1mm)
      set text(font: mono, size: 7pt, fill: reed)
      grid(
        columns: (1fr, auto),
        column-gutter: 10pt,
        [#org · CC BY 4.0],
        [#status#if stand != none [ · #stand]#if rev != none [ · #rev] · #counter(page).display() / #counter(page).final().first()],
      )
    },
    background: if draft {
      rotate(-38deg, text(font: mono, size: 84pt, weight: "bold", fill: accent.transparentize(92%))[DRAFT])
    },
  )

  show heading: set text(font: sans, weight: "semibold", fill: ink, hyphenate: false)
  show heading: set par(justify: false)
  show heading.where(level: 1): it => {
    v(4mm)
    block(below: 6mm, sticky: true, {
      text(size: 15pt, it.body)
      v(-2mm)
      line(length: 22mm, stroke: 1.6pt + accent)
    })
  }
  show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, text(size: 11.5pt, it.body))
  show heading.where(level: 3): it => block(above: 1.4em, below: 0.7em, sticky: true, text(size: 10.5pt, it.body))

  show quote.where(block: true): it => block(
    width: 100%, fill: note, inset: (x: 10pt, y: 8pt), radius: 1pt,
    stroke: (left: 2pt + accent), text(size: 9pt, it.body),
  )

  set table(stroke: 0.5pt + rule, inset: (x: 6pt, y: 5pt))
  show table: set text(size: 8.8pt)
  show table: set par(justify: false)
  show table: set align(left)
  show figure.where(kind: table): set block(breakable: true)
  show table.cell.where(y: 0): set text(weight: "bold")

  show raw: set text(font: mono, size: 8pt)
  show raw.where(block: true): set par(justify: false)
  show link: set text(fill: steel)
  set list(marker: text(fill: accent, [–]))
  set enum(numbering: "1.")
  set footnote.entry(separator: line(length: 22mm, stroke: 0.5pt + rule))
  show footnote.entry: set text(size: 8pt)

  // title block
  if title != none {
    v(18mm)
    block(text(font: sans, weight: "semibold", size: 26pt, hyphenate: false, title))
    if subtitle != none { block(above: 4mm, text(size: 13pt, fill: steel, subtitle)) }
    v(2mm)
    line(length: 30mm, stroke: 2pt + accent)
    block(above: 5mm, text(font: mono, size: 9pt, fill: reed,
      [Whitepaper#if version != none [ #version]#if date != none [ · #date]]))
    v(14mm)
  }

  body
}
