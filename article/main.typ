#import "@preview/glossy:0.8.0": *

#import "template/style.typ": page_template
#show: page_template

#import "template/header.typ": define_header
#import "template/abstract.typ": define_abstract

// Information for the document
#let title = [Ingresso de pessoas negras e indígenas, interioranas e jovens no ensino superior por meio do ProUni]

#let institutions = (
  [Departamento de Ciência da Computação #sym.dash.em Universidade Federal de Juiz de Fora (UFJF) #sym.dash.em Juiz de Fora, MG, Brasil],
)

#let authors = (
  (
    name: "Alexandre Rocha da Silva Moreira",
    email: "alexandre.rocha@estudante.ufjf.br",
    institution: 1,
  ),
  (
    name: "Celso Gabriel Malosto",
    email: "gabriel.malosto@estudante.ufjf.br",
    institution: 1,
  ),
  (
    name: "Lucas Paiva Santos",
    email: "lucas.paiva@estudante.ufjf.br",
    institution: 1,
  ),
)

// Set as none to render emails as default
// #let custom_emails = none
#let custom_emails = "{alexandre.moreira, gabriel.malosto, lucas.paiva}@estudante.ufjf.br"

#define_header(
  title: title,
  authors: authors,
  institutions: institutions,
  custom_emails: custom_emails,
)

#define_abstract(title: "Abstract")[

]


#define_abstract(title: "Resumo")[

]

// Glossary
#import "glossary.typ": glossary_entries
#show: init-glossary.with(glossary_entries)

#include "introduction.typ"
#include "methodology.typ"
#include "results.typ"
#include "conclusion.typ"

// References
#heading(numbering: none)[
  Referências
]
#bibliography(
  "bibliography.bib",
  style: "template/bibliography_style.csl",
  title: none,
)
