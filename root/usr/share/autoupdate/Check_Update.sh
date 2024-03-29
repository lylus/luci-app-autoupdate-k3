#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001

rm -f /tmp/cloud_*_version
if [ ! -f /bin/AutoUpdate.sh ];then
	echo "未检测到 /bin/AutoUpdate.sh" > /tmp/cloud_nightly_version
	echo "未检测到 /bin/AutoUpdate.sh" > /tmp/cloud_stable_version
	exit
fi
CURRENT_DEVICE="$(jsonfilter -e '@.model.id' < "/etc/board.json" | tr ',' '_')"
Github="$(awk 'NR==2' /etc/openwrt_info)"
[[ -z "${Github}" ]] && exit
Author="${Github##*com/}"
Github_Tags="https://api.github.com/repos/${Author}/releases/latest"
wget -q ${Github_Tags} -O - > /tmp/Github_Tags
GET_Nightly_Version="$(cat /tmp/Github_Tags | egrep -o "AutoBuild-phicomm-R[0-9]+.[0-9]+.[0-9]+.[0-9]+.[a-z]" | awk 'END {print}' | egrep -o 'R[0-9]+.[0-9]+.[0-9]+.[0-9]+')"
GET_Stable_Version="$(cat /tmp/Github_Tags | egrep -o "AutoBuild-phicomm-R[0-9]+.[0-9]+.[0-9]+.[0-9]+-Stable.[a-z]" | awk 'END {print}' | egrep -o 'R[0-9]+.[0-9]+.[0-9]+.[0-9]+-Stable')"
[[ -z "${GET_Stable_Version}" ]] && GET_Stable_Version="未知"
echo "${GET_Stable_Version}" > /tmp/cloud_stable_version
CURRENT_Version="$(awk 'NR==1' /etc/openwrt_info)"
if [ ! -z "${GET_Nightly_Version}" ];then
	if [[ "${CURRENT_Version}" == "${GET_Nightly_Version}" ]];then
		Checked_Type="已是最新"
	else
		Checked_Type="可更新"
	fi
	echo "${GET_Nightly_Version} [${Checked_Type}]" > /tmp/cloud_nightly_version
else
	echo "未知" > /tmp/cloud_nightly_version
fi
exit
