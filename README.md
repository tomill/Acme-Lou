# NAME

Acme::Lou - Let's together with Lou Ohshiba 

# SYNOPSIS

    use utf8;
    use Acme::Lou;
    

    my $lou = new Acme::Lou;
    

    my $text = "「美しい国、日本」";
    

    print $lou->translate($text); # 「ビューティフルな国、ジャパン」

    print $lou->translate($text, {
        lou_rate     =>  50,
        html_fx_rate => 100,
    })
    # 「美しい国、<FONT color=#003399>ジャパン</FONT>」

# DESCRIPTION

Mr. Lou Ohshiba is a Japanese comedian. This module translates 
text or HTML into his style. 

# METHODS

- $lou = Acme::Lou->new(\[ \\%options \])
- $lou = Acme::Lou->new(\[ %options \]) 

    Creates an Acme::Lou object.

    _%options_ can take...

    - mecab\_charset 

        Your MeCab dictionary charset. Default is `euc-jp`. If you compiled 
        mecab with `utf-8`,

            my $lou = new Acme::Lou( mecab_charset => 'utf-8' );

    - mecab\_option

        Optional. Arguments for [Text::MeCab](http://search.cpan.org/perldoc?Text::MeCab) instance.

            my $lou = new Acme::Lou({ 
                mecab_option => { dicdir => "/path/to/yourdicdir" },
            });

    - mecab

        You can set your own Text::MeCab instance, if you want. Optional. 

    - format
    - is\_html 
    - lou\_rate
    - html\_fx\_rate

        These are global options for `$lou->translate()` (See below).

        Defaults are 

            format       => '%s',
            is_html      => 0,
            lou_rate     => 100,
            html_fx_rate => 0,

- $lou->translate($text \[, \\%options \])

    Return translated text in Lou Ohshiba style. `translate()` expect 
    utf-8 byte or utf-8 flagged text, and it return utf-8 flaged text.

    _%options_: (overwrite global options)

    - format 

        Output format string for `sprintf`. Default is `%s`.
        It is taken as follows. 

            sprintf(C<format>, "translated word", "original word")

        e.g.
            

            Default:
            $lou->translate("考えておく");
            # シンクアバウトしておく
             

            Idea 1: <ruby> tag
            $lou->translate("考えておく", { 
                format => '<ruby><rb>%s</rb><rp>(</rp><rt>%s</rt><rp>)</rp></ruby>',
            });
            # <ruby><rb>シンクアバウトし</rb><rp>(</rp><rt>考え</rt><rp>)</rp></ruby>ておく
             

            Idea 2: for English study (?!)
            $lou->translate("考えておく", { 
                format => '%2$s[%1$s]', # require perl v5.8
            });
            # 考え[シンクアバウトし]ておく

        `format` option was added by version 0.03.

    - is\_html

        Optional. If $text is a HTML, you should set true. Acme::Lou makes 
        a fine job with HTML::Parser mode. Default is false. 

    - lou\_rate

        Set percentage of translating. 100 means full translating, 
        0 means do nothing.

    - html\_fx\_rate

        Set percentage of HTML style decoration. Default is 0. 
        When `html_fx_rate` is set, using HTML::Parser automatically.
        (don't need to set `is_html`)

    If using HTML::Parser, `translate()` skips the text in `<script>` 
    and `<style>` tag and attribute values.

    And, `html_fx_rate` skips the text in `<title>` tag.

        my $html = <<'HTML';
        <html>
        <head><title>新年のごあいさつ></title></head>
        <body>
        <img src="foo.jpg" alt="新年" />
        今年もよろしく
        お願いいたします。
        </body>
        </html>
        HTML
        ;
         

        print $lou->translate($html, {
            lou_rate => 100, # translate all words that Acme::Lou knows.
            html_fx_rate => 100, # and decorate all words.
        });
          

        # <html>
        # <head><title>ニューイヤーのごあいさつ</title></head>
        # <body>
        # <img src="foo.jpg" alt="新年" />
        # <FONT color=#0000ff size=5>ディスイヤー</FONT>もよろしく
        # <FONT color=#df0029 size=6><STRONG>プリーズ</STRONG></FONT>いたします
        # </body>
        # </html>

    HTML is not broken.

# AUTHOR

Naoki Tomita <tomita@cpan.org>

# SEE ALSO

[http://lou5.jp/](http://lou5.jp/), [http://mecab.sourceforge.jp/](http://mecab.sourceforge.jp/)

Special thanks to Taku Kudo

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
