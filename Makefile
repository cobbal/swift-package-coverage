#
#  SwiftPackageCoverage.swift
#  swift-package-coverage
#
#  Created by Braden Scothern on 6/8/2021.
#  Copyright © 2021 Braden Scothern. All rights reserved.
#

# IMPORTANT: Make sure to use actual tabs instead of spaces. Make doesn't like spaces.

EXECUTABLE := package-coverage
PRODUCT_NAME := swift-package-coverage
INSTALL_DIR := /usr/local/bin

# Override this on the command line if you need to
BUILD_FLAGS :=

.PHONY: build build-debug build-release
.PHONY: install install-debug install-beta install-debug-beta
.PHONY: uninstall uninstall-beta

default: build

# Build Commands
build: build-debug

build-debug: $(wildcard Sources/*/*.swift)
	swift build $(BUILD_FLAGS) --configuration debug

build-release: $(wildcard Sources/*/*.swift)
	swift build $(BUILD_FLAGS) --configuration release

# Install Commands
install: build-release
	cp .build/release/$(EXECUTABLE) $(INSTALL_DIR)/$(PRODUCT_NAME)
	touch -c $(INSTALL_DIR)/$(PRODUCT_NAME)

install-debug: build-debug
	cp .build/debug/$(EXECUTABLE) $(INSTALL_DIR)/$(PRODUCT_NAME)
	touch -c $(INSTALL_DIR)/$(PRODUCT_NAME)

install-beta: build-release
	cp .build/release/$(EXECUTABLE) $(INSTALL_DIR)/$(PRODUCT_NAME)-beta
	touch -c $(INSTALL_DIR)/$(PRODUCT_NAME)-beta

install-debug-beta: build-debug
	cp .build/debug/$(EXECUTABLE) $(INSTALL_DIR)/$(PRODUCT_NAME)-beta
	touch -c $(INSTALL_DIR)/$(PRODUCT_NAME)-beta

# Uninstall Commands
uninstall:
	rm -rf $(INSTALL_DIR)/$(PRODUCT_NAME)

uninstall-beta:
	rm -rf $(INSTALL_DIR)/$(PRODUCT_NAME)-beta
