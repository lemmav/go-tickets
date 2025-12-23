FROM golang:1.25 AS builder

WORKDIR /app

COPY board_service/ ./board_service/
COPY comment_service/ ./comment_service/
COPY ticket_service/ ./ticket_service/
COPY pgdb/ ./pgdb/
COPY proto/ ./proto/

RUN set -eux; \
    cd /app/board_service && go mod download && CGO_ENABLED=0 GOOS=linux go build -o /app/bin/board_service ./main.go; \
    cd /app/comment_service && go mod download && CGO_ENABLED=0 GOOS=linux go build -o /app/bin/comment_service ./main.go; \
    cd /app/ticket_service && go mod download && CGO_ENABLED=0 GOOS=linux go build -o /app/bin/ticket_service ./main.go

FROM alpine:latest
WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/bin/board_service .
COPY --from=builder /app/bin/comment_service .
COPY --from=builder /app/bin/ticket_service .

EXPOSE 50051 50052 50053
