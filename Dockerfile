FROM golang:1.25.3-bookworm as builder

RUN apt update
RUN apt install git -y

WORKDIR /appbuild/yagpdb
COPY yagpdb/. .
RUN go mod download

WORKDIR /appbuild/yagpdb/cmd/yagpdb
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build 

FROM alpine:latest

# run the bot as user "yagpdbbot" (group yagpdbbot, UID 1000, GID 1000)
# made username "yagpdbbot" to avoid the ambiguous and
#   hard to read "/home/yagpdb/yagpdb" situation
WORKDIR /home/container
EXPOSE 5000 5001

# Compatibility fix is now in the docker-entrypoint.sh

# Directories have been contsrusted in Pipeline
COPY --from=builder --chown=container:container /appbuild/yagpdb/cmd/yagpdb/yagpdb /home/yagpdb
COPY --chown=container:container /docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Create normal user yagpdbbot
# Note "system user" is not root, search keyword "linux system user"
RUN apk --no-cache add ca-certificates ffmpeg tzdata; \
  addgroup --system --gid 1000 container; \
  adduser --disabled-password --system --home /home/container \
    --ingroup container --uid 1000 container; \
  chmod 0755 /usr/local/bin/docker-entrypoint.sh

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
