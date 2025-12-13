ARG COMPOSER_IMAGE_VERSION=2.1.3
ARG PHPLINT_PACKAGE_VERSION=3.0.0
ARG PHP_VERSION=8.4

FROM composer:${COMPOSER_IMAGE_VERSION} AS build

# An ARG declared before a FROM is outside of a build stage, so it can’t be used in any
# instruction after a FROM. @see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHPLINT_PACKAGE_VERSION
ARG PHP_VERSION

RUN \
    set -xe && \
    composer --quiet global require overtrue/phplint:${PHPLINT_PACKAGE_VERSION}

FROM php:${PHP_VERSION}-cli-alpine

WORKDIR /workdir

COPY --from=build /tmp/vendor /root/.composer/vendor

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
