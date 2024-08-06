#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=spartan
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        odm/bin/hw/vendor.oplus.hardware.biometrics.fingerprint@2.1-service)
            grep -q libshims_fingerprint.oplus.so "${2}" || "${PATCHELF}" --add-needed libshims_fingerprint.oplus.so "${2}"
            ;;
        odm/etc/init/wlchgmonitor.rc)
            sed -i "/disabled/d;/seclabel/d" "${2}"
            ;;
        odm/etc/vintf/manifest/manifest_oplus_fingerprint.xml)
            sed -ni "/android.hardware.biometrics.fingerprint/{x;s/hal format/hal override=\"true\" format/;x};x;1!p;\${x;p}" "${2}"
            ;;
        odm/lib64/libpwirissoft.so)
            "${SIGSCAN}" -p "72 1F 00 94" -P "1F 20 03 D5" -f "${2}"
            ;;
        product/app/PowerOffAlarm/PowerOffAlarm.apk)
            apktool_patch "${2}" "${MY_DIR}/blob-patches/PowerOffAlarm.patch" -s
            ;;
        product/etc/sysconfig/com.android.hotwordenrollment.common.util.xml)
            sed -i "s/\/my_product/\/product/" "${2}"
            ;;
        system_ext/lib64/libwfdnative.so)
            sed -i "s/android.hidl.base@1.0.so/libhidlbase.so\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00/" "${2}"
            ;;
        vendor/etc/libnfc-nxp.conf)
            sed -i "s/^NXP_RF_CONF_BLK_9/#NXP_RF_CONF_BLK_9/" "${2}"
            sed -i "s/^NXP_RF_CONF_BLK_10/#NXP_RF_CONF_BLK_10/" "${2}"
            ;;
        vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so)
            "${SIGSCAN}" -p "AF 0B 00 94" -P "1F 20 03 D5" -f "${2}"
            ;;
        vendor/lib64/hw/com.qti.chi.override.so)
            grep -q libcamera_metadata_shim.so "${2}" || "${PATCHELF}" --add-needed libcamera_metadata_shim.so "${2}"
            sed -i "s/com.oem.autotest/\x00om.oem.autotest/" "${2}"
            ;;
        vendor/lib64/hw/camera.qcom.so)
            grep -q libcamera_metadata_shim.so "${2}" || "${PATCHELF}" --add-needed libcamera_metadata_shim.so "${2}"
            ;;
        vendor/lib/libgui1_vendor.so)
            "${PATCHELF}" --replace-needed "libui.so" "libui-v30.so" "${2}"
            ;;
        odm/lib64/libwvhidl.so | odm/lib64/mediadrm/libwvdrmengine.so | vendor/bin/sensors.qti | vendor/lib64/libsensorcal.so | vendor/lib64/libssc.so | vendor/lib64/sensors.ssc.so | vendor/lib64/libsnsdiaglog.so | vendor/lib64/libsnsapi.so | odm/lib64/libdmtpclient.so | odm/lib64/lib-virtual-modem-protos.so | odm/lib64/libdmtp-protos-lite.so | odm/lib64/libdmtp.so | odm/lib64/liboplus_service.so)
            "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite-3.9.1.so" "libprotobuf-cpp-full-3.9.1.so" "${2}"
            ;;
        vendor/lib/libstagefright_soft_ac4dec.so | vendor/lib/libstagefright_soft_ddpdec.so | vendor/lib/libstagefrightdolby.so | vendor/lib64/libdlbdsservice.so | vendor/lib64/libstagefright_soft_ac4dec.so | vendor/lib64/libstagefright_soft_ddpdec.so | vendor/lib64/libstagefrightdolby.so)
            grep -q "libstagefright_foundation-v33.so" "${2}" || "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib/libstagefright_soft_ac4dec.so | vendor/lib/libstagefright_soft_ddpdec.so | vendor/lib/libstagefright_soft_qtiflacdec.so | vendor/lib/libstagefrightdolby.so | vendor/lib64/libdlbdsservice.so | vendor/lib64/libstagefright_soft_ac4dec.so | vendor/lib64/libstagefright_soft_ddpdec.so | vendor/lib64/libstagefrightdolby.so | odm/lib/libdlbdsservice_v3_6.so | odm/lib/libstagefright_soft_ddpdec.so | odm/lib/libstagefrightdolby.so | odm/lib64/libdlbdsservice_v3_6.so)
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            :;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
