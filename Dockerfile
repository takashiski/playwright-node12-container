# based https://github.com/microsoft/playwright/blob/master/utils/docker/Dockerfile.focal

FROM ubuntu:focal

# === INSTALL Node.js ===

# Install node14
RUN apt-get update && apt-get install -y curl && \
	curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
	apt-get install -y nodejs

# Upgrade to NPM7 (see https://github.com/microsoft/playwright/pull/8915)
RUN npm install -g npm@7

# Feature-parity with node.js base images.
RUN apt-get update && apt-get install -y --no-install-recommends git ssh && \
	npm install -g yarn

# Create the pwuser (we internally create a symlink for the pwuser and the root user)
RUN adduser pwuser

# Install Python 3.8

RUN apt-get update && apt-get install -y python3.8 python3-pip && \
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
	update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
	update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# === BAKE BROWSERS INTO IMAGE ===

ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 1. Add tip-of-tree Playwright package to install its browsers.
#    The package should be built beforehand from tip-of-tree Playwright.
# COPY ./playwright-core.tar.gz /tmp/playwright-core.tar.gz

# 2. Install playwright and then delete the installation.
#    Browsers will remain downloaded in `/ms-playwright`.
#    Note: make sure to set 777 to the registry so that any user can access
#    registry.
RUN mkdir /ms-playwright && \
	mkdir /tmp/pw && cd /tmp/pw && npm init -y && \
	npm install playwright && \
	# npm i /tmp/playwright-core.tar.gz && \
	npx playwright install && \
	DEBIAN_FRONTEND=noninteractive npx playwright install-deps && \
	# rm -rf /tmp/pw && rm /tmp/playwright-core.tar.gz && \
	chmod -R 777 /ms-playwright