# hugo-best-practices

Best practices and ideas for [Hugo](https://gohugo.io/) the open-source static site generator.

If there is any english native speaker reading this I would be glad to get some corrections on the wording. ;-)

## Organize Content

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

## Copy the theme folder content

In 99.999% of the time you want to make changes to existing themes. To keep your version independent of the latest development copy all theme files (except from screenshots and examples) to your main directory.
There is no need to provide the theme setting in the config anymore. However you might want to add the theme as a git submodule to your themes directory.
Having the submodule available allows you to diff your files to the lastest master. This gives you the possibility to copy relevant features and fixes to your own theme.

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

Hugo allows you to create resources from `.Param` information ([Hugo Documentation](https://gohugo.io/hugo-pipes/resource-from-string/)).
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

## Front-End Checklist

Walk trough every point in the [Front-End Checklist](https://github.com/thedaviddias/Front-End-Checklist)
