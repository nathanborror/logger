[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# Logger

Logger lets you quickly send messages to yourself as a means of fast note taking. All messages you send to yourself show up chronologically. Tapping the spacebar before entering any text puts you in a search mode for easy filtering. Hashtags can be used to categorize notes. All data is stored on your device and not shared with the cloud.

[![image](https://github.com/nathanborror/logger/blob/master/static/2021-03-29%20Logger.png?raw=true)](https://github.com/nathanborror/logger/blob/master/static/2021-03-29%20Logger%20Spread.png?raw=true)

## Usage

To get things up an running _locally_ you'll need the latest version of [Go](https://golang.org/dl/). Run the following commands to get going:

1: Checkout and build:

    $ git clone git@github.com:nathanborror/logger.git
    $ cd logger
    $ go get
    $ make test
    $ make

2: Build Xcode project:

    $ open clients/Logger/Logger.xcodeproj
    <Build & Run>

## Tasks

- [x] Remove experimental state backend
- [x] Make hashtags tappable (moved to popover until I can devise a cleaner solution)
- [x] Implement search
- [ ] Make repository public
- [ ] Ship update to App Store

## Notes

- Go mobile doesn't appear to support modules which explains the `GO111MODULE=off` environment variable in the make command (ref: https://github.com/golang/go/issues/27234).

## Download Latest

[<img src="https://developer.apple.com/app-store/marketing/guidelines/images/badge-example-alternate_2x.png" width="160">](https://apps.apple.com/ca/app/logger-notes/id1364248334)
