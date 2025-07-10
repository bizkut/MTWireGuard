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

# Diagnostic: Verify presence of libe_sqlite3.so from SQLitePCLRaw.bundle_e_sqlite3
RUN echo "Verifying presence of libe_sqlite3.so in /app:" && \
    if [ -f /app/libe_sqlite3.so ]; then \
      echo "libe_sqlite3.so FOUND in /app/"; \
      ls -l /app/libe_sqlite3.so; \
    else \
      echo "libe_sqlite3.so NOT FOUND in /app/"; \
    fi

# Attempt to make libe_sqlite3.so available as SQLite.Interop.dll
RUN if [ -f /app/libe_sqlite3.so ]; then \
      cp /app/libe_sqlite3.so /app/SQLite.Interop.dll && \
      echo "Copied /app/libe_sqlite3.so to /app/SQLite.Interop.dll" && \
      echo "Verifying SQLite.Interop.dll:" && \
      ls -l /app/SQLite.Interop.dll; \
    else \
      echo "Error: Cannot copy /app/libe_sqlite3.so because it was not found."; \
    fi

ENTRYPOINT ["./MTWireGuard"]
