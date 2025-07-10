FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/aspnet:8.0-noble AS final

ENV TZ=Asia/Tehran

# Install SQLite native library
USER root
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
EXPOSE 8080
USER app

# Declare build arguments
ARG TARGETARCH

# Copy the published output from the build stage (set by the GitHub Actions workflow)
# Use TARGETARCH to copy the correct binaries
COPY publish/linux-${TARGETARCH}/ .

ENTRYPOINT ["./MTWireGuard"]
