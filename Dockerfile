ARG VERSION=v0.3.3-alpha

FROM lightninglabs/lightning-terminal:$VERSION

COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint

EXPOSE 8443

ENTRYPOINT ["/bin/entrypoint"]
