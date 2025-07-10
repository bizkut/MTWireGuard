FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy-arm64v8 AS final

ENV TZ=Asia/Tehran

# Install SQLite native library (system level as a fallback)
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
EXPOSE 8080
USER app

# Declare build arguments
ARG TARGETARCH

# Copy the published output from the build stage (set by the GitHub Actions workflow)
# Use TARGETARCH to copy the correct binaries
COPY publish/linux-${TARGETARCH}/ .

# Diagnostic: Verify presence of SQLite.Interop.dll (expected from sqlite_interop_arm64)
RUN echo "Verifying presence of SQLite.Interop.dll in /app (from sqlite_interop_arm64):" && \
    if [ -f /app/SQLite.Interop.dll ]; then \
      echo "SQLite.Interop.dll FOUND in /app/"; \
      ls -l /app/SQLite.Interop.dll; \
      file /app/SQLite.Interop.dll || echo "'file' command not found or failed on SQLite.Interop.dll"; \
      ldd /app/SQLite.Interop.dll || echo "'ldd' command not found or failed on SQLite.Interop.dll"; \
    else \
      echo "SQLite.Interop.dll NOT FOUND in /app/"; \
    fi

ENTRYPOINT ["./MTWireGuard"]
