FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/aspnet:8.0-noble AS final

ENV TZ=Asia/Tehran

# Install SQLite native library and file utility
USER root
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 file && rm -rf /var/lib/apt/lists/*

WORKDIR /app
EXPOSE 8080
USER app

# Declare build arguments
ARG TARGETARCH

# Copy the published output from the build stage (set by the GitHub Actions workflow)
# Use TARGETARCH to copy the correct binaries
COPY publish/linux-${TARGETARCH}/ .

RUN echo "Diagnostics before entrypoint:"
RUN echo "Listing /app/ contents:" && ls -lA /app/
RUN echo "Checking /app/MTWireGuard details:"
RUN if [ -f /app/MTWireGuard ]; then \
      echo "MTWireGuard FOUND in /app/"; \
      echo "Permissions:"; ls -l /app/MTWireGuard; \
      echo "Attempting file command:"; file /app/MTWireGuard || echo "'file' command not found or failed."; \
      echo "Attempting ldd command:"; ldd /app/MTWireGuard || echo "'ldd' command not found or failed on MTWireGuard."; \
    else \
      echo "MTWireGuard NOT FOUND in /app/"; \
    fi
RUN echo "Current directory: $(pwd)"
RUN echo "PATH variable: $PATH"

ENTRYPOINT ["./MTWireGuard"]
