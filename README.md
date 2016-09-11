# NAME

Acme::Lou - Let's together with Lou Ohshiba 

# SYNOPSIS

    use utf8;
    use Acme::Lou qw/lou/;

    my $text = <<'...';
    祇園精舎の鐘の声、諸行無常の響きあり。
    沙羅双樹の花の色、盛者必衰の理を現す。
    奢れる人も久しからず、
    唯春の夜の夢のごとし。
    ...

    print lou($text);

    # 祇園テンプルのベルのボイス、諸行無常のエコーあり。
    # 沙羅双樹のフラワーのカラー、盛者必衰のリーズンをショーする。
    # プラウドすれるヒューマンも久しからず、
    # オンリースプリングのイーブニングのドリームのごとし。

# DESCRIPTION

Translate Japanese text into Lou Ohshiba (Japanese comedian) style. 

# METHODS

## $lou = Acme::Lou->new() 

Creates an Acme::Lou object.

## $lou->translate($text \[, \\%options \])

    $lou = Acme->Lou->new();
    $out = $lou->translate($text, { lou_rate => 50 });

Return translated unicode string.

_%options_:

- lou\_rate

    Percentage of translating. 100(default) means full, 0 means do nothing.

# EXPORTS

No exports by default.

## lou

    use Acme::Lou qw/lou/;

    print lou("人生には、大切にしなくてはいけない三つの袋があります。");
    # => ライフには、インポータントにしなくてはいけない三つのバッグがあります。

Shortcut to `Acme::Lou-`new->translate()>.

# OBSOLETED FUNCTION

To keep this module working, following functions are obsoleted. sorry.

- html input/output

# AUTHOR

Naoki Tomita <tomita@cpan.org>

# SEE ALSO

[http://lou5.jp/](http://lou5.jp/), [http://mecab.sourceforge.jp/](http://mecab.sourceforge.jp/)

Special thanks to Taku Kudo

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
