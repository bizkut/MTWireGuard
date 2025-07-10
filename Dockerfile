FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy-arm64v8 AS final

ENV TZ=Asia/Tehran

# Install SQLite native library, file utility, and libc6
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends --reinstall libc6 file libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/*

# Immediate check after apt-get
RUN echo "Post apt-get: Checking for ELF interpreter /lib/ld-linux-aarch64.so.1:" && \
    if [ -f /lib/ld-linux-aarch64.so.1 ]; then \
      echo "POST APT-GET: Interpreter /lib/ld-linux-aarch64.so.1 FOUND"; \
      ls -l /lib/ld-linux-aarch64.so.1; \
      file /lib/ld-linux-aarch64.so.1; \
    else \
      echo "POST APT-GET: Interpreter /lib/ld-linux-aarch64.so.1 NOT FOUND"; \
    fi

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

RUN echo "Checking for ELF interpreter /lib/ld-linux-aarch64.so.1:"
RUN if [ -f /lib/ld-linux-aarch64.so.1 ]; then \
      echo "Interpreter /lib/ld-linux-aarch64.so.1 FOUND"; \
      ls -l /lib/ld-linux-aarch64.so.1; \
      echo "File type of interpreter:"; file /lib/ld-linux-aarch64.so.1; \
      echo "ldd on interpreter itself (output might be verbose or indicate it's not directly executable with ldd):"; ldd /lib/ld-linux-aarch64.so.1 || echo "ldd failed or not applicable for interpreter."; \
    else \
      echo "Interpreter /lib/ld-linux-aarch64.so.1 NOT FOUND"; \
    fi

ENTRYPOINT ["./MTWireGuard"]
