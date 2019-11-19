use v6.*;
use Test;

use Pod::To::HTML;
my $processor = Pod::To::HTML.processor;
my $rv;
my $pn = 0;

plan 11;

=begin pod
X<|behavior> L<http://www.doesnt.get.rendered.com>
=end pod
    
$processor.process-pod( $=pod[$pn++] );
$rv = $processor.body-only;

like $rv,
    /
    'href="http://www.doesnt.get.rendered.com"'
    /, 'zero width with glossary passed';

=begin pod

When creating an anchor (or indexing), eg. for a glossary, for X<an item> the X<X format> is used.

It is possible to reference the same text, eg. X<an item>, in multiple places.
=end pod

$processor.process-pod( $=pod[$pn++] );
$rv = $processor.body-only
        .subst(/\s+/,' ',:g);

like $rv,
    /
    '<section name="___top">'
    \s* '<p>'
    \s* 'When creating an anchor (or indexing), eg. for a glossary, for '
    \s* '<a name="an_item"></a>'
    \s* '<span class="glossary-entry">an item</span>'
    \s* 'the'
    \s* '<a name="x_format"></a>'
    \s* '<span class="glossary-entry">X format</span> is used.'
    .+ 'same text, eg.'
    \s* '<a name="an_item' .+ '></a>'
    \s* '<span class="glossary-entry">an item</span>'
    \s* ', in multiple places.'
    /, 'X format in text';

$rv = $processor.render-glossary
        .subst(/\s+/,' ',:g).trim;

like $rv, /
    '<table id="glossary">'
    \s* '<caption><h2 id="source-glossary">Glossary</h2></caption>'
    \s* '<tr class="glossary-defn-row">'
    \s*     '<td class="glossary-defn">X format</td><td></td></tr>'
    \s*         '<tr class="glossary-place-row"><td></td><td class="glossary-place"><a href="#x_format">' .+ '</a></td></tr>'
    \s* '<tr class="glossary-defn-row">'
    \s*     '<td class="glossary-defn">an item</td><td></td></tr>'
    \s*         '<tr class="glossary-place-row"><td></td><td class="glossary-place"><a href="#an_item">' .+ '</a></td></tr>'
    \s*         '<tr class="glossary-place-row"><td></td><td class="glossary-place"><a href="#an_item_0">' .+ '</a></td></tr>'
    \s* '</table>'
    /, 'glossary rendered later';

$processor.no-glossary = True;
$rv = $processor.render-glossary
        .subst(/\s+/,' ',:g).trim;

unlike $rv, /
    '<table id="glossary">'
    /, 'No glossary is rendered';

=begin pod

When indexing X<an item|Define an item> another text can be used for the index.

It is possible to index X<hierarchical items|defining,a term>with hierarchical levels.

And then index the X<same place|Same,almost;Place> with different index entries.

But X<|an entry can exist> without the text being marked.

An empty X<> is ignored.
=end pod

# Need to eliminate all previous glossary entries. Easiest by just making new instance.

$processor = Pod::To::HTML.processor;
$processor.process-pod( $=pod[$pn++] );
$rv = $processor.body-only;

like $rv,
    /
    'When indexing'
    \s* '<a name="define_an_item"></a>'
    \s * '<span class="glossary-entry">an item</span>'
    .+ 'to index'
    \s* '<a name="' .+ '></a>'
    \s * '<span class="glossary-entry">hierarchical items</span>'
    .+ 'index the'
    \s* '<a name="same' .+ '></a>'
    \s * '<span class="glossary-entry">same place</span>'
    .+ 'But' \s* '<a name' .+ '</a>' \s* 'without the text being marked.'
    .+ 'An empty' \s+ 'is ignored.'
    /,  'Text with indexed items correct';

$rv = $processor.render-glossary.subst(/\s+/,' ',:g).trim;

like $rv, /
    '<tr class="glossary-defn-row">' \s* '<td class="glossary-defn">Define an item</td><td></td>'
    /, 'glossary contains the right entry text';

like $rv, /
    '<td class="glossary-defn">defining</td><td></td>' .* '<td></td><td class="glossary-place">' .+? 'a term' .+? '</td>'
    /, 'glossary contains hierarchy';

like $rv, /
    '<td class="glossary-defn">Same</td><td></td>'
    /, 'glossary contains Same';

like $rv, /
    '<td class="glossary-defn">Place</td><td></td>'
    /, 'glossary contains Place';

like $rv, /
    '<td class="glossary-defn">an entry can exist</td><td></td>'
    /, 'glossary contains entry of zero text marker';
$rv ~~ /  [ '<td class="glossary-defn">' ~ '</td>'  $<es> =(.+?)  .*? ]* $ /;

is-deeply $<es>>>.Str, ['Define an item','Place','Same','an entry can exist','defining'], 'Entries match, nothing for the X<>';