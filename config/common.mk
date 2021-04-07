# Copyright (C) 2019 KangOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include vendor/kangos/config/fingerprint.mk
include vendor/kangos/config/version.mk
include vendor/themes/common.mk

ifeq ($(TARGET_OPLAUNCHER), true)
include vendor/oplauncher/OPLauncher.mk
endif

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/kangos/overlay
DEVICE_PACKAGE_OVERLAYS += \
    vendor/kangos/overlay/common

ifeq ($(USE_GAPPS), true)
$(call inherit-product, vendor/gapps/gapps.mk)
endif

ifeq ($(PRODUCT_USES_QCOM_HARDWARE), true)
include vendor/kangos/build/core/qcom_target.mk
endif

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

ifeq ($(TARGET_INCLUDE_OP_FILE_MANAGER), true)
include vendor/opfilemanager/config.mk
endif

# Blur
PRODUCT_PRODUCT_PROPERTIES += \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.supports_background_blur=1

ifeq ($(TARGET_USES_BLUR), true)
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.sf.disable_blurs=0
else
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.sf.disable_blurs=1
endif

# Gboard
PRODUCT_PRODUCT_PROPERTIES += \
    ro.com.google.ime.kb_pad_port_b=1

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    persist.sys.disable_rescue=true

# Backup Tool
ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_COPY_FILES += \
    vendor/kangos/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/kangos/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/kangos/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
endif

# Flipendo
PRODUCT_COPY_FILES += \
    vendor/kangos/config/permissions/pixel_experience_2020.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/pixel_experience_2020.xml \
    vendor/kangos/config/permissions/privapp-permissions-elgoog.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-elgoog.xml

# IORap app launch prefetching using Perfetto traces and madvise
PRODUCT_PRODUCT_PROPERTIES += \
    ro.iorapd.enable=true

# KangOS-specific
PRODUCT_COPY_FILES += \
    vendor/kangos/prebuilt/common/bin/backuptool.sh:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.sh \
    vendor/kangos/prebuilt/common/bin/backuptool.functions:$(TARGET_COPY_OUT_SYSTEM)/install/bin/backuptool.functions \
    vendor/kangos/prebuilt/common/bin/50-cm.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-cm.sh

# Copy all custom init rc files
$(foreach f,$(wildcard vendor/kangos/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# system mount
PRODUCT_COPY_FILES += \
    vendor/kangos/prebuilt/common/bin/system-mount.sh:$(TARGET_COPY_OUT_SYSTEM)/install/bin/system-mount.sh

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=log

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Packages
include vendor/kangos/config/packages.mk

# Props
include vendor/kangos/config/props.mk

# RevengeUI
include vendor/revengeui/config.mk

# Sensitive Phone Numbers list
PRODUCT_COPY_FILES += \
    vendor/kangos/prebuilt/common/etc/sensitive_pn.xml:system/etc/sensitive_pn.xml

#Safetynet
TARGET_FORCE_BUILD_FINGERPRINT := google/redfin/redfin:11/RQ2A.210405.005/7181113:user/release-keys

# Priv-app permissions
ifeq ($(KANGOS_BUILDTYPE),OFFICIAL)
PRODUCT_COPY_FILES += \
    vendor/kangos/config/permissions/com.kangos.ota.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.kangos.ota.xml
endif

PRODUCT_COPY_FILES += \
    vendor/kangos/config/permissions/com.android.screenshot.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/com.android.screenshot.xml \
    vendor/kangos/config/permissions/privapp-permissions-livedisplay-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-livedisplay-product.xml \
    vendor/kangos/config/permissions/privapp-permissions-kangos-system.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-kangos-system.xml \
    vendor/kangos/config/permissions/privapp-permissions-kangos-product.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-kangos-product.xml

# Hidden API whitelist
PRODUCT_COPY_FILES += \
    vendor/kangos/config/sysconfig/kangos-hiddenapi-package-whitelist.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/kangos-hiddenapi-package-whitelist.xml

# Face Unlock
TARGET_FACE_UNLOCK_SUPPORTED ?= true
ifeq ($(TARGET_FACE_UNLOCK_SUPPORTED),true)
PRODUCT_PACKAGES += \
    FaceUnlockService
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.face_unlock_service.enabled=$(TARGET_FACE_UNLOCK_SUPPORTED)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.biometrics.face.xml
endif

# Fonts
include vendor/kangos/fonts.mk

ifneq ($(filter blueline crosshatch,$(TARGET_DEVICE)),)
ifneq ($(TARGET_BUILD_VARIANT),user)
# Ignore neverallows to allow Smart Charging sepolicies
SELINUX_IGNORE_NEVERALLOWS := true

# Inherit from our vendor sepolicy config
$(call inherit-product, vendor/kangos/configs/vendor_sepolicy.mk)

# Include Smart Charging overlays
DEVICE_PACKAGE_OVERLAYS += \
    vendor/kangos/overlay-smartcharging
endif
endif
