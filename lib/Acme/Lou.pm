package Acme::Lou;
use 5.010001;
use strict;
use warnings;
use utf8;
our $VERSION = '0.033';

use Encode;
use File::ShareDir qw/dist_file/;
use Text::Mecabist;

sub new {
    my $class = shift;
    my $self = bless {
        mecab_option => {
            userdic => dist_file('Acme-Lou', Text::Mecabist->encoding->name .'.dic'),
        },
        lou_rate => 100,
        @_,
    }, $class;
}

sub translate {
    my ($self, $text, $opt) = @_;
    my $rate = $opt->{lou_rate} // $self->{lou_rate};
    
    my $parser = Text::Mecabist->new($self->{mecab_option});
    
    return $parser->parse($text, sub {
        my $node = shift;
        return if not $node->readable;
        
        my $word  = $node->extra1 or return; # ルー単語 found
        my $okuri = $node->extra2 // "";
        
        return if int(rand 100) > $rate;
        
        if ($node->prev and
            $node->prev->is('接頭詞') and
            $node->prev->lemma =~ /^[ごお御]$/) {
            $node->prev->skip(1);
        }
        
        if ($node->is('形容詞') and
            $node->is('基本形') and
            $node->next and $node->next->pos =~ /助詞|記号/) {
            $okuri = "";
        }

        $node->text($word . $okuri);
    })->stringify;
}

1;
__END__

=encoding utf-8

=head1 NAME

Acme::Lou - Let's together with Lou Ohshiba 

=head1 SYNOPSIS

    use utf8;
    use Acme::Lou;
    
    my $lou = new Acme::Lou;
    
    my $text = "「美しい国、日本」";
    
    print $lou->translate($text); # 「ビューティフルな国、ジャパン」

    print $lou->translate($text, {
        lou_rate     =>  50,
    })
    # 「美しい国、<FONT color=#003399>ジャパン</FONT>」

=head1 DESCRIPTION

Mr. Lou Ohshiba is a Japanese comedian. This module translates 
text into his style. 

=head1 METHODS

=over 4

=item $lou = Acme::Lou->new([ \%options ])

=item $lou = Acme::Lou->new([ %options ]) 

Creates an Acme::Lou object.

I<%options> can take...

=over 4 

=item * mecab_charset 

Your MeCab dictionary charset. Default is C<euc-jp>. If you compiled 
mecab with C<utf-8>,

    my $lou = new Acme::Lou( mecab_charset => 'utf-8' );

=item * mecab_option

Optional. Arguments for L<Text::MeCab> instance.

    my $lou = new Acme::Lou({ 
        mecab_option => { dicdir => "/path/to/yourdicdir" },
    });

=item * mecab

You can set your own Text::MeCab instance, if you want. Optional. 

=item * lou_rate

These are global options for C<< $lou->translate() >> (See below).

Defaults are 

    lou_rate     => 100,

=back

=item $lou->translate($text [, \%options ])

Return translated text in Lou Ohshiba style. C<translate()> expect 
utf-8 byte or utf-8 flagged text, and it return utf-8 flaged text.

I<%options>: (overwrite global options)

=over 4

=item * lou_rate

Set percentage of translating. 100 means full translating, 
0 means do nothing.

=back

=back

=head1 OBSOLETED FUNCTION

To keep this module working, following functions are obsoleted. sorry.

=over

=item * html input/output

=back

=head1 AUTHOR

Naoki Tomita E<lt>tomita@cpan.orgE<gt>

=head1 SEE ALSO

L<http://lou5.jp/>, L<http://mecab.sourceforge.jp/>

Special thanks to Taku Kudo

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
