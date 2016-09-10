package Acme::Lou;
use strict;
our $VERSION = '0.033';

use utf8;
use Acme::Lou::Effect;
use Carp;
use DB_File;
use Encode;
use Text::MeCab;

sub new {
    my $class = shift;
    my $opt   = ref $_[0] eq 'HASH' ? shift : { @_ };
    
    my %self = (
        mecab_charset => 'euc-jp',
        mecab_option  => {},
        dbpath => do {
            my $file = $INC{ join '/', split '::', "$class.pm" };
            $file =~ s{\.pm$}{/lou-ja2kana.db};
            $file;
        },
        lou_rate     => 100,
        %$opt,
    );
    
    $self{dic} ||= do {
        tie(my %db, 'DB_File', $self{dbpath}, O_RDONLY)
          or croak "Can't open $self{dbpath}: $!";
        \%db;
    };
    
    $self{mecab} ||= new Text::MeCab($self{mecab_option});
     
    bless \%self, $class;
}

sub mecab {
    shift->{mecab};
}

sub dic {
    my ($self, $word) = @_;
    utf8::encode($word) if utf8::is_utf8($word);
    decode('utf8', $self->{dic}->{$word} || "");
}

sub translate {
    my ($self, $text, $opt) = @_;
    return "" unless $text;
    utf8::decode($text) unless utf8::is_utf8($text);
    
    $opt = {
        lou_rate     => $self->{lou_rate},
        use_emoji => $self->{use_emoji},
        %{ $opt || {} },
    };

    if (!$opt->{lou_rate}) {
        return $text;
    } else {
        return $self->lou($text, $opt);
    }
}

our %cform = (
    '名詞-*'                => '',
    '感動詞-*'              => '',
    '接続詞-*'              => '',
    '連体詞-*'              => '',
    '動詞-仮定形'           => 'すれ',
    '動詞-仮定縮約１'       => 'すれ',
    '動詞-基本形'           => 'する',
    '動詞-体言接続'         => 'する',
    '動詞-体言接続特殊２'   => 'す',
    '動詞-文語基本形'       => 'する',
    '動詞-未然レル接続'     => 'せ',
   #'動詞-未然形'           => '',
   #'動詞-未然特殊'         => '',
    '動詞-命令ｅ'           => '',
    '動詞-命令ｒｏ'         => '',
    '動詞-命令ｙｏ'         => '',
   #'動詞-連用タ接続'       => '',
    '形容詞-ガル接続'       => '',
    '動詞-連用形'           => 'し',
    '形容詞-仮定形'         => 'なら',
    '形容詞-仮定縮約１'     => 'なら',
    '形容詞-仮定縮約２'     => 'なら',
    '形容詞-基本形'         => 'な',
    '形容詞-体言接続'       => 'な',
    '形容詞-文語基本形'     => '',
    '形容詞-未然ウ接続'     => 'だろ',
    '形容詞-未然ヌ接続'     => 'らしから',
    '形容詞-命令ｅ'         => 'であれ',
    '形容詞-連用ゴザイ接続' => '',
    '形容詞-連用タ接続'     => 'だっ',
    '形容詞-連用テ接続'     => 'に',
);

sub lou {
    my ($self, $text, $opt) = @_;

    # tricks for mecab... Umm.. Do you have any good idea ?
    $text = "\n$text\n";
    $text =~ s/\r?\n/\r/g; # need \r
    $text =~ s/ /\x{25a1}/g; # white space to "tofu"
    
    $text = encode($self->{mecab_charset}, $text);
    my @out;
    my $node = $self->mecab->parse($text);
    while ($node) {
       
        my $n = $self->decode_node($node);
        $n->{to} = $self->dic($n->{original});
        $n->{class_type} = "$n->{class}-$n->{type}";
        $n->{cform} = $cform{ $n->{class_type} };
       
        if ($n->{to} =~ s/\s//g >= 2) {
            $n->{to} = "" if int(rand 3); # idiom in over 3 words.
        }
        if ($n->{class} =~ /接続詞|感動詞/) { # only "But" "Yes",...
            $n->{to} = "" if $n->{to} !~ /^[a-z]+$/i;
        }
       
        if ($n->{to} && defined $n->{cform} &&
            #length $n->{original} > 1 &&
            int(rand 100) < $opt->{lou_rate}
        ) {
            if ($n->{prev}{class} eq '接頭詞' &&
                $n->{prev}{original} =~ /^[ごお御]$/) {
                pop @out;
            }
            if ($n->{class_type} eq '形容詞-基本形' &&
                $n->{next}{class} =~ /助詞|記号/) {
                $n->{cform} = "";
            }
           
            $n->{to} .= $n->{cform};

            push @out, sprintf($opt->{format}, $n->{to}, $n->{surface});
        } else {
            push @out, $n->{surface};
        }
        $node = $node->next;
    }
    $text = join "", @out;
    $text =~ s/\r/\n/g;
    $text =~ s/\x{25a1}/ /g;
    $text;
}

sub decode_node {
    my ($self, $node) = @_;
    my $charset = $self->{mecab_charset};
    
    my $getf = sub {
        my $csv = shift;
        my %f;
        @f{qw( class class2 class3 class4 form type original yomi pron )}
            = split ",", $csv;
        return \%f;
    };
     
    my $n = $getf->(decode($charset, $node->feature));
    $n->{surface} = decode($charset, $node->surface);
    $n->{surface} = "" if !defined $n->{surface};
    
    for (qw( prev next )) {
        next unless $node->$_;
        $n->{$_} =  $getf->(decode($charset, $node->$_->feature));
        $n->{$_}{surface} = decode($charset, $node->$_->surface);
    }
    
    $n;
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
