requires 'Encode';
requires 'HTML::Parser';
requires 'Test::More';
requires 'Text::MeCab';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};
