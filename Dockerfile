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

RUN echo "Listing contents of /app/ after COPY:" && ls -lA /app/
RUN echo "Checking for SQLite.Interop.dll:"
RUN if [ -f /app/SQLite.Interop.dll ]; then \
      echo "SQLite.Interop.dll FOUND"; \
      echo "File type:"; file /app/SQLite.Interop.dll; \
      echo "Attempting to list dependencies (ldd will fail if it's not a dynamic executable or shared library, or if ldd is not available - output is best effort):"; ldd /app/SQLite.Interop.dll || echo "ldd command failed or SQLite.Interop.dll is not the expected type for ldd."; \
    else \
      echo "SQLite.Interop.dll NOT FOUND in /app/"; \
    fi
RUN echo "Also checking for common SQLitePCLRaw native library name (libe_sqlite3.so) just in case:"
RUN if [ -f /app/libe_sqlite3.so ]; then \
      echo "libe_sqlite3.so FOUND"; \
      echo "File type:"; file /app/libe_sqlite3.so; \
      echo "Attempting to list dependencies (ldd):"; ldd /app/libe_sqlite3.so || echo "ldd command failed or libe_sqlite3.so is not the expected type for ldd."; \
    else \
      echo "libe_sqlite3.so NOT FOUND in /app/"; \
    fi

ENTRYPOINT ["./MTWireGuard"]
