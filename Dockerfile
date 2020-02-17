FROM golang:1.13.8 as builder

# Fetch and build static github-app-authenticate
RUN CGO_ENABLED=0 GOOS=linux go get -a -tags netgo -ldflags '-w' github.com/tcnksm/misc/cmd/github-app-authenticate

# Add tini here because chmod doesn't exist in the final container
# And kubernetes can't inject it by default
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini


FROM gcr.io/distroless/base:nonroot@sha256:2b177fbc9a31b85254d264e1fc9a65accc6636d6f1033631b9b086ee589d1fe2
COPY --from=builder /go/bin/github-app-authenticate /
COPY --from=builder /tini /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/github-app-authenticate"]
