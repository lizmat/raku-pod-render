# Rendering POD6 into HTML
>Renders POD6 sources into HTML using templates


----
## Table of Contents
[Usage with compiler](#usage-with-compiler)
[Standalone usage mixing Pod and code](#standalone-usage-mixing-pod-and-code)
[HTML Components: CSS, Classes &amp; Favicon](#html-components-css-classes--favicon)
[Customisable CSS](#customisable-css)
[CSS Load](#css-load)
[CSS Link](#css-link)
[Camelia Image](#camelia-image)
[Favicon](#favicon)
[Highlighting](#highlighting)
[Templates](#templates)
[Exported Subroutines](#exported-subroutines)
[Miscellaneous](#miscellaneous)
[Why Reinvent the Wheel?](#why-reinvent-the-wheel?)

----
A simple default set of templates is provided with a default set of css and a header with the Camelia-bug image.

Since no assumption can be made about the way the html is served, everything in the default templates assumes output to an html file that can be served as a file (eg., no embedded images from external files). The default behaviour can be changed by changing one or more or all of the templates.

The rationale for re-writing the whole Pod::To::HTML module is in the section [Why Reinvent the Wheel?](#why-reinvent-the-wheel?).

For more information about methods not covered here see the [PodProcess Class](RenderPod.md). A sister class [Markdown](MarkDown.md) is available.

# Usage with compiler
From the terminal:

```
raku --doc=HTML input.raku > output.html

```
Possibly the compiler may run the legacy `Pod::To::HTML` module. If so the following may work:

```
raku --doc=HTML2 input.raku > output.html

```
This takes the POD in the `input.raku` file, transforms it into HTML, outputs a full HTML page including a Table of Contents, Glossary and Footnotes.

Some rendering options can be passed via the PODRENDER Environment variable. The options can be used to turn off components of the page.

```
PODRENDER='NoTOC NoMETA NoGloss NoFoot' raku --doc=HTML input.raku > output.html

```
The following regexen are applied to the contents of the PODRENDER environment variable and if one or more matchd, they switch off the default rendering of the respective section:

>Regexen and Page Component

|regex applied|if Match, then Turns off|
|:----:|:----:|
|/:i 'no' '-'? 'toc' /|Table of Contents|
|/:i 'no' '-'? 'meta' /|Meta information (eg AUTHOR)|
|/:i 'no' '-'? 'glossary' /|Glossary|
|/:i 'no' '-'? 'footnotes' /|Footnotes.|

Any or all of 'NoTOC' 'NoMETA' 'NoGloss' 'NoFoot' may be included in any order. Default is to include each section.

# Standalone usage mixing Pod and code
'Standalone ... mixing' means that the program itself contains pod definitions (some examples are given below). This functionality is mainly for tests, but can be adapted to render other pod sources.

`Pod::To::HTML` is a subclass of `PodProcessed`, which contains the code for a generic Pod Render. `Pod::To::HTML` provides a default set of templates and minimal css. It also exports some routines (not documented here) to pass the tests of the legacy `Pod::To::HTML` module (see below for the rationale for choosing a different API).

`Pod::To::HTML` also allows, as covered below, for a customised css file to be included, for individual template components to be changed on the fly, and also to provide a different set of templates.

What is happening in this case is that the raku compiler has compiled the Pod in the file, and the code then accesses the Pod segments. In fact the order of the Pod segments is irrelavant, but it is conventional to show Pod definitions interwoven with the code that accesses it.

```
use Pod::To::HTML;
# for repeated pod trees to be output as a single page or html snippets (as in a test file)
my $renderer = Pod::To::HTML.new(:name<Optional name defaults to UNNAMED>);
# later

=begin pod
some pod
=end pod

say 'The rendered pod is: ', $renderer.render-block( $=pod );

=begin pod

another fact-filled assertion

=end pod

say 'The next pod snippet is: ', $renderer.render-block( $=pod[1] );
# note that all the pod in a file is collected into a 'pod-tree', which is an array of pod blocks. Hence
# to obtain the last Pod block before a statement, as here, we need the latest addition to the pod tree.

# later and perhaps after many pod statements, each of which must be processed through pod-block

my $output-string = $renderer.source-wrap;

# will return an HTML string containing the body of all the pod items, TOC, Glossary and Footnotes.
# If there are headers in the accumulated pod, then a TOC will be generated and included
# if there are X<> type references in the accumulated pod, then a Glossary will be generated and included

$renderer.file-wrap(:output-file<some-useful-name>, :ext<html>);
# first .source-wrap is called and then output to a file.
# if ext is missing, 'html' is used
# if C<some-useful-name> is missing, C<name> is used, which defaults to C<UNNAMED>
# C<some-useful-name> could include a valid path.


```
# HTML Components: CSS, Classes &amp; Favicon
A minimal CSS is provided for the default templates and is placed in a <style>...</style> container. This default behaviour can be changed, see below.

In addition to the rendering of containers, extra styling can be achieved by adding classes via configuration parameters. For example `myclass` can be added to a table as follows `=begin table :classes<myclass> `. The CSS to affect the styling needs to be added to a customisable CSS.

The different customisations are incompatible during object instantiation.

*  If `:templates` is specified, then the `:css-type`, `:css-src` and `:favicon-src` will not have any effects. This should not be a concern because when providing templates, a raku program that evaluates to a Hash is run. Any desired customisation can be handled in the same program.

*  If a file `html-templates.raku` exists in the current directory, then it will be given to the object, see above.

*  It is possible, though to retain the `:css-type`, `:css-src` and `:favicon-src` customisations, but to change specific templates, via the `modify-templates` method.

## Customisable CSS
Two variables `:css-type` and `:css-src` are provided to customise the loading of css for the 'source-wrap' template provided here. These can be specified as arguments to `processor`.

If the `head-block` templates, which is used in the `source-wrap` template, contain the Mustache stanza `{{> css-text }}`, which calls the partial template `css-text` . When `Pod::To::HTML` is instantiated using these variables, a style string is given to the css-text. In order to use the default css behaviour of `Pod::To::HTML`, only over-ride some templates, keeping css-text, and use the `css-text` or `head-block` templates.

If `:css-type` is specified, then `:css-src` must be specified.

## CSS Load
```
    use Pod::To::HTML;
    my Pod::To::HTML $processor .= new(:css-type<load>, :css-src('path/to/custom.css') );

```
The contents of path/to/custom.css are slurped into a `<style> ` container and given to the template `css-text`.

This is similar to the default action of the module, except that the pod.css file is in the module repository.

## CSS Link
Normally, when HTML is served a separate CSS file is loaded from a path on the server, or an http/https link. Then it is know where the source is, eg.,`assets/pod.css`, or it might be loaded from another internet source, eg. `https://somedomain.com/assets/pod.css`.

```
    use Pod::To::HTML;
    my Pod::To::HTML $processor .= new(:css-type<link>, :css-src('https://somedomain.dom/assets/pod.css') );

```
This generates a string that is given to the template `css-text`. For example: `<link rel="stylesheet" type="text/css" href="https://somedomain.com/assets/pod.css" media="screen" title="default" /> `

## Camelia Image
The Camelia image is the mascot for Raku. It is provided in the Header by default.

The behaviour can be changed by changing the `header` template

## Favicon
The Camelia icon is inserted by default. Since the most generic form has no other links, the favicon has to be provided as a Base64 encoding of a standard icon.

If another favicon is required, then it can be inserted by

*  convert the favicon to base64 coding, eg. a site such as [MotoBit](https://www.motobit.com/util/base64-decoder-encoder.asp)

*  store the text string produced in a file, eg 'assets/favicon.bin'

*  provide that filename when instantiating a `Pod::To::HTML` object, eg.,

```
use Pod::To::HTML;
my Pod::To::HTML $p .= new(:favicon-src('assets/favicon.bin') );
...

```
Note that the validity of the favicon cannot be tested here, and that different browsers have different favicon requirements.

# Highlighting
Generally it is desirable to highlight code contained in `=code ` blocks. Since this is not easily accomplished for the generic situation when there is no information about the environment, eg., using the `--doc=HTML ` compiler option, highlighting is added after the instantiation of the `ProcessedPod` ( `Pod::To::HTML.processor` call).

For example,

```
    use File::Temp;
    use Pod::To::HTML;
    my $processor = Pod::To::HTML; #default templates/css
    my $proc;
    my $proc-supply;
    my &highlighter;

    # set up a highlighter closure
    # the following uses the coffee set up for the raku.org/docs set up.
    # the coffee assets are not included in the distribution
    # the following is for illustration only!!

    $proc = Proc::Async.new('coffee', './highlighting/highlight-filename-from-stdin.coffee', :r, :w);
    $proc-supply = $proc.stdout.lines;
    $proc.start unless $proc.started;
    &highlighter = -> $raku-string {
        my ($tmp_fname, $tmp_io) = tempfile;
        $tmp_io.spurt: $raku-string, :close;
        my $promise = Promise.new;
        my $tap = $proc-supply.tap( -> $json {
            my $parsed-json = from-json($json);
            if $parsed-json<file> eq $tmp_fname {
                $promise.keep($parsed-json<html>);
                $tap.close();
            }
        } );
        $proc.say($tmp_fname);
        await $promise;
        $promise.result;
    }

    # once the highlighter has been created, attach it to the processor
    # the closure is called with a string of raku code, which it returns as html code.
    $processor.highlighter = &highlighter;


```
# Templates
The default templating engine is Template::Mustache. A minimal default set of templates is provided with the Module.

Each template can be changed using the `modify-templates` method. Be careful when over-riding `head-block` to ensure the css is properly referenced.

A full set of new templates can be provided to ProcessedPod either by providing a path/filename to the processor method, eg.,

```
use Pod::To::HTML;
my Pod::To::HTML $p .= new;

$p.templates<path/to/mytemplates.raku>;

# or if all templates known

$p.templates( %( format-b => '<b>{{ contents }}</b>' .... ) );


```
If :templates is given a string, then it expects a file that can be compiled by raku and evaluates to a Hash containing the templates. More about the hash can be found in [RenderPod](renderpod.md).

When a `Pod::To::HTML` object is instantiated, and the file 'html-templates.raku' exists in the current working directory, it will be evaluated and treated as the source of the templates hash (see above).

This allows a developer to use the compiler option `--doc=HTML` together with her own templates. Note that css must also be provided explicitly in the `head-block` template.

# Exported Subroutines
Two functions are exported to provide backwards compatibility with legacy Pod::To::HTML module. They map onto the methods described above.

Only those options actually tested will be supported.

*  node2html

```
sub node2html( $pod ) is export
```
*  pod2html

```
sub pod2html( $pod, *%options ) is export
```
# Miscellaneous
In the contents, headers can be prefixed with their header levels in the form 1.2.4

The default separator (.) can be changed by setting (eg to _) as :counter-separator<_>

The header levels can be omitted by setting :no-counters

# Why Reinvent the Wheel?
The two original Pod rendering modules are `Pod::To::HTML ` (later **legacy P2HTML** ) and `Pod::To::BigPage `. So why rewrite the modules and create another API? There was an attempt to rewrite the existing modules, but the problems go deeper than a rewrite. The following difficulties can be found with the legacy Modules:

*  Inside the code of legacy P2HTML there were several comments such as 'fix me'. The API provided a number of functions with different parameters that are not documented.

*  Not all of the API is tested.

*  One or two POD features are not implemented in legacy P2HTML, but are implemented in P2BigPage.

*  Fundamentally: HTML snippets for different Pod Blocks is hard-coded into the software. Changing the structure of the HTML requires rewriting the software.

*  Neither module deals with Indexes, or Glossaries. POD6 defines the ** ** format code to place text in a glossary (or index), but this information is not collected or used by P2HTML. The Table of Content data is not collected in the same pass through the document as the generation of the HTML code.

This module deal with these problems as follows:



*  All Pod Blocks are associated with templates and data for the templates. So the Generic Renderer passes off generation of the output format to a Template engine. (Currently, only the Template::Mustache engine is supported, but the code has been designed to allow for other template engines to be supported by over-ridding only the template rendering methods).

*  Data for **Page Components** such as `Table of Contents`, `Glossary`, `Footnotes`, and `MetaData` are collected in a single processing pass of the Generic Renderer. The subclass can provide templates for the whole document to incorporate the Page Components as desired.

*  All the links (both external and internal) are collected together and can be accessed after processing the Pod source, thus allowing for testing of the links separately.

*  There is a clear distinction between rendering a Pod tree (all of the pod in a source), a pod block (the text between the `=begin pod` and `=end pod` markers, and outputting the pod for a page or for the body of a page (without headers, footers, or page components). This distinction required a different API.

*  There is a clear distinction between what is needed for a particular output format, eg., HTML or MarkDown, and what is needed to render Pod. Thus, HTML requires css and headers, etc. MarkDown requires the anchors to connect a Table of Contents to specific Headers in the text to be written in a specific way.

*  `Pod::To::HTML` subclass allows for a more flexible provision of css or other assets.

*  The `source-wrap` template can be completely rewritten to allow for different assets.

*  css can be provided in a file that is **slurped** into the header as a style component

*  css can be provided as a link to a source, when the location of the asset is known and will be loaded by the HTML server.






----
Rendered from Pod2HTML.pod6 at 2020-07-12T20:28:18Z