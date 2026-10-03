# Hugo - Best practices

Best practices and ideas for [Hugo](https://gohugo.io/) the open-source static site generator.

Themes based on this best practices: [Bootstrap-BP](https://github.com/spech66/bootstrap-bp-hugo-theme), [Materialize-BP](https://github.com/spech66/materialize-bp-hugo-theme),
[Bootstrap-BP hugo startpage](https://github.com/spech66/bootstrap-bp-hugo-startpage).

The examples are tested with Hugo 0.16x. Older Hugo versions might not support every function used here.

## Table of contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Hugo - Best practices](#hugo---best-practices)
  - [Table of contents](#table-of-contents)
  - [Content organization](#content-organization)
  - [Git repository and CI Tools](#git-repository-and-ci-tools)
  - [Content types and archetypes](#content-types-and-archetypes)
  - [Configure the site](#configure-the-site)
  - [Keep up with Hugo deprecations](#keep-up-with-hugo-deprecations)
    - [Template system since Hugo 0.146](#template-system-since-hugo-0146)
  - [CSS and JavaScript](#css-and-javascript)
    - [CSS](#css)
    - [Only ship what you use](#only-ship-what-you-use)
    - [Javascript](#javascript)
    - [Conditionals](#conditionals)
  - [Icons as inline SVG](#icons-as-inline-svg)
  - [Fonts](#fonts)
  - [Images](#images)
    - [Image sizes in HTML and CSS](#image-sizes-in-html-and-css)
  - [Caching and server configuration](#caching-and-server-configuration)
  - [Structured data (Schema.org)](#structured-data-schemaorg)
  - [External links in new window](#external-links-in-new-window)
  - [Themes: overrides and maintenance](#themes-overrides-and-maintenance)
  - [Readability and accessibility](#readability-and-accessibility)
  - [Dark mode](#dark-mode)
  - [Print styles](#print-styles)
  - [Check pages with a headless browser](#check-pages-with-a-headless-browser)
  - [Front-End Checklist](#front-end-checklist)
  - [Awesome Hugo list](#awesome-hugo-list)
  - [Tools](#tools)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Content organization

Keep all images next to the index Markdown file (page bundles). This allows to keep the images in the highest possible resolution and let Hugo resize them to the perfect size for the current theme (see [Images](#images) below).

```sh
├── mysite/
    ├── content/
    │   └── posts/
    │       ├── 0001-firstpost/
    │       │   ├── index.md
    │       │   └── me.jpg
    │       ├── 0002-secondpost/
    │       │   ├── index.md
    │           └── fun.jpg
    ├── about/
    │   └── index.md
```

Folder names become URLs when no `url` or `slug` is set. Keep them lowercase and without umlauts or spaces.

There is a Discussion on this in the [Forum](https://discourse.gohugo.io/t/discussion-content-organization-best-practice/6360/2).

## Git repository and CI Tools

Keep your site in a version control system like Git. This provides backup, history and multi user editing out of the box.

Use Continuous Integration/Deployment to publish your website after git push. Simple solutions like [webhook](https://github.com/adnanh/webhook/) or GitHub Actions/GitLab CI might do the job. For most cases Jenkins will be overkill.

You can sync files using `rsync` after a successful build. Have a look at the provided `deployment` scripts in this repository.

Do not commit generated files: add `public/`, `resources/_gen/` and `.hugo_build.lock` to `.gitignore`.

## Content types and archetypes

Define your required types. A blog usually goes with pages and posts. Pages won't have fields like the author or creation dates displayed.
Pages are usually reached under their name directly. Posts will be posted several times a month and might have a structure like `/year/month/name`.
The archetypes should reflect the data that is needed for the content. Posts should have tags and categories applied.

```toml
[permalinks]
    posts = "/:year/:month/:slug/"
    page = "/:slug/"
```

This might be the archetype for posts. I prefer to collect all categories and tags in the archetype so I can remove all unused ones for the new blog post.

```yaml
---
title: "{{ replace .Name "-" " " | title }}"
author: Sebastian
type: post
date:  {{ now.Format "2006-01-02" }}
featured_image: myimage.jpg
images: ["myimage.jpg"]
draft: true
categories:
  - A
  - B
  - C
tags:
  - Hugo
  - Game Development
  - Internet of Things (IoT)
  - Linux
  - ...
description: xxx
---

CONTENT

&nbsp;

Source: xyz
```

`images` is used by the embedded Open Graph and Twitter Card templates. Set it to the same file as `featured_image`.

## Configure the site

Configure your new site with all relevant [options](https://gohugo.io/configuration/). These are helpful values to start with.

```toml
baseURL = "https://www.spech.de/"
locale = "de-DE" # was languageCode
title = "My hugo page"
copyright = "Sebastian Pech"
enableRobotsTXT = true

[params]
  description = "Nice page"

[params.author]
  name = "Sebastian Pech"

[pagination]
  pagerSize = 10 # was paginate

[sitemap]
  changefreq = "weekly"
  priority = 0.5

[permalinks]
  posts = "/:year/:month/:slug/"
  page = "/:slug/"
```

Make sure to send your `sitemap.xml` file to [Google Search Console](https://search.google.com/search-console), [Bing Webmaster Tools](https://www.bing.com/webmasters), ...

## Keep up with Hugo deprecations

Hugo removes old functions and settings after a deprecation phase. Run a build with info logging from time to time and fix every deprecation warning before it becomes an error:

```sh
hugo --logLevel info | grep -i deprecat
```

Changes that hit most older themes and sites:

| Old | New |
| --- | --- |
| `languageCode` | `locale` |
| `paginate` | `[pagination] pagerSize` |
| `googleAnalytics` | `[services.googleAnalytics] ID` |
| `.Site.Author` | `.Site.Params.author` |
| `.Site.Data` / `site.Data` | `hugo.Data` |
| `toCSS` / `resources.ToCSS` | `css.Sass` |
| `{{ template "_internal/opengraph.html" . }}` | `{{ partial "opengraph.html" . }}` |

Set `min_version` in a theme's `theme.toml` to the oldest Hugo version you actually tested.

### Template system since Hugo 0.146

Hugo 0.146 re-implemented the template lookup and changed the `layouts` folder ([overview](https://gohugo.io/templates/new-templatesystem-overview/)). Old structures are mapped automatically, so existing themes keep working, but new themes and sites should use the new names:

| Old | New |
| --- | --- |
| `layouts/_default/single.html`, `list.html`, `baseof.html` | `layouts/single.html`, `list.html`, `baseof.html` |
| `layouts/index.html` (home page) | `layouts/home.html` |
| `layouts/partials/` | `layouts/_partials/` |
| `layouts/shortcodes/` | `layouts/_shortcodes/` |
| `layouts/_default/_markup/` | `layouts/_markup/` |
| `list-baseof.html` | `baseof.list.html` |
| `taxonomy.html` for taxonomy and term pages | `taxonomy.html` and `term.html` (or one `list.html`) |

The examples below use the new paths. In older themes the same files live in the old folders.

## CSS and JavaScript

Old themes kept the css and js files in the static folder. Sometimes tools like Gulp, Grunt and Webpack were used for pre-processing.
Hugo does bundling and minifying for you. For this to work the files have to be put in the `assets` folder.

There are three critical methods to use as the bare minimum `minify`, `fingerprint` and `resources.Concat`. SCSS is compiled with `css.Sass`.

With `minify` you will get a minified version of your files. ([Hugo Documentation](https://gohugo.io/functions/resources/minify/))

The `fingerprint` adds a unique string to the name so that the browser won't cache your files on modification. ([Hugo Documentation](https://gohugo.io/functions/resources/fingerprint/))

Finally `resources.Concat` allows you to concat multiple files to a new one. This works best with `minify`. ([Hugo Documentation](https://gohugo.io/functions/resources/concat/))

### CSS

Putting the above methods in place the minified `main.css` will be created as described below. Keep in mind that the files have to be in the `assets` folder.

```html
{{ $stylemain := resources.Get "css/main.css" | minify | fingerprint "sha512" }}
<link rel="stylesheet" href="{{ $stylemain.RelPermalink }}" integrity="{{ $stylemain.Data.Integrity }}">
```

SCSS is compiled with `css.Sass` ([Hugo Documentation](https://gohugo.io/functions/css/sass/)).

```html
{{ $stylemain := resources.Get "sass/main.scss" | css.Sass | minify | fingerprint "sha512" }}
<link rel="stylesheet" href="{{ $stylemain.RelPermalink }}" integrity="{{ $stylemain.Data.Integrity }}">
```

Combining all css files to one minified file allows fewer HTTP requests.

```html
{{ $csstheme := resources.Get "/sass/main.scss" | css.Sass }}
{{ $csscustom := resources.Get "/css/custom.css" }}
{{ $allcss := slice $csstheme $csscustom | resources.Concat "/css/vendor.css" | minify | fingerprint "sha512" }}
<link rel="stylesheet" href="{{ $allcss.RelPermalink }}" integrity="{{ $allcss.Data.Integrity }}">
```

### Only ship what you use

A full CSS framework is often the largest file of a small site. Bootstrap's SCSS can be imported component by component: copy the import list of `bootstrap.scss` into your own file and comment out what the site does not use (modal, carousel, toasts, ...). In the Bootstrap-BP theme this took the CSS from 43 KB to 23 KB (gzip).

For very small sites (a start page, a CV) a few KB of own CSS with CSS variables, grid and flexbox is often simpler than any framework. The Bootstrap-BP startpage went from 162 KB Bootstrap plus an icon font to about 3 KB of CSS.

### Javascript

Most sites need very little JavaScript. A navbar toggle and dropdowns are a few lines of plain JavaScript, the full Bootstrap bundle is not needed for that. The Bootstrap-BP theme replaced `bootstrap.bundle.min.js` (24 KB gzip) with an own `navigation.js` (0.5 KB) and loads the bundle only on request (`params.bootstrapJS = true`).

If you need several scripts, bundle them in the right order:

```html
{{ $navigation := resources.Get "/js/navigation.js" }}
{{ $main := resources.Get "/js/main.js" }}

{{ $fullscript := slice $navigation $main | resources.Concat "/js/vendor.js" | minify | fingerprint "sha512" }}
<script src="{{ $fullscript.RelPermalink }}" integrity="{{ $fullscript.Data.Integrity }}" defer></script>
```

### Conditionals

All scripts and styles that are needed only on specific pages should be wrapped in conditionals or loaded through front matter.

```html
{{ with .Params.js }}
    {{ range . }}
        {{ $script := resources.Get . | minify | fingerprint "sha512" }}
        <script src="{{ $script.RelPermalink }}" integrity="{{ $script.Data.Integrity }}" defer></script>
    {{ end }}
{{ end }}
```

## Icons as inline SVG

Icon fonts (Font Awesome & co.) load a CSS file and several font files for a handful of icons. Inline SVG only puts the icons into the HTML that a page actually uses and needs no request at all.

Store the glyphs in a data file and render them with a partial:

```json
{ "github": { "w": 496, "d": "M165.9 397.4c0 2-2.3 3.6-5.2 3.6..." } }
```

```html
{{- /* layouts/_partials/icon.html */ -}}
{{- with index hugo.Data.icons . -}}
<svg class="icon" viewBox="0 -448 {{ .w }} 512" aria-hidden="true" focusable="false"><path transform="scale(1,-1)" d="{{ .d }}"/></svg>
{{- end -}}
```

```css
.icon { display: inline-block; height: 1em; width: auto; vertical-align: -0.125em; fill: currentColor; }
```

Font Awesome Free glyphs can be taken from the SVG webfont of the package (`<glyph glyph-name="..." horiz-adv-x="..." d="...">`). They use font units, hence the flipped `viewBox`. Keep the license file (icons CC BY 4.0). Accept the old class names (`fab fa-github`) in the partial, then existing content and data files keep working.

For menus, use menu params instead of HTML in `pre`:

```toml
[[menu.main]]
  name = "About"
  url = "/about/"
  [menu.main.params]
    icon = "user"
```

## Fonts

- The fastest font is no font: a system font stack (`system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`) needs no download and looks native everywhere. It is a good default for themes; let sites add a web font in their custom CSS.
- Self-host the fonts and use **only `woff2`**. `eot`, `ttf`, `svg` and `woff` are not needed by any current browser.
- Use the **latin subset** and only the weights you need. A variable font covers all weights in one file.
- Load a **real bold** weight if the text uses bold (Markdown `**...**`). Without it the browser fakes bold, which looks smeared.
- `font-display: swap` and a `preload` for the main text font.
- A fallback face with `size-adjust` reduces layout shift while the web font loads.

```html
<link rel="preload" href="/fonts/archivo-latin-var.woff2" as="font" type="font/woff2" crossorigin>
```

```css
@font-face {
  font-family: "Archivo";
  font-weight: 400 800;
  font-display: swap;
  src: url("/fonts/archivo-latin-var.woff2") format("woff2");
}

@font-face {
  font-family: "Archivo Fallback";
  src: local("Arial");
  size-adjust: 102%;
}

body { font-family: "Archivo", "Archivo Fallback", system-ui, sans-serif; }
```

## Images

Image files should never be larger than necessary.

Keep the original images next to the Markdown files (as mentioned before) and let Hugo generate smaller versions ([Hugo Documentation](https://gohugo.io/content-management/image-processing/)). Convert JPG and PNG to **WebP**, it saved 30 to 55 % on my sites compared to already optimized JPG/PNG. PNG screenshots with text look better with a higher quality setting.

A partial that returns the processed image keeps this in one place. It never upscales and leaves GIF/SVG untouched:

```html
{{- /* layouts/_partials/image-webp.html */ -}}
{{- $img := .image -}}
{{- $result := $img -}}
{{- if in (slice "jpeg" "png") $img.MediaType.SubType -}}
    {{- $spec := printf "webp q%d" (cond (eq $img.MediaType.SubType "png") 90 80) -}}
    {{- with .fill -}}
        {{- $spec = printf "fill %s %s" . $spec -}}
    {{- else -}}
        {{- with .width }}{{ if gt $img.Width . }}{{ $spec = printf "resize %dx %s" . $spec }}{{ end }}{{ end -}}
    {{- end -}}
    {{- $result = $img.Process $spec -}}
{{- end -}}
{{- return $result -}}
```

```html
{{ with .Resources.GetMatch .Params.featured_image }}
    {{ $thumb := partial "image-webp.html" (dict "image" . "width" 800) }}
    <img src="{{ $thumb.RelPermalink }}" width="{{ $thumb.Width }}" height="{{ $thumb.Height }}" alt="{{ $.Title }}" loading="lazy" decoding="async">
{{ end }}
```

Background images in CSS can be processed the same way and handed over as a CSS variable:

```html
{{ with resources.Get "images/bg.jpg" }}
    {{ $large := .Process "resize 1920x webp q75" }}
    {{ $small := .Process "resize 960x webp q70" }}
    <style>:root { --bg: url("{{ $large.RelPermalink }}"); --bg-small: url("{{ $small.RelPermalink }}"); }</style>
{{ end }}
```

### Image sizes in HTML and CSS

- Always set `width` and `height` on `<img>`. The browser reserves the space and the page does not jump while loading.
- If CSS sets the width (`width: 100%`), also set `height: auto`. Otherwise the `height` attribute wins and the image is distorted on smaller screens.
- Use `loading="lazy"` for everything below the fold, but not for the first large image (use `fetchpriority="high"` there).
- For grids with mixed image formats, crop in CSS instead of creating many sizes: `aspect-ratio: 16 / 9; object-fit: cover;`.

## Caching and server configuration

See the example `nginx-config` in the `static` folder (and the `.htaccess` in the [Bootstrap-BP startpage](https://github.com/spech66/bootstrap-bp-hugo-startpage/blob/master/static/.htaccess) for Apache). It covers the following points.

- Redirects for old content
- Compression
- Caching (long cache times are safe for fingerprinted files)
- SSL
- HSTS and Content Security Policies
- Error documents
- Wordpress migration rules

Make sure you understand every rule before applying it! The Content-Security-Policy might break your page if you rely on external sources.

## Structured data (Schema.org)

Use the Hugo [embedded templates](https://gohugo.io/templates/embedded/) for Open Graph and Twitter Cards: `{{ partial "opengraph.html" . }}` and `{{ partial "twitter_cards.html" . }}`. For Schema.org JSON-LD build the data as a `dict` and let `jsonify` do the escaping. String templates break as soon as a title contains a quote, and dates need extra care.

```html
{{- /* layouts/_partials/seo_schema.html */ -}}
{{- if eq .Section "posts" -}}
{{- $schema := dict
    "@context" "https://schema.org"
    "@type" "BlogPosting"
    "mainEntityOfPage" (dict "@type" "WebPage" "@id" .Permalink)
    "headline" .Title
    "description" (or .Description (.Summary | plainify | chomp))
    "inLanguage" .Lang
    "datePublished" (.PublishDate.Format "2006-01-02T15:04:05-07:00")
    "dateModified" (.Lastmod.Format "2006-01-02T15:04:05-07:00")
    "url" .Permalink
    "author" (dict "@type" "Person" "name" site.Params.author.name)
-}}
{{- with .Params.tags }}{{ $schema = merge $schema (dict "keywords" .) }}{{ end -}}
<script type="application/ld+json">{{ $schema | jsonify | safeJS }}</script>
{{- end -}}
```

For courses and events use `Event` with an `Offer`. Google warns if the offer has no `validFrom` (the date from which tickets or registrations are available), so set it from the front matter or the page date.

Check the result with the [Rich Results Test](https://search.google.com/test/rich-results) and the [Schema Markup Validator](https://validator.schema.org/).

## External links in new window

Goldmark has no option for `target="_blank"`, use a [link render hook](https://gohugo.io/render-hooks/links/) in `layouts/_markup/render-link.html` (older themes: `layouts/_default/_markup/`). Write it without line breaks inside the `<a>`, otherwise the whitespace becomes part of the link text. A small, quiet icon marks external links without making the text restless.

```html
{{- $external := strings.HasPrefix .Destination "http" -}}
<a href="{{ .Destination | safeURL }}"{{ with .Title }} title="{{ . }}"{{ end }}{{ if $external }} target="_blank" rel="noopener noreferrer"{{ end }}>{{ .Text | safeHTML }}
{{- if $external }}&nbsp;{{ partial "icon.html" "external-link-alt" }}{{ end -}}
</a>
```

## Themes: overrides and maintenance

- **Override as little as possible.** A site copy of a theme partial freezes that partial: later theme fixes never reach the site. Before copying a whole partial, check if the theme offers a parameter or a small hook partial for it, or add one (e.g. an empty `content_card_body_extra.html` the site can fill).
- **Find stale overrides** from time to time by diffing the site's `layouts/` against the theme. Identical or nearly identical files can go.
- **Never change files inside `themes/`** of a site if the theme is copied or synced from elsewhere. The next update overwrites them. Site specific things belong into the site's `layouts/` and `assets/`.
- **Keep private things out of public themes** (contact form backends, personal texts).
- **Release tags:** in my experience the [Hugo themes](https://themes.gohugo.io/) site keeps using the latest release tag once a theme repository has tags, newer untagged commits do not show up. Either tag every release or never tag. Tags should be [semantic versions](https://semver.org/) (`v1.2.3`).
- **Gallery screenshots** for the [Hugo themes](https://themes.gohugo.io/) site: `images/screenshot.png` (1500x1000) and `images/tn.png` (900x600). Take them from the example site with a headless browser, e.g. `msedge --headless=new --hide-scrollbars --window-size=1500,1000 --screenshot=screenshot.png http://localhost:1313/` (`--force-device-scale-factor=0.6` for the thumbnail).

## Readability and accessibility

- Check text contrast on every background, especially text on images and semi-transparent cards. `opacity` on a card fades the text as well; use a semi-transparent background color (or `backdrop-filter: blur()`) instead.
- Fewer signals per element feel calmer: one meta line without icons (`date · 5 min read`) instead of several icons, quiet tags instead of heavy badges.
- Keep cards in a grid the same height: fixed image ratio, summary cut with `-webkit-line-clamp`, tags pushed to the bottom with `margin-top: auto`.
- Make the whole card clickable with one link and a stretched `::after` instead of several "Read more" links, and lift other links in the card above it with `position: relative; z-index: 2`.
- Visible keyboard focus (`:focus-visible`) and `prefers-reduced-motion` for hover animations.
- Text on photos: a gradient overlay and a "frosted glass" surface (`background: rgba(...)` plus `backdrop-filter: blur(14px)`) keep text readable on any image. Offer a solid fallback with `@media (prefers-reduced-transparency: reduce)`.
- Build navigation lists from the data (menus, data files, sections) instead of a hardcoded list. Missing entries then disappear instead of producing empty links.

## Dark mode

- Define all colors as CSS variables and switch them with one class (or `prefers-color-scheme`), never duplicate whole rule sets.
- Pick dark colors separately. Inverting the light palette rarely works: links and the accent color usually need a lighter shade on dark backgrounds.
- If visitors can toggle the theme, set the class with a small inline script directly after `<body>`. A script at the end of the page applies the theme after the first paint and the page flashes in the wrong colors.

```html
<body>
<script>(function(){var t=null;try{t=localStorage.getItem("theme");}catch(e){}if(t==="dark"||(t!=="light"&&matchMedia("(prefers-color-scheme: dark)").matches)){document.body.classList.add("dark-theme");}})();</script>
```

```css
:root { --text: #3a4452; --bg: #ffffff; --accent: #245d93; }
body.dark-theme { --text: #c9ced6; --bg: #1b1e23; --accent: #8cc0f2; }
```

Wrap `localStorage` in `try`/`catch`, it throws in some privacy modes.

## Print styles

Pages that are printed or saved as PDF (CVs, recipes, documentation) need a print stylesheet:

```css
@page { size: A4; margin: 16mm 14mm; }

@media print {
  nav, footer, .buttons { display: none; }
  body { background: #fff; color: #000; }
  h2, h3 { break-after: avoid; }           /* no heading at the end of a page */
  li, figure, .small-block { break-inside: avoid; }
}
```

Use `break-inside: avoid` only for small elements. On a long block it pushes the whole block to the next page and leaves half a page empty. Reset dark mode colors in print, and hide decorative icons.

## Check pages with a headless browser

Chrome and Edge can take screenshots and PDFs from the command line. This is handy for theme gallery images, to check dark mode and to test the print layout:

```sh
# screenshot in light or dark mode (preferredColorScheme: 0 = dark, 1 = light)
msedge --headless=new --hide-scrollbars --window-size=1500,1000 --blink-settings=preferredColorScheme=1 --screenshot=light.png http://localhost:1313/

# thumbnail at 60 % (900x600)
msedge --headless=new --hide-scrollbars --window-size=1500,1000 --force-device-scale-factor=0.6 --screenshot=tn.png http://localhost:1313/

# print layout as PDF
msedge --headless=new --no-pdf-header-footer --print-to-pdf=page.pdf http://localhost:1313/
```

Use `chrome` instead of `msedge` with the same flags. Pass a separate `--user-data-dir` if a normal browser window is open at the same time.

## Front-End Checklist

Walk through every point in the [Front-End Checklist](https://github.com/thedaviddias/Front-End-Checklist) and the [Front-End Performance Checklist](https://github.com/thedaviddias/Front-End-Performance-Checklist).

## Awesome Hugo list

Additional links and resources can be found at [Awesome Hugo](https://github.com/theNewDynamic/awesome-hugo). *A curated list of awesome things related to Hugo.*

## Tools

There are some tools and websites that can validate your page and check the speed.

- [webhint](https://webhint.io/) _is a linting tool that will help you with your site's accessibility, speed, security and more, by checking your code for best practices and common errors._ The online scanner was shut down, use the CLI or the VS Code extension.
- [Google PageSpeed Insights](https://pagespeed.web.dev/) checks performance, loading times and image sizes.
- [Google Lighthouse](https://developer.chrome.com/docs/lighthouse/) performs audits on website performance, best practices, accessibility and SEO. It is built into Chrome and Edge DevTools.
- [Rich Results Test](https://search.google.com/test/rich-results) and [Schema Markup Validator](https://validator.schema.org/) validate the structured data on the website.
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) checks text and background colors.
- [SSL Server Test](https://www.ssllabs.com/ssltest/index.html) is a _free online service performing a deep analysis of the configuration of any SSL web server on the public Internet._
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/) _An easy-to-use secure configuration generator for web, database, and mail software._
- [SEORCH](https://seorch.de/) German SEO testing tool.
