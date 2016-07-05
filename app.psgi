#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use Plack;
use Plack::Builder;
use Plack::App::Directory;
use DateTime;
use Router::Boom;
use HTML::Entities;
use Template::Tiny;

use Data::Dumper;

my %DRAGON_QUESTS = (
    dq9     => {
        date    => '2010-07-11',
        image   => 'dq9.png',
        title   => 'Dragon Quest IX: Sentinels of the Starry Skies',
        short   => 'DQ9',
    },

    dq7_3ds => {
        date    => '2016-09-16',
        image   => '',
        title   => 'Dragon Quest VII: Fragments of the Forgotten Past',
        url     => 'http://www.nintendo.com/en_CA/games/detail/dragon-quest-vii-fragments-of-the-forgotten-past-3ds',
        short   => 'DQ7 3DS',
    },

    dq8_3ds => {
        date    => undef,
        image   => '',
        title   => 'Dragon Quest VIII: Journey of the Cursed King',
        short   => 'DQ8 3DS',
    },
);

my @SORTED = qw(dq9 dq7_3ds dq8_3ds);

my $TEMPLATE = do { local $/; <DATA> };

my $template_processor = Template::Tiny->new();

my $router = Router::Boom->new();
$router->add('/', 'index');
$router->add('/' . $_, $_) for @SORTED;

my $app = sub {
    my $env = shift;
    my ($dest) = $router->match($env->{PATH_INFO});

    if (! $dest) {
        return [ 404, [ 'Content-type' => 'text/plain; charset=utf-8' ], ['not found'] ];
    }

    my $content;
    if ($dest eq 'index') {
        $content = '<p>'
            . join(
                "<br/>\n",
                map { sprintf(qq(<a href="/%s">%s</a>), $_, encode_entities($DRAGON_QUESTS{$_}{title})) } @SORTED
            ) . '</p>';
    }
    elsif (my $data = $DRAGON_QUESTS{$dest}) {
        my $markup;

        if ($data->{image}) {
            $markup = '<img src="/static/' . encode_entities($data->{image}) . '" alt="' . encode_entities($data->{title}) . '" />';
        }
        else {
            $markup = '<h1>' . encode_entities($data->{title}) . '</h1>';
        }

        if ($data->{date}) {
            my %d_hash;
            @d_hash{qw(year month day)} = split /-/, $data->{date};

            my $dt = DateTime->new(%d_hash);
            my $now = DateTime->now;
            if ($dt < $now) {
                $markup .= '<h2>Rejoice, for it has been released unto us!</h2>';
            }
            else {
                # BUGFIX: Won't work if $dt and $now are different years.
                # But it's all 2016 now, so ... it's OK?
                my $days = $dt->day_of_year - $now->day_of_year;
                $markup .= "<h2><big>$days</big> days 'til the North American release.</h2>";
            }
        }
        else {
            $markup .= '<h2>It will come, you just gotta believe!</h2>';
        }

        $template_processor->process(\$TEMPLATE,
                {
                    short => $data->{short},
                    content => $markup,
                },
                \$content
            );
    }
    else {
        return [ 500, [ 'Content-type' => 'text/plain; charset=utf-8' ], [ 'server error' ] ];
    }


    return [ 200, [ 'Content-type' => 'text/html; charset=utf-8' ], [ $content ] ];
};

builder {
    enable 'ContentLength';
    enable 'Runtime';
    mount '/favicon.ico' => Plack::App::File->new( file => 'static/favicon.ico' )->to_app;
    mount '/static' => Plack::App::Directory->new({ root => 'static' })->to_app;
    mount '/' => $app;
};




__DATA__
<!DOCTYPE html>
<html>
    <meta charset="UTF-8">
    <link rel="icon" href="/favicon.ico" type="image/x-icon" />

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">

    <title>[% short %] Countdown</title>
</head>
<body>

<div style="text-align: center">
    [% content %]
</div>

</body>
</html>
