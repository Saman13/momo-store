FROM golang:1.20 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o app .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api

FROM alpine:3.18.4
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8081
ENTRYPOINT ["./main"]