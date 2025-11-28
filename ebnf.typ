/// Plain color scheme
#let colors-plain = (
  lhs: none,
  nonterminal: none,
  terminal: none,
  operator: none,
  delim: none,
  annot: none,
)

/// Colorful color scheme (default)
#let colors-colorful = (
  lhs: rgb("#1a5fb4"),
  nonterminal: rgb("#613583"),
  terminal: rgb("#26a269"),
  operator: rgb("#a51d2d"),
  delim: rgb("#5e5c64"),
  annot: rgb("#986a44"),
)

// Layout constants
#let _error-text-size = 0.9em
#let _production-spacing = 0.5em
/// Default horizontal spacing between grid columns (LHS, delimiter, RHS, annotation)
#let _column-gap = 0.75em
/// Default vertical spacing between grid rows (individual production alternatives)
#let _row-gap = 0.5em

#let _color-keys = (
  "lhs",
  "nonterminal",
  "terminal",
  "operator",
  "delim",
  "annot",
)
#let _ebnf-state = state("ebnf", (
  mono-font: none,
  body-font: none,
  colors: colors-colorful,
))
#let _error(msg) = text(
  fill: red,
  weight: "bold",
  size: _error-text-size,
)[⚠ EBNF Error: #msg]
#let _styled(color, content) = if color != none {
  text(fill: color, content)
} else { content }

#let _wrap-op(left, right, content, suffix: none) = context {
  let c = _ebnf-state.get().colors.at("operator", default: none)
  if suffix != none {
    [#_styled(c, left)#content#_styled(c, right)#_styled(c, suffix)]
  } else { [#_styled(c, left)#content#_styled(c, right)] }
}

#let _validate-colors(colors) = {
  if type(colors) != dictionary {
    return (false, "colors must be a dictionary")
  }
  let missing = _color-keys.filter(k => k not in colors)
  if missing.len() > 0 {
    return (false, "colors missing: " + missing.join(", "))
  }
  (true, none)
}

#let _validate-prod(prod, n) = {
  if type(prod) != array or prod.len() != 4 {
    return (false, "production #" + str(n) + " invalid")
  }
  let alts = prod.at(2)
  if type(alts) != array or alts.len() == 0 {
    return (false, "production #" + str(n) + " has no alternatives")
  }
  for alt in alts {
    if type(alt) != array or alt.len() != 2 {
      return (false, "production #" + str(n) + " has invalid Or()")
    }
  }
  (true, none)
}

/// Optional: `[content]`
#let Opt(content) = _wrap-op("[", "]", content)
/// Repetition (zero or more): `{content}`
#let Rep(content) = _wrap-op("{", "}", content)
/// Repetition (one or more): `{content}+`
#let Rep1(content) = _wrap-op("{", "}", content, suffix: "+")
/// Grouping: `(content)`
#let Grp(content) = _wrap-op("(", ")", content)
/// Terminal symbol
#let T(content) = context _styled(
  _ebnf-state.get().colors.at("terminal", default: none),
  content,
)
/// Non-terminal reference (italic)
#let N(content) = context _styled(
  _ebnf-state.get().colors.at("nonterminal", default: none),
  emph(content),
)
/// Non-terminal in angle brackets: `⟨content⟩`
#let NT(content) = context _styled(
  _ebnf-state.get().colors.at("nonterminal", default: none),
  [⟨#emph(content)⟩],
)

/// Alternative in a production
#let Or(var, annot) = (var, annot)

/// Production rule
#let Prod(lhs, annot: none, delim: auto, ..rhs) = {
  (
    lhs,
    delim,
    rhs.pos().flatten().chunks(2).map(c => (c.at(0), c.at(1, default: none))),
    annot,
  )
}

/// Renders an EBNF grammar as a formatted grid.
///
/// The grammar is displayed as a 4-column table with columns for:
/// left-hand side (LHS), delimiter, right-hand side (RHS), and annotations.
/// Multiple alternatives for a production are shown on separate rows with `|` delimiters.
///
/// - mono-font (string, none): Font for grammar symbols. If `none`, uses document default.
/// - body-font (string, none): Font for annotation text. If `none`, uses document default.
/// - colors (dictionary): Color scheme for syntax highlighting. Use `colors-plain` for no colors
///   or `colors-colorful` (default). Keys: `lhs`, `nonterminal`, `terminal`, `operator`, `delim`, `annot`.
/// - production-spacing (length): Extra vertical space between productions. Default: `0.5em`.
/// - column-gap (length): Horizontal spacing between grid columns. Default: `0.75em`.
/// - row-gap (length): Vertical spacing between grid rows. Default: `0.5em`.
/// - body (Prod): One or more production rules created with `Prod()`.
/// -> content
#let ebnf(
  mono-font: none,
  body-font: none,
  colors: colors-colorful,
  production-spacing: _production-spacing,
  column-gap: _column-gap,
  row-gap: _row-gap,
  ..body,
) = {
  for (name, val) in (("mono-font", mono-font), ("body-font", body-font)) {
    if val != none and type(val) != str {
      return _error(name + " must be string or none")
    }
  }
  let (ok, err) = _validate-colors(colors)
  if not ok { return _error(err) }
  let prods = body.pos()
  if prods.len() == 0 { return _error("no productions provided") }
  for (i, p) in prods.enumerate() {
    let (ok, err) = _validate-prod(p, i + 1)
    if not ok { return _error(err) }
  }

  _ebnf-state.update((
    mono-font: mono-font,
    body-font: body-font,
    colors: colors,
  ))
  let colorize(role, content) = _styled(colors.at(role, default: none), if role
    == "annot"
    and body-font != none { text(font: body-font, content) } else { content })

  let cells = prods
    .enumerate()
    .map(((idx, prod)) => {
      let (lhs, delim, alts, annot) = prod
      let delim = if delim == auto { "::=" } else { delim }
      let first-annot = alts.at(0).at(1)
      let multi-annot = (
        alts.len() > 1 and alts.slice(1).any(a => a.at(1) != none)
      )
      let annot-row(c) = (
        grid.cell(colspan: 4, if idx > 0 {
          [#v(production-spacing)#colorize("annot", c)]
        } else { colorize("annot", c) }),
      )
      let rows = ()
      if annot != none { rows.push(annot-row(annot)) }
      if first-annot != none and not multi-annot {
        rows.push(annot-row(first-annot))
      }
      for (i, (rhs, rhs-annot)) in alts.enumerate() {
        let acol = if rhs-annot != none and multi-annot {
          colorize("annot", rhs-annot)
        } else { [] }
        rows.push(if i == 0 {
          (colorize("lhs", lhs), colorize("delim", delim), rhs, acol)
        } else { ([], colorize("delim", "|"), rhs, acol) })
      }
      rows
    })
    .flatten()
    .flatten()

  let result = grid(columns: 4, align: (
      left,
      center,
      left,
      left,
    ), column-gutter: column-gap, row-gutter: row-gap, ..cells)
  if mono-font != none {
    set text(font: mono-font)
    result
  } else { result }
}
