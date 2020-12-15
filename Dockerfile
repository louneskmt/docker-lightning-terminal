ARG VERSION=v0.3.1-alpha

FROM lightninglabs/lightning-terminal:$VERSION

COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint

ENTRYPOINT ["/bin/entrypoint"]