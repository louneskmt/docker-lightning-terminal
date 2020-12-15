ARG VERSION=v0.3.3-alpha

FROM lightninglabs/lightning-terminal:$VERSION

ENTRYPOINT ["/bin/entrypoint"]
