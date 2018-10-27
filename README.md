# hugo-best-practices

Best practices and ideas for [Hugo](https://gohugo.io/) the open-source static site generator.

If there is any english native speaker reading this I would be glad to get some corrections on the wording. ;-)

## Content organization

I prefer to keep all images next to the Markdown files.
This allows me to keep the images in the highest poossible resolution and use the latest hugo version to resize them to the perfect size for the current theme.

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

There is a Discussion on this in the [Forum](https://discourse.gohugo.io/t/discussion-content-organization-best-practice/6360/2).

## Git repository and CI Tools

Keep your site in a version control system like Git. This provides backup, history and multi user editing out of the box.

Use Continuous Integration/Deployment to publish your website after git push. Simple solutions like [webhook](https://github.com/adnanh/webhook/) might do the job. For complex scenarios you might want to use something like [Jenkins](https://jenkins.io/). For most cases Jenkins will be overkill.

You can sync files using `rsync` after a successfull build. Have a look at the provided `deployment` scripts in this repository.

## Content types and archetypes

Define your required types. A blog usually goes with pages and posts. Pages won't have things like the author or creation dates display.
They are usually reached under their name directly. Posts will be postet regualary and might have a structure like `/year/month/name`.
The archetypes should reflect the data that is needed for the content. Posts should have tags and categories applied.

```yaml
[permalinks]
    posts = "/:year/:month/:slug/"
    page = "/:slug/"
```

This might be the archetype for posts. I prefect to collect all categories and tags in the archetype so I can remove all unused ones for the new blog post.

```yaml
---
title: "{{ replace .Name "-" " " | title }}"
author: Sebastian
type: post
date:  {{ now.Format "2006-01-02" }}
featured_image: myimage.jpg
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

## Configure the site

Configure your new site with all relevant [options](https://gohugo.io/getting-started/configuration/). These are helpful values to start with.

```yaml
# Settings
baseURL = "https://www.spech.de/"
languageCode = "de-DE" # or en-US
title = "My hugo page"
description = "Nice page"
# theme = "hugo-future-imperfect" # <- you won't need this as we copy the theme data!
googleAnalytics = "UA-111111111111-1"
canonifyURLs = true
copyright = "Sebastian Pech"
enableRobotsTXT = true

[sitemap]
    changefreq = "weekly"
    priority = 0.5

[permalinks]
    posts = "/:year/:month/:slug/"
    page = "/:slug/"
```

Make sure to send your `sitemap.xml` file to [Google Search Console](https://www.google.com/webmasters/tools/home), [Bing Webmaster Tools](https://www.bing.com/toolbox/webmaster), ...

## Copy the theme folder content

In 99.999% of the time you want to make changes to existing themes. To keep your version independent of the latest development copy all theme files (except from screenshots and examples) to your main directory.
There is no need to provide the theme setting in the config anymore. However you might want to add the theme as a git submodule to your themes directory.
Having the submodule available allows you to diff your files to the lastest master. This gives you the possibility to copy relevant features and fixes to your own theme.

I hope that newer themes will just work out of the box with performance and SEO kept in mind.

## CSS and JavaScript

Old themes kept the css and js files in the static folder. Sometimes tools like Gulp, Grunt and Webpack were used for pre-processing.
The latest version of Hugo will do all the stuff like bundling and minifiy for you. For this to work the files have to be put in the `assets` folder.

There are three critical methods to use as the bare minimum `minify`, `fingerprint` and `slice`. SCSS might make use of `toCSS` and `postCSS`.

With `minify` you will get a minified version of your files. ([Hugo Documentation](https://gohugo.io/hugo-pipes/minification/))

The `fingerprint` adds a unique string to the name so that the browser won't cache your files on modification. ([Hugo Documentation](https://gohugo.io/hugo-pipes/fingerprint/))

Finally `slice` allows you to concat multiple files to a new one. This works best with `minify`. ([Hugo Documentation](https://gohugo.io/hugo-pipes/bundling/))

### CSS

Putting the above methods in place the minified `main.css` will be created as described below. Keep in mind that the files has to be in the `assets` folder.

```html
{{ $stylemain := resources.Get "css/main.css" | minify | fingerprint }}
<link rel="stylesheet" href="{{ $stylemain.Permalink }}" integrity="{{ $stylemain.Data.Integrity }}">
```

For processing SCSS Hugo provides two functions. ([Hugo Documentation](https://gohugo.io/hugo-pipes/postcss/))

```html
{{ $stylemain := resources.Get "scss/main.scss" | toCSS | postCSS (dict "use" "autoprefixer") | minify | fingerprint }}
<link rel="stylesheet" href="{{ $stylemain.Permalink }}" integrity="{{ $stylemain.Data.Integrity }}">
```

### Javascript

Usually a theme will contain multiple JS files which might require a specific order. This is where `slice` comes into handy.

```html
{{ $jquery := resources.Get "/js/jquery-v6.6.6/jquery.min.js" }}
{{ $bootstrap := resources.Get "/js/bootstrap-v4.2.0/bootstrap.min.js" }}
{{ $main := resources.Get "/js/main.js" }}

{{ $fullscript := slice $jquery $bootstrap $main | resources.Concat "/js/vendor.js" | minify | fingerprint }}
<script src="{{ $fullscript.Permalink }}"></script>
```

## Images

Image files should never be larger than necessary.

Hugo allows you to create resources from `.Params` information ([Hugo Documentation](https://gohugo.io/hugo-pipes/resource-from-string/)).
The resources can be processed with the image processing functions from Hugo afterwards ([Hugo Documentation](https://gohugo.io/content-management/image-processing/)).
This allows you to keep the original images next to the Markdown files (as mentioned before) and let Hugo generate thumbnails and smaller versions.

```html
featured_image: my-blog-header-1.jpg
```

This example resizes the image mentioned in the `featured_image` parameter of the blog page to a version with 800 pixel width.

```html
{{ if .Params.featured_image }}
    {{ $siteurl := (.RelPermalink) }}
    {{ $sitetitle := (.Title) }}
    {{ with .Resources.GetMatch (.Params.featured_image) }}
        {{ $thumb := .Resize "800x" }}
        <img src="{{ $thumb.Permalink }}" alt="{{ $sitetitle }}">
    {{ end }}
{{ end }}
```

## Caching and .htaccess

See the example `.htaccess` in the `static` folder. It covers the following points.

* Redirects for old content
* Compression
* Caching
* SSL
* HSTS and Content Security Policies
* Errror documents
* Wordpress migration rules

Make sure you understand every rule before applying it! The Content-Security-Policy might break your page if you rely on external sources.

## Add a Schema.org partial

Add a Schema.org partial according to [](https://keithpblog.org/post/hugo-website-seo/).

```html
# layouts/partials/header.html
...
{{ partial "seo_schema" . }}
<title>
...
```

```js
// layouts/partials/seo_schema.html
<script type="application/ld+json">
{
    "@context" : "http://schema.org",
    "@type" : "BlogPosting",
    "mainEntityOfPage": {
         "@type": "WebPage",
         "@id": "{{ .Site.BaseURL }}"
    },
    "articleSection" : "{{ .Section }}",
    "name" : "{{ .Title }}",
    "headline" : "{{ .Title }}",
    "description" : "{{ if .Description }}{{ .Description }}{{ else }}{{if .IsPage}}{{ .Summary }}{{ end }}{{ end }}",
    "inLanguage" : "{{ .Lang }}",
    "author" : "{{ range .Site.Author }}{{ . }}{{ end }}",
    "creator" : "{{ range .Site.Author }}{{ . }}{{ end }}",
    "publisher": "{{ range .Site.Author }}{{ . }}{{ end }}",
    "accountablePerson" : "{{ range .Site.Author }}{{ . }}{{ end }}",
    "copyrightHolder" : "{{ range .Site.Author }}{{ . }}{{ end }}",
    "copyrightYear" : "{{ .Date.Format "2006" }}",
    "datePublished": "{{ .Date | safeHTML }}",
    "dateModified" : "{{ .Date | safeHTML }}",
    "url" : "{{ .Permalink }}",
    "wordCount" : "{{ .WordCount }}",
    "keywords" : [ {{ if isset .Params "tags" }}{{ range .Params.tags }}"{{ . }}",{{ end }}{{ end }}"Blog" ]
}
</script>
```

I modified the example with `{{ .Date | safeHTML }}` otherwise Hugo replaces the + for positive timezones (like GTM, MEZ, ...) with a HTML escaped sequence which makes the javascript illegal for HTML check tools.

## Front-End Checklist

Walk trough every point in the [Front-End Checklist](https://github.com/thedaviddias/Front-End-Checklist) and the [Front-End Performance Checklist](https://github.com/thedaviddias/Front-End-Performance-Checklist).
