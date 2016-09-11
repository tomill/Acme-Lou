requires 'perl', '5.010001';

requires 'Encode';
requires 'File::ShareDir';
requires 'Text::Mecabist';

on test => sub {
    requires 'Test::More';
    requires 'Test::Base';
};
