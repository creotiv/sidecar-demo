FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o server cmd/server/main.go

FROM alpine:latest
# Install ca-certificates for HTTPS requests (if needed)
RUN apk --no-cache add ca-certificates
WORKDIR /app

# Create the logs directory
RUN mkdir -p /app/logs

# Copy the binary
COPY --from=builder /app/server .

# Make binary executable (just in case)
RUN chmod +x server

EXPOSE 8080

# Use environment variable for log path, with a default
ENV LOG_PATH=/app/logs/app.log

# Use full path to binary
CMD ["./server"]
