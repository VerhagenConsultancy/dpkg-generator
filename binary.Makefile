BUILD_DIR?=$(CURDIR)/build
PACKAGE_DIR?=$(CURDIR)/package
DEBIAN_ARCHIVE?=$(CURDIR)/DEBIAN.tar.xz
SOURCE_ARCHIVE_NAME?=SOURCE.orig.tar.xz
SOURCE_ARCHIVE?=$(CURDIR)/$(SOURCE_ARCHIVE)

DEBIAN_FOLDER?=$(CURDIR)/debian
SOURCE_FILES?=meson.build
CHANGES_FILE:=*.changes
EXTRACT_DIR:=$(BUILD_DIR)/build

default: all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(EXTRACT_DIR):
	mkdir -p $(EXTRACT_DIR)

$(PACKAGE_DIR):
	mkdir -p $(PACKAGE_DIR)

$(BUILD_DIR)/debian.tar.xz: $(BUILD_DIR) $(DEBIAN_ARCHIVE)
	cp --reflink=auto $(DEBIAN_ARCHIVE) $@

$(BUILD_DIR)/$(SOURCE_ARCHIVE_NAME): $(BUILD_DIR) $(SOURCE_ARCHIVE)
	cp --reflink=auto $(SOURCE_ARCHIVE) $@

$(EXTRACT_DIR)/$(DEBIAN_FOLDER):: $(BUILD_DIR)/debian.tar.xz $(EXTRACT_DIR)
	tar -C $(EXTRACT_DIR) -xf $(BUILD_DIR)/debian.tar.xz

$(EXTRACT_DIR)/$(SOURCE_FILES):: $(BUILD_DIR)/$(SOURCE_ARCHIVE_NAME) $(EXTRACT_DIR)
	tar -C $(EXTRACT_DIR) -xf $(BUILD_DIR)/$(SOURCE_ARCHIVE_NAME)

$(BUILD_DIR)/$(CHANGES_FILE):: $(EXTRACT_DIR)/$(DEBIAN_FOLDER) $(EXTRACT_DIR)/$(SOURCE_FILES)
	cd $(EXTRACT_DIR) && dpkg-buildpackage -jauto

build: $(BUILD_DIR)/$(CHANGES_FILE)
	mkdir -p $(PACKAGE_DIR)

	cd $(BUILD_DIR) && cp --reflink=auto $$(sed -n '/Files:/,$$p' $(DSC_FILE) | grep -E "\.dsc$$|\.tar.xz$$|\.tar.gz$$" | sed 's/.* //' | xargs) $(PACKAGE_DIR)/
	cp --reflink=auto $(BUILD_DIR)/$(DSC_FILE) $(PACKAGE_DIR)/

	cd $(BUILD_DIR) && cp --reflink=auto $$(sed -n '/Files:/,$$p' $(CHANGES_FILE) | grep -E "\.tar.gz$$|\.deb$$|\.ddeb$$|\.buildinfo$$" | sed 's/.* //' | xargs) $(PACKAGE_DIR)/
	cp --reflink=auto $(BUILD_DIR)/$(CHANGES_FILE) $(PACKAGE_DIR)/

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PACKAGE_DIR)

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: build
.PHONY: build clean list all
