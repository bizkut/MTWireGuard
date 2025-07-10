FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/runtime-deps:8.0-noble-chiseled-extra AS final

ENV TZ=Asia/Tehran
WORKDIR /app
EXPOSE 8080
USER $APP_UID

# Declare build arguments
ARG TARGETARCH

# Copy the published output from the build stage (set by the GitHub Actions workflow)
# Use TARGETARCH to copy the correct binaries
COPY publish/linux-${TARGETARCH}/ .

ENTRYPOINT ["./MTWireGuard"]
