// Codex cv-tailor template based on @preview/basic-resume:0.2.9.
#import "@preview/basic-resume:0.2.9": *

#let name = "REPLACE_NAME"
#let location = "REPLACE_LOCATION"
#let email = "REPLACE_EMAIL"
#let github = "github.com/REPLACE_GITHUB"
#let linkedin = "linkedin.com/in/REPLACE_LINKEDIN"
#let phone = "REPLACE_PHONE"

#let show-summary = REPLACE_SHOW_SUMMARY
#let show-skills = REPLACE_SHOW_SKILLS
#let show-education = REPLACE_SHOW_EDUCATION
#let show-languages = REPLACE_SHOW_LANGUAGES

#show: resume.with(
  author: name,
  location: location,
  email: email,
  github: github,
  linkedin: linkedin,
  phone: phone,
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "a4",
  author-position: left,
  personal-info-position: left,
  font-size: 10pt,
  lang: "pt",
)

#if show-summary [
== Resumo Profissional

REPLACE_SUMMARY
]

== Experiência Profissional

#work(
  title: "REPLACE_CANONICAL_TITLE",
  company: "REPLACE_COMPANY",
  dates: "REPLACE_DATES",
  location: "REPLACE_WORK_LOCATION",
)
- REPLACE_GROUNDED_BULLET

#if show-skills [
== Habilidades Técnicas

- *REPLACE_CATEGORY*: REPLACE_RELEVANT_SKILLS.
]

#if show-education [
== Educação

#edu(
  institution: "REPLACE_INSTITUTION",
  location: "REPLACE_EDUCATION_LOCATION",
  dates: "REPLACE_EDUCATION_DATES",
  degree: "REPLACE_DEGREE",
)
]

#if show-languages [
== Idiomas

- REPLACE_LANGUAGE_AND_LEVEL.
]
