################################################################################
#
# rte-control
#
################################################################################

RTE_CONTROL_VERSION = 1.0
RTE_CONTROL_SITE = $(TOPDIR)/../rte-control
RTE_CONTROL_SITE_METHOD = local
RTE_CONTROL_LICENSE = GPL-2.0+
RTE_CONTROL_LICENSE_FILES = COPYING
RTE_CONTROL_DEPENDENCIES = libiio mongoose

define RTE_CONTROL_COPY_LICENSE
	$(INSTALL) -D -m 0644 $(RTE_CONTROL_PKGDIR)/COPYING $(@D)/COPYING
endef
RTE_CONTROL_POST_RSYNC_HOOKS += RTE_CONTROL_COPY_LICENSE

define RTE_CONTROL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) clean
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" AR="$(TARGET_AR)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) -Iinclude -I$(STAGING_DIR)/usr/include" \
		CFLAGS="$(TARGET_CFLAGS) -std=c11 -Wall -Wextra -Werror -Wformat=2 -Wshadow" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		IIO_CFLAGS="-I$(STAGING_DIR)/usr/include" \
		IIO_LIBS="-L$(STAGING_DIR)/usr/lib -liio" \
		MONGOOSE_CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
		MONGOOSE_SOURCE="$(MONGOOSE_DIR)/mongoose.c" \
		WITH_HTTP=1 all
endef

define RTE_CONTROL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/rte-httpd \
		$(TARGET_DIR)/usr/sbin/rte-httpd
	$(INSTALL) -D -m 0755 $(@D)/build/rte-regtool \
		$(TARGET_DIR)/usr/bin/rte-regtool
	test -s $(@D)/www/index.html
	test -s $(@D)/www/app.css
	test -s $(@D)/www/app.js
	$(RM) -r $(TARGET_DIR)/usr/share/rte-control/www
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/rte-control/www
	$(INSTALL) -m 0644 $(@D)/www/index.html \
		$(TARGET_DIR)/usr/share/rte-control/www/index.html
	$(INSTALL) -m 0644 $(@D)/www/app.css \
		$(TARGET_DIR)/usr/share/rte-control/www/app.css
	$(INSTALL) -m 0644 $(@D)/www/app.js \
		$(TARGET_DIR)/usr/share/rte-control/www/app.js
endef

define RTE_CONTROL_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(RTE_CONTROL_PKGDIR)/S23udc-rte \
		$(TARGET_DIR)/etc/init.d/S23udc
	$(INSTALL) -D -m 0755 $(RTE_CONTROL_PKGDIR)/S60rte-httpd \
		$(TARGET_DIR)/etc/init.d/S60rte-httpd
	$(INSTALL) -D -m 0644 $(RTE_CONTROL_PKGDIR)/rte-httpd.conf \
		$(TARGET_DIR)/etc/default/rte-httpd
endef

$(eval $(generic-package))
