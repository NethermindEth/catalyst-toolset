FROM rust:1.90 AS builder

# Set the working directory inside the container
WORKDIR /usr/src/build

# Copy the entire project into the container
COPY . .

# Set environment variables to handle cross-compilation issues
ENV RUST_MIN_STACK=16777216

# Build the project in release mode
RUN cargo build -p p2p-bootnode --release

# Use debian slim as the base image
FROM debian:bookworm-slim

# Copy the build artifact from the builder stage
COPY --from=builder /usr/src/build/target/release/p2p-bootnode /usr/local/bin/p2p-bootnode

# Expose the port that the server will run on
EXPOSE 9000
EXPOSE 8545

# Run the binary
# CMD in docker-compose
# CMD ["p2p-boot-node"]
