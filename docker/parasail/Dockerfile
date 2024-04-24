FROM mambaorg/micromamba@sha256:9d09137c237a48c3166bd799107f938e15e9bd9400f5cc007af774e5fdcac7b3
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yml /tmp/env.yml
RUN micromamba install -y -n base -f /tmp/env.yml && \
    micromamba clean --all --yes
