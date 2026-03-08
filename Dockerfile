# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o socks5-pool .

# Run stage
FROM alpine:3.19
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/socks5-pool .
EXPOSE 1080 8080
CMD ["./socks5-pool", 
     "-listen", "0.0.0.0:1080",           # SOCKS5 监听地址
     "-status", "0.0.0.0:8080",           # Web 仪表盘地址
     "-url", "https://socks5-proxy.github.io/",  # 代理列表源（最常改的变量！）
     "-scrape-interval", "20m",           # 代理池刷新间隔
     "-check-timeout", "10s",             # 健康检查超时
     "-max-concurrent", "20"]             # 最大并发检查数
