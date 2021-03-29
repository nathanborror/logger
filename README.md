[![image](https://github.com/nathanborror/logger/blob/master/static/2021-02-19%20Logger.png?raw=true)](https://github.com/nathanborror/logger/blob/master/static/2021-02-19%20Logger%20Spread.png?raw=true)

# Logger

Logger lets you quickly send messages to yourself as a means of fast note taking. All messages you send to yourself show up chronologically. Tapping the spacebar before entering any text puts you in a search mode for easy filtering. Hashtags can be used to categorize notes. All data is stored on your device and not shared with the cloud.

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