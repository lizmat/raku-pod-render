#!/usr/bin/env perl6
use v6.*;
use Test;

use Pod::To::HTML;
my $rv;
my $processor;
my $pc = 0;

plan 10;

=begin pod
    Some pod
=end pod

lives-ok { $rv = Pod::To::HTML.render( $=pod[$pc] ) }, 'captures Pod into HTML';

like $rv, / .*? '<html' .*? '>' .*? '<body' .*? '>' .*? 'Some pod' .*? '</body>' .*? '</html>' /, 'got consistent HTML';

lives-ok { $processor = Pod::To::HTML.processor }, 'returns a renderer OK';
like $processor.WHAT.perl , /ProcessedPod/ , 'correct return type';
$processor.process-pod( $=pod[$pc++] );
like $processor.source-wrap
        .subst(/ \s+ /, ' ', :g),
        / .*? '<html' .*? '>' .*? '<body' .*? '>' .*? 'Some pod' .*? '</body>' .*? '</html>' /, 'works like render';
$rv = $processor.body-only
        .subst(/ \s+ /, ' ', :g);
like $rv,
        / '<section' .*? '>' .*? 'Some pod' .*? '</section>' /, 'html but no file wrapping';
unlike $rv,
        / .*? '<html' .*? '>' .*? '<body' .*? '>' .*? '</body>' .*? '</html>' /, 'confirm there is not html wrapping';

my $fn = 't/000-test-output';
"$fn\.html".IO.unlink if "$fn\.html".IO ~~ :e;
"$fn\.md".IO.unlink if "$fn\.md".IO ~~ :e;

$processor.file-wrap( :filename($fn) );
ok "$fn\.html".IO ~~ :f, 'file is created with default extension';

$processor.file-wrap( :filename($fn), :ext<md> );

ok "$fn\.md".IO ~~ :f, 'file with new extension';
"$fn\.html".IO.unlink if "$fn\.html".IO ~~ :e;
"$fn\.md".IO.unlink if "$fn\.md".IO ~~ :e;

=begin pod
    Another fascinating mess
=end pod

$processor.process-pod( $=pod[1] );
$rv = $processor.body-only;

like $rv,
        / '<section' .*? '>' .*? 'Another fascinating mess' .*? '</section>' /, 'latest snippit only';

done-testing;