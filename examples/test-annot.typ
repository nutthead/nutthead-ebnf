#import "../ebnf.typ": *
#set page(width: auto, height: auto, margin: .5cm, fill: white)

#ebnf(
  mono-font: "JetBrains Mono",
  body-font: "DejaVu Serif",
  Prod(
    N[Test],
    {
      Or[#T[foo] #N[Bar]][this is annotation]
    },
  ),
)
