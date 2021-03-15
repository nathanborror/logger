main:
	@GO111MODULE=off gomobile bind -target=ios --tags "json1 fts5" -o clients/Logger/Frameworks/LoggerKit.framework github.com/nathanborror/logger/pkg/logger

test:
	@go test ./... --tags "json1 fts5"