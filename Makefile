main:
	@GO111MODULE=auto gomobile bind -target=ios --tags "json1 fts5" -o clients/Logger/Frameworks/LoggerKit.framework github.com/nathanborror/logger/pkg/logger

test:
	@GO111MODULE=auto go test ./... --tags "json1 fts5"