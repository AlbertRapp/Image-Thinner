# About

## Author and Code
This small [`{Shiny}`](https://shiny.rstudio.com/) app was created by [Albert Rapp](https://albert-rapp.de/). 
It is licensed under a [CC BY-NC 4.0 license](https://creativecommons.org/licenses/by-nc/4.0/).
So, feel free to use it as you see fit.
The code can be found on [GitHub](https://github.com/AlbertRapp/Image-Thinner).

## Under The Hood
If you want to learn how to build this app, let me give you a few pointers.

I wrote an intro to `{Shiny}` in Chapter 13 of my [YARDS lecture notes](https://yards.albert-rapp.de/shiny-applications.html).
Most of the additional `{Shiny}` logic necessary for this app can be learned from two of my blog posts ([here](https://albert-rapp.de/post/2021-11-21-a-few-learnings-from-a-simple-shiny-app/) and [here](https://albert-rapp.de/post/2022-01-17-drawing-a-ggplot-interactively/)).
The following "tricks" will do the rest.

- Image processing was done with [`{magick}`](https://docs.ropensci.org/magick/). 
Import an image via `image_read()` and compute the image's pixel grid with `image_raster()`.


- In this app, millions of points/pixels have to be plotted. 
This is powered by [`{scattermore}`](https://github.com/exaexa/scattermore) which enhances the speed of [`{ggplot2}`](https://ggplot2.tidyverse.org/) dramatically.


- Wrap `plotOutput()` in `withSpinner()` from [`{shinycssloaders}`](https://github.com/daattali/shinycssloaders). During long calculations, this will inform the user that something is happening.


- To avoid clutter, long texts were added via Markdown files. 
For example, this page was included in a `tabPanel()` using `columns()`.

```
tabPanel(
  "About",
  fluidRow(
    # White space left and right avoids wall of text.
    column(2),
    column(8, div(includeMarkdown('about.md'))),
    column(2)
  )
)
```


- Allow 10 MB file sizes: `options(shiny.maxRequestSize = 10 * 1024^2)`


- Basic theming of this app was performed with [`{bslib}`](https://rstudio.github.io/bslib/). I'm no design genius so I added only the following "one"-liner to `fluidPage()`.

```
theme = bslib::bs_theme(
  bg = 'white', 
  fg = '#06436e', 
  primary = colorspace::lighten('#06436e', 0.3),
  base_font = 'Source Sans Pro',
  heading_font = 'Oleo Script'
)
```

<br>
