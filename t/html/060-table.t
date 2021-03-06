use v6.*;
use Test;

use Pod::To::HTML;
my $processor = Pod::To::HTML.new;
my $rv;
my $pn = 0;

plan 5;
=table
  col1  col2

$rv = $processor.render-block( $=pod[$pn++] );

like $rv,
    /
    \s* '<table class="pod-table">'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'simple row';

=table
  H1    H2
  --    --
  col1  col2

$rv = $processor.render-block( $=pod[$pn++] );

like $rv,
    /
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /,'simple header and row';

=begin table :class<sorttable>

  H1    H2
  --    --
  col1  col2

  col1  col2

=end table

$rv = $processor.render-block( $=pod[$pn++] );

like $rv,
    /
    '<table class="' \s* 'pod-table' \s+ 'sorttable' \s* '">'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with class';

=begin table :caption<Test Caption>

  H1    H2
  --    --
  col1  col2

=end table

$rv = $processor.render-block( $=pod[$pn++] );

like $rv,
    /
    '<table class="pod-table">'
    \s*   '<caption>Test Caption</caption>'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td>col1</td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with caption';

=begin table :class<sorttable>

  H1    H2
  --    --
  col1  B<col2>

  I<col1>  col2

=end table

$rv = $processor.render-block( $=pod[$pn++] );
todo 'Compiler does not give information about contents of POD table cells';
like $rv,
    /
    '<table class="pod-table sorttable">'
    \s*   '<thead>'
    \s*     '<tr>'
    \s*       '<th>H1</th>'
    \s*       '<th>H2</th>'
    \s*     '</tr>'
    \s*   '</thead>'
    \s*   '<tbody>'
    \s*     '<tr>'
    \s*       '<td><strong>col1</strong></td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*     '<tr>'
    \s*       '<td><em>col1</em></td>'
    \s*       '<td>col2</td>'
    \s*     '</tr>'
    \s*   '</tbody>'
    \s* '</table>'
    /, 'table with pod inside a cell';
