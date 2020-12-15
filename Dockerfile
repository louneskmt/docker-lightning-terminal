ARG VERSION=v0.3.3-alpha

FROM lightninglabs/lightning-terminal:$VERSION

COPY entrypoint.sh /bin/entrypoint
RUN chmod a+x /bin/entrypoint

USER 1000

EXPOSE 8443 10009 9735

ENTRYPOINT ["/bin/entrypoint"]
