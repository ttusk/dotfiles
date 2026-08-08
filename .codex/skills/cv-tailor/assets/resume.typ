// Codex cv-tailor template. Replace every REPLACE_* value before compiling.
#set page(paper: "a4", margin: (x: 1.45cm, y: 1.2cm))
#set text(font: "New Computer Modern", size: 9.3pt, fill: rgb("#171717"))
#set par(justify: false, leading: 0.56em)
#set list(indent: 1.05em, body-indent: 0.45em, spacing: 0.2em)
#show heading.where(level: 2): it => block(above: 0.65em, below: 0.35em)[
  #set text(size: 10.5pt, weight: "bold")
  #upper(it.body)
  #line(length: 100%, stroke: 0.6pt + rgb("#444444"))
]
#show link: set text(fill: rgb("#171717"))

#let cv-header(name, location, email, phone, github-url, linkedin-url) = block(below: 0.7em)[
  #text(size: 19pt, weight: "bold")[#name]
  #linebreak()
  #location · #phone · #link("mailto:" + email)[#email]
  #linebreak()
  #link(github-url)[#github-url] · #link(linkedin-url)[#linkedin-url]
]

#let work(title, company, location, dates) = block(above: 0.35em, below: 0.15em)[
  #text(weight: "bold")[#title]
  #linebreak()
  #text(size: 8.7pt, fill: rgb("#444444"))[#company · #location · #dates]
]

#let education(degree, institution, location, dates) = block(above: 0.25em)[
  #text(weight: "bold")[#degree]
  #linebreak()
  #text(size: 8.7pt, fill: rgb("#444444"))[#institution · #location · #dates]
]

#cv-header(
  "REPLACE_NAME",
  "REPLACE_LOCATION",
  "REPLACE_EMAIL",
  "REPLACE_PHONE",
  "https://github.com/REPLACE_GITHUB",
  "https://www.linkedin.com/in/REPLACE_LINKEDIN",
)

== Resumo Profissional

REPLACE_SUMMARY

== Experiência Profissional

#work(
  "REPLACE_CANONICAL_TITLE",
  "REPLACE_COMPANY",
  "REPLACE_WORK_LOCATION",
  "REPLACE_DATES",
)

- REPLACE_GROUNDED_BULLET

== Habilidades Técnicas

- *REPLACE_CATEGORY*: REPLACE_RELEVANT_SKILLS.

== Educação

#education(
  "REPLACE_DEGREE",
  "REPLACE_INSTITUTION",
  "REPLACE_EDUCATION_LOCATION",
  "REPLACE_EDUCATION_DATES",
)

== Idiomas

- REPLACE_LANGUAGE_AND_LEVEL.
