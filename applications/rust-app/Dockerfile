FROM rust:1.75-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache musl-dev

# Copy manifest files
COPY Cargo.toml ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies
RUN cargo build --release
RUN rm -rf src

# Copy actual source code
COPY src ./src

# Build the application
RUN touch src/main.rs && cargo build --release

# Final stage
FROM alpine:latest

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/rust-logging-app .

# Set environment variables
ENV APP_NAME=rust-app
ENV ENVIRONMENT=development

# Run the application
CMD ["./rust-logging-app"]
