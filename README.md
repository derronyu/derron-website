<p align="center">
  <img src="source/favicon.svg" width="110" alt="Derron Yu geometric D and inverted-triangle brand mark">
</p>

<h1 align="center">DERRON YU</h1>

<p align="center">
  A portfolio for work across investment strategy, markets, policy, and sustainable growth.
</p>

<p align="center">
  <a href="https://deronyu.com/">View the website</a>
  &nbsp;·&nbsp;
  <a href="docs/BRAND_GUIDELINES.md">Brand guidelines</a>
</p>

---

## About

This repository contains Derron Yu's personal portfolio. The site presents professional experience, selected competition work, and academic research through an editorial system built around clear evidence and direct language.

The visual identity pairs a warm paper canvas with strong rules, oversized serif typography, a restrained color system, and the custom D-and-triangle brand mark.

## Brand system

The identity is grounded in **Analytical Optimism**: rigorous thinking presented with clarity, warmth, and momentum.

| Token | Hex | Use |
| --- | --- | --- |
| Paper | `#F2EAD3` | Primary canvas |
| Soft Paper | `#FBF7EC` | Reading surfaces |
| Ink | `#17231C` | Text, borders, and dark sections |
| Moss | `#315843` | Finance and sustainability |
| Signal Coral | `#F06F4F` | Actions and key emphasis |
| Citron | `#DDEB72` | Highlights and selected states |
| Aubergine | `#75485D` | Research and editorial work |
| Lake | `#5573A9` | Strategy and technology |

The full identity rules—including voice, typography, layout, photography, accessibility, and mark usage—are documented in the [brand guidelines](docs/BRAND_GUIDELINES.md).

## Site structure

The home page is a single scrolling page (`source/index.html.md.erb`) built from `data/home.yml`, with each section rendered by a partial in `source/partials/`:

- **Hero** — positioning and portrait
- **Expertise** (`#expertise`) — analytical, research, and communication capabilities, plus experience history
- **Work** (`#work`) — portfolio management, infrastructure strategy, and venture-development cases, listed as compact linked rows
- **Research** (`#research`) — five academic papers, listed as compact linked rows
- **Background** — closing bio and contact links

Section order (and which one gets bottom padding) is controlled by the `sections:` list at the top of `data/home.yml`.

Each Work and Research row links out to its own detail page under `source/work/<slug>/` or `source/papers/<slug>/`, authored in Markdown with ERB helpers for base-path-safe asset links, and wrapped in the shared `.prose-page` style.

## Technology

- [Middleman](https://middlemanapp.com/) static-site generator
- Ruby 3.4
- Semantic HTML, custom CSS, and vanilla JavaScript
- Local Inter and Cardo webfonts
- GitHub Actions and GitHub Pages

## Local development

Install Homebrew (Mac):

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install Ruby:

```
brew install rbenv
rbenv init
# restart your terminal
rbenv install 3.4
```

Install dependencies:

```sh
bundle install
```

Start the development server at `http://localhost:4174`:

```sh
bundle exec middleman server
```

Run the test suite:

```sh
bundle exec ruby -Itest test/site_test.rb
```

Create a production build using the GitHub Pages base path:

```sh
BASE_PATH=/derron-website bundle exec middleman build --clean
```

Generated files are written to `build/`.

## Project layout

```text
data/
└── home.yml               Home page content (hero, expertise, work, research, background)

source/
├── layouts/               Shared page shell
├── partials/              One partial per home-page section (_work.html.erb, _research.html.erb, …)
├── stylesheets/           Brand tokens and responsive visual system
├── javascripts/           Accessible mobile-navigation behavior
├── images/                Portrait and project artifacts
├── index.html.md.erb      Homepage, assembled from data/home.yml + partials
├── work/<slug>/           One detail page per case competition
└── papers/                Downloadable PDFs + one detail page per paper (papers/<slug>/)
```

## Deployment

Pushes to `main` run the Pages workflow in [`.github/workflows/pages.yml`](.github/workflows/pages.yml). The workflow installs Ruby dependencies, runs the test suite, builds with the configured Pages base path, and deploys the generated artifact.

## Contact

- [LinkedIn](https://www.linkedin.com/in/derron-yu/)
- [Email](mailto:derron-nis@hotmail.com)
