ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/julia/julia-base
ARG BASE_TAG=latest
#FROM registry1.dso.mil/ironbank/opensource/julia/julia-base as base
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ARG USER="joules"
ARG UID="1000"
ARG GID="100"

RUN dnf upgrade -y --nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN mkdir -p /tmp/julia/ /julia/
COPY julia-1.7.2-linux-x86_64.tar.gz /tmp/julia/
RUN tar xvf /tmp/julia/julia-1.7.2-linux-x86_64.tar.gz -C /julia

RUN mkdir -p /tmp/ai-packages/ 
WORKDIR /tmp/ai-packages
COPY *.tar.gz /tmp/ai-packages/
#RUN tar xvf /tmp/ai-packages/
RUN for f in /tmp/ai-packages/*.tar.gz; do tar xvf $f -C /tmp/ai-packages; done

USER 1001

ENV VIRTUAL_ENV=/julia/venv
RUN /julia/julia-1.7.2/bin/julia
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
USER root 

RUN useradd -m -s /bin/bash -N -u $UID -g $GID $USER   \
    && chmod -R 775 /home/joules

USER $UID
CMD ["/julia/julia-1.7.2/bin/julia"]

RUN julia -e "using Pkg; Pkg.add([ \
    \"Flux\", \
    \"Tensorflow\", \
    \"Clustering\", \
    \"ScikitLearn\", \
    \"Knet\", \
    \"LIBVSM\", \
    \"MLDatasets\", \
    \"JuliaParser\", \
    \"MLKernels\", \
    \"Kernels\", \
    \"FileIO\", \
    \"DiffResults\", \
    \"Interpolations\", \
    \"NLopt\" \
]); Pkg.update;"
                                                                 

HEALTHCHECK NONE
