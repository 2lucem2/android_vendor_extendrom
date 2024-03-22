############################################################################
#
# Copyright (C) 2020-2023 steadfasterX <steadfasterX@binbash.rocks>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
############################################################################

VENDOR_DIR := vendor/extendrom

ifeq ($(ENABLE_EXTENDROM), true)

##########################################
# boot debugger

ifeq ($(EXTENDROM_BOOT_DEBUG), true)

ifeq ($(call math_gt_or_eq,$(PLATFORM_VERSION),11),true)
BOARD_VENDOR_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug
else
BOARD_SEPOLICY_DIRS += $(VENDOR_DIR)/sepolicy/boot_debug
endif

PRODUCT_PACKAGES += \
	er-logcat

ifeq ($(call math_gt_or_eq,$(PLATFORM_SDK_VERSION),30), true)
PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_OUT_SYSTEM_EXT_ETC)/init/init.extendrom.rc
else
PRODUCT_COPY_FILES += \
    $(VENDOR_DIR)/config/init.er.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.extendrom.rc
endif # call math_gt_or_eq = true
endif # EXTENDROM_BOOT_DEBUG = true

# include package definitions generated by er.sh
$(call inherit-product-if-exists, vendor/extendrom/packages.mk)

endif # ENABLE_EXTENDROM = true
