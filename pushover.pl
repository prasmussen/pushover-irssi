#!/usr/bin/env perl -w
use strict;
use Irssi;
use LWP::UserAgent;

my $VERSION = '1.00';
my %IRSSI = (
    authors => 'Petter Rasmussen',
    contact => 'nil',
    name => 'Pushover',
    description => "Sends push notifications through Pushover on highligts and pm's",
    license => 'MIT',
    url => 'https://github.com/prasmussen/pushover-irssi'
);

my @notifications;
my $last_activity = 0;

sub pushover_help() {
    Irssi::print('%G>>%n Pushover can be configured with these settings:');
    Irssi::print('%G>>%n pushover_enabled      : Enable push notifications');
    Irssi::print('%G>>%n pushover_api_key      : Application Token/Key');
    Irssi::print('%G>>%n pushover_user_key     : User Key');
    Irssi::print('%G>>%n pushover_idle_timeout : Idle timeout in minutes before sending notifications');
}

sub enqueue_notification($$) {
    my ($title, $msg) = @_;
    push(@notifications, {'title' => $title, 'msg' => $msg});
}

sub on_private_message($$$$) {
    my ($server, $data, $nick, $address) = @_;
    enqueue_notification($nick, $data);
}

sub on_message($$$) {
    my ($dst, $text, $stripped) = @_;

    if ($dst->{'level'} & MSGLEVEL_HILIGHT) {
        enqueue_notification($dst->{'target'}, $stripped);
    }
}

sub on_keypress() {
    @notifications = ();
    $last_activity = time();
}

sub check_notifications() {
    my $now = time();
    my $min_idle = Irssi::settings_get_int('pushover_idle_timeout') * 60;

    if (($now - $last_activity) < $min_idle) {
        return;
    }

    while (my $x = shift(@notifications)) {
        send_notification($x->{'title'}, $x->{'msg'});
    }
}

sub send_notification($$) {
    my ($title, $msg) = @_;

    if (!Irssi::settings_get_bool('pushover_enabled')) {
        return;
    }

    my $token = Irssi::settings_get_str('pushover_api_key');
    my $user = Irssi::settings_get_str('pushover_user_key');

    if ($token eq "" || $user eq "") {
        Irssi::print('%G>>%n Pushover missing API or User Key');
        return;
    }

    my $url = 'https://api.pushover.net/1/messages.json';
    my $res = LWP::UserAgent->new()->post($url, [
        token => $token,
        user => $user,
        title => $title,
        message => $msg
    ]);

    if (!$res->is_success) {
        Irssi::print('Failed to send notification: ' . $res->decoded_content);
    }
}


Irssi::settings_add_bool($IRSSI{'name'}, 'pushover_enabled', 1);
Irssi::settings_add_str($IRSSI{'name'}, 'pushover_api_key', '');
Irssi::settings_add_str($IRSSI{'name'}, 'pushover_user_key', '');
Irssi::settings_add_int($IRSSI{'name'}, 'pushover_idle_timeout', 5);
Irssi::command_bind('pushover', 'pushover_help');
Irssi::signal_add_last('message private', 'on_private_message');
Irssi::signal_add_last('print text', 'on_message');
Irssi::signal_add_last('gui key pressed', 'on_keypress');
Irssi::timeout_add(60000, 'check_notifications', undef);
Irssi::print('%G>>%n ' . $IRSSI{name} . ' ' . $VERSION . ' loaded (/pushover for help)');
