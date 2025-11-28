#import "../ebnf.typ": *

// Test with default spacing
#ebnf(
  Prod(
    $A$,
    annot: [First production],
    Or[$a$][terminal a],
    Or[$b$][terminal b],
  ),
  Prod(
    $B$,
    annot: [Second production],
    Or[$c$][terminal c],
  ),
)

#v(2em)

// Test with custom spacing - tighter layout
#ebnf(
  production-spacing: 0.2em,
  column-gap: 0.3em,
  row-gap: 0.2em,
  Prod(
    $A$,
    annot: [First production (tight)],
    Or[$a$][terminal a],
    Or[$b$][terminal b],
  ),
  Prod(
    $B$,
    annot: [Second production (tight)],
    Or[$c$][terminal c],
  ),
)

#v(2em)

// Test with custom spacing - looser layout
#ebnf(
  production-spacing: 1em,
  column-gap: 1em,
  row-gap: 0.8em,
  Prod(
    $A$,
    annot: [First production (loose)],
    Or[$a$][terminal a],
    Or[$b$][terminal b],
  ),
  Prod(
    $B$,
    annot: [Second production (loose)],
    Or[$c$][terminal c],
  ),
)
