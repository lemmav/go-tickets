FROM golang:1.25 as builder

WORKDIR /app

COPY board_service/ ./board_service/
COPY comment_service/ ./comment_service/
COPY ticket_service/ ./ticket_service/

RUN set -eux; \
    cd /board_service && go mod download; \
    CGO_ENABLED=0 GOOS=linux go build -o /app/bin/board_service ./board_service/main.go; \
    cd /comment_service; \
    go mod download && CGO_ENABLED=0 GOOS=linux go build -o /app/bin/comment_service ./comment_service/main.go; \
    cd /ticket_service; \ go mod download && CGO_ENABLED=0 GOOS=linux go build -o /app/bin/ticket_service ./ticket_service/main.go

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/bin/board_service .
COPY --from=builder /app/bin/comment_service .
COPY --from=builder /app/bin/ticket_service .

EXPOSE 50051 50052 50053