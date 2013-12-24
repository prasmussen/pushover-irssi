pushover-irssi
==============


## Overview
pushover-irssi is an extension to [irssi](http://www.irssi.org/) which sends
push notifications through [pushover.net](https://pushover.net/) to your
android/ios device when you receive a private message or is highlighted in a
channel. Notifications will only be sent when you are idling.


### Idle detection
The extension listens for key presses inside irssi and you need to avoid
pressing any keys for 5 minutes (configurable) to become idle.
Any pm or highlight received in this 5 minute period will be queued up and
sent when you reach the idle state. Pm's and highlights received when you are
idle will be sent within a minute. There is a timer that checks each minute
if you are in the idle state and sends out any queued up notifications.


## Requirements
- Account at [pushover.net](https://pushover.net/)
- LWP


## Installation

#### Install LWP on Ubuntu
    $ sudo apt-get install libwww-perl

#### Install pushover.pl
    $ cd ~/.irssi/scripts/
    $ wget https://raw.github.com/prasmussen/pushover-irssi/master/pushover.pl
    $ cd ~/.irssi/scripts/autorun/
    $ ln -s ../pushover.pl pushover.pl


## Configuration

#### Create pushover app
At [pushover.net](https://pushover.net/) create a new application called
irssi. The irssi app will get a unique API Key which is needed in the step
below. The User Key is also needed and can be found on the front page of
[pushover.net](https://pushover.net/).

#### Required irssi settings
- Load script `/script load pushover.pl`
- Set api key `/set pushover_api_key <api_key>`
- Set user key `/set pushover_user_key <user_key>`

#### Optional irssi settings
- Set idle timeout `/set pushover_idle_timeout <minutes>` (5 minutes by default)
- Enable notifications `/set pushover_enabled ON` (enabled by default)
- Disable notifications `/set pushover_enabled OFF`
