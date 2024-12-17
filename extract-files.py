#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

blob_fixups: blob_fixups_user_type = {
    'odm/bin/hw/vendor.oplus.hardware.biometrics.fingerprint@2.1-service': blob_fixup()
        .add_needed('libshims_fingerprint.oplus.so'),
    'odm/etc/vintf/manifest/manifest_oplus_fingerprint.xml': blob_fixup()
        .patch_file('blob-patches/manifest_oplus_fingerprint.patch'),
    ('odm/lib64/mediadrm/libwvdrmengine.so', 'odm/lib64/libwvhidl.so'): blob_fixup()
        .add_needed('libcrypto_shim.so'),
    'odm/etc/init/vendor.oplus.hardware.biometrics.fingerprint@2.1-service.rc': blob_fixup()
        .add_line_if_missing('task_profiles ProcessCapacityHigh MaxPerformance'),
    'odm/etc/dolby/multimedia_dolby_dax_default.xml': blob_fixup()
        .regex_replace('(volume-leveler-enable value="false"', '\\1=true'),
    'product/etc/sysconfig/com.android.hotwordenrollment.common.util.xml': blob_fixup()
        .regex_replace('/my_product', '/product'),
    'system_ext/lib/libwfdservice.so': blob_fixup()
        .replace_needed('android.media.audio.common.types-V2-cpp.so', 'android.media.audio.common.types-V3-cpp.so'),
    'system_ext/lib64/libwfdnative.so': blob_fixup()
        .replace_needed('android.hidl.base@1.0.so', 'libhidlbase.so'),
    'vendor/etc/libnfc-nci.conf': blob_fixup()
        .regex_replace('NFC_DEBUG_ENABLED=1', 'NFC_DEBUG_ENABLED=0'),
    'vendor/etc/libnfc-nxp.conf': blob_fixup()
        .regex_replace('(NXPLOG_.*_LOGLEVEL)=0x03', '\\1=0x02')
        .regex_replace('NFC_DEBUG_ENABLED=1', 'NFC_DEBUG_ENABLED=0'),
    'vendor/lib64/hw/com.qti.chi.override.so': blob_fixup()
        .add_needed('libcamera_metadata_shim.so')
        .binary_regex_replace(b'com.oem.autotest', b'\x00om.oem.autotest'),
    'vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so': blob_fixup()
        .sig_replace('23 0A 00 94', '1F 20 03 D5'),
    'vendor/lib64/hw/camera.qcom.so': blob_fixup()
        .add_needed('libcamera_metadata_shim.so'),
    'vendor/lib/libgui1_vendor.so': blob_fixup()
        .replace_needed('libui.so', 'libui-v30.so'),
        'odm/lib/libdlbdsservice_v3_6.so|odm/lib/libstagefright_soft_ddpdec.so|odm/lib/libstagefrightdolby.so|odm/lib64/libdlbdsservice_v3_6.so': blob_fixup()
        .replace_needed('libstagefright_foundation.so', 'libstagefright_foundation-v33.so'),    
}  # fmt: skip

module = ExtractUtilsModule(
    'spartan',
    'realme',
    blob_fixups=blob_fixups,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
