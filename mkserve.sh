# https://hub.docker.com/r/squidfunk/mkdocs-material/

# Serve
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material

# Build
#docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material build