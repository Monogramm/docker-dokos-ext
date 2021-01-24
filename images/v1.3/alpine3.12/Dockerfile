##
##    Docker image for Dokos.
##    Copyright (C) 2020  Monogramm
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU Affero General Public License as published
##    by the Free Software Foundation, either version 3 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU Affero General Public License for more details.
##
##    You should have received a copy of the GNU Affero General Public License
##    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
FROM monogramm/docker-dokos:v1.3-alpine3.12

ARG VERSION=v1.3.15

ENV TESSDATA_PREFIX=/home/$DODOCK_USER/tessdata \
    LANG=C.UTF-8 \
    LC_ALL=C

ARG ERPNEXT_AUTOINSTALL_VERSION=1.3.1
ARG RECOD_FRAPPE_DEVTOOLS=0.9.0
ARG ERPNEXT_OCR_VERSION=1.1.1
ARG RECOD_ERPNEXT_DESIGN=1.2.0
ARG FRAPPE_PWA=1.0.2
ARG ERPNEXT_FRANCE=master
ARG MAUTIC=master

# Build environment variables
ENV DODOCK_APP_PROTECTED='frappe erpnext erpnext_autoinstall'

USER root

# Setup Dokos additional plugins
RUN set -ex; \
    apk add --update \
        ghostscript \
        imagemagick \
        imagemagick-dev \
        tesseract-ocr \
        tesseract-ocr-dev \
        leptonica \
        pkgconfig \
    ; \
    rm -rf /var/cache/apk/*; \
    mkdir -p "$TESSDATA_PREFIX"; \
    chown -R "$DODOCK_USER:$DODOCK_USER" "$TESSDATA_PREFIX"; \
    sed -i \
        -e 's/rights="none" pattern="PDF"/rights="read" pattern="PDF"/g' \
        /etc/ImageMagick*/policy.xml \
    ;

USER dodock

# Setup Dokos additional plugins
RUN set -ex; \
    curl -sS -o "$TESSDATA_PREFIX/eng.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/eng.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/equ.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/equ.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/osd.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/osd.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/fra.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/fra.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/deu.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/deu.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/spa.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/spa.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/por.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/por.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/ita.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/ita.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/nld.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/nld.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/ara.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/ara.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/tur.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/tur.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/rus.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/rus.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/jpn.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/jpn.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/vie.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/vie.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/kor.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/kor.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/chi_sim.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/chi_sim.traineddata; \
    curl -sS -o "$TESSDATA_PREFIX/chi_tra.traineddata" https://raw.github.com/tesseract-ocr/tessdata/master/chi_tra.traineddata; \
    chmod -R 755 "$TESSDATA_PREFIX"; \
    tar zxf sites-base.tgz; \
    install_dokos_app erpnext_autoinstall 'https://github.com/Monogramm/erpnext_autoinstall' "${ERPNEXT_AUTOINSTALL_VERSION:-master}"; \
    install_dokos_app recod_frappe_devtools 'https://github.com/Monogramm/recod_frappe_devtools' "${RECOD_FRAPPE_DEVTOOLS:-master}"; \
    install_dokos_app erpnext_ocr 'https://github.com/Monogramm/erpnext_ocr' "${ERPNEXT_OCR_VERSION:-master}"; \
    install_dokos_app recod_erpnext_design 'https://github.com/Monogramm/recod_erpnext_design' "${RECOD_ERPNEXT_DESIGN:-master}"; \
    install_dokos_app frappe_pwa 'https://github.com/Monogramm/frappe_pwa' "${FRAPPE_PWA:-master}"; \
    install_dokos_app erpnext_france 'https://github.com/britlog/erpnext_france' "${ERPNEXT_FRANCE:-master}"; \
    install_dokos_app mautic 'https://github.com/dokos-io/mautic' "${MAUTIC:-master}"; \
    tar zcf sites-base.tgz sites; \
    rm -rf sites/* ~/.cache

VOLUME \
    /home/dodock/dodock-bench/apps/erpnext_autoinstall/erpnext_autoinstall/public \
    /home/dodock/dodock-bench/apps/erpnext_ocr/erpnext_ocr/public \
    /home/dodock/dodock-bench/apps/recod_erpnext_design/recod_erpnext_design/public \
    /home/dodock/dodock-bench/apps/frappe_pwa/frappe_pwa/public \
    /home/dodock/dodock-bench/apps/erpnext_france/erpnext_france/public \
    /home/dodock/dodock-bench/apps/mautic/mautic/public

ARG TAG
ARG VCS_REF
ARG BUILD_DATE

# Build environment variables
ENV DOCKER_TAG=${TAG} \
    DOCKER_VCS_REF=${VCS_REF} \
    DOCKER_BUILD_DATE=${BUILD_DATE}

# Container labels (http://label-schema.org/)
# Container annotations (https://github.com/opencontainers/image-spec)
LABEL maintainer="Monogramm maintainers <opensource at monogramm dot io>" \
      product="Dokos" \
      version=$VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Monogramm/docker-dokos" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Dokos" \
      org.label-schema.description="Open Source ERP built for the web" \
      org.label-schema.url="https://dokos.io/" \
      org.label-schema.vendor="Dokos" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/Monogramm/docker-dokos" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="Dokos" \
      org.opencontainers.image.description="Open Source ERP built for the web" \
      org.opencontainers.image.url="https://dokos.io/" \
      org.opencontainers.image.vendor="Dokos" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.authors="Monogramm maintainers <opensource at monogramm dot io>"
