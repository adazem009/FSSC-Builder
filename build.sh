#!/bin/bash

# --- FSSC Builder ---
# 2020 - adazem009
#
# Functions
abortfb()
{
	echo -e "[ ${RED}FAIL${NC} ] $1"
	exit $2
}
printfb_info()
{
	echo -e "[ ${YELLOW}INFO${NC} ] $1"
}
success()
{
	echo -e "[ ${GREEN}OK${NC} ] $1"
}
setup_files()
{
	echo
	oldcd="$(pwd)"
	cd "${PartitionContent[$((i2-1))]}"
	dirs=()
	while IFS= read -r line; do
  		dirs+=( "$line" )
	done < <( find . -type d -print )
	echo "${dirs[@]}"
	cd="/"
	echo
	local i4=0
	while ((i4 < ${#dirs[@]})); do
		i4="$(($i4+1))"
		partfiles "${dirs[$((i4-1))]}"
		cd="${dirs[$((i4-1))]:1}"
		if [[ "${dirs[$((i4-1))]}" = "." ]]; then
			cd="/"
		fi
		FSSC[${#FSSC[@]}]="c$cd"
		i5=0
		while ((i5 < ${#partfiles[@]})); do
			i5="$(($i5+1))"
			if [ -d "${partfiles[$((i5-1))]}" ]; then
				temp0='$'
				FSSC[${#FSSC[@]}]="${temp0}folder;${partfiles[$((i5-1))]};;"
			else
				list=()
				IFS=$'\r\n' GLOBIGNORE='*' command eval  'list=($(cat "${dirs[$((i4-1))]}/${partfiles[$((i5-1))]}"))'
				echo "Adding file ${dirs[$((i4-1))]}/${partfiles[$((i5-1))]}"
				encode
				FSSC[${#FSSC[@]}]="${temp0}file;${partfiles[$((i5-1))]};${var};"
			fi
		done
	done
}
encode()
{
	echo "Encoding... 0%"
	temp="${list[*]}"
	tempi=0
	var=""
	item=0
	while ((item < ${#list[@]})); do
		item="$(($item+1))"
		letter=0
		tempi1=0
		while ((tempi1 < ${#list[$((item-1))]})); do
			tempi1="$(($tempi1+1))"
			tempi="$(($tempi+1))"
			letter="$(($letter+1))"
			symbol=1
			until [[ "${characters:$((symbol-1)):1}" = "${list[$((item-1))]:$((letter-1)):1}" ]] || ((symbol > ${#characters})); do
				symbol="$(($symbol+1))"
			done
			if ((symbol <= ${#characters})); then
				if ((${#symbol} < 2)); then
					symbol="0${symbol}"
				fi
				if [[ "${list[$((item-1))]:$((letter-1)):1}" = ' ' ]]; then
					symbol=95
				fi
				var="${var}${symbol:0:1}${symbol:1:1}"
			fi
			echo -e "\e[1A\e[KEncoding... $(($((tempi*100))/${#temp}))%"
		done
		tempi1="$(($tempi1+1))"
		var="${var}00"
	done
	echo -e "\e[1A\e[KEncoding... 100%"
}
partfiles()
{
	temp1=( $( ls -a $1) )
	partfiles=()
	i3=0
	while ((i3 < ${#temp1[@]})); do
		i3="$(($i3+1))"
		if [[ "${temp1[$((i3-1))]}" != "." ]] && [[ "${temp1[$((i3-1))]}" != ".." ]]; then
		partfiles[${#partfiles[@]}]="${temp1[$((i3-1))]}"
		fi
	done
}
# Init
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
characters='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~`!$^&*()-_=+[]/;:",.<>?\|%{}'
characters="${characters}'#@ °€"
printfb_info "Welcome to FSSC Builder by adazem009."
echo
# Get disk count
printfb_info "Reading project configuration."
source ./project.conf
disks=${#DiskName[@]}
# Check for errors
tmp="$((${#DiskName[@]}+${#DiskSize[@]}+${#DiskConfig[@]}+${#DiskBootable[@]}))"
tmp="$(echo "scale=2;${tmp}/4" | bc)"
if (( $(echo "$tmp != $disks" | bc) )); then
	abortfb "'project.conf' is wrongly configured." 1
fi
printfb_info "Found ${disks} disk(s)."
echo
# Set up disks
pcc=""
DiskContent=()
i1=0
while ((i1 < disks)); do
	i1="$(($i1+1))"
	DiskContent[$(($i1-1))]=""
	# Set up disk i1-1
	printfb_info "Setting up disk $((i1-1))."
	# Check for errors
	if test -f "${DiskConfig[$(($i1-1))]}"; then
		source "${DiskConfig[$(($i1-1))]}"
		# Check for errors
		tmp="$((${#PartitionName[@]}+${#PartitionSize[@]}+${#PartitionContent[@]}))"
		tmp="$(echo "scale=2;${tmp}/3" | bc)"
		if (( $(echo "$tmp != ${#PartitionName[@]}" | bc) )); then
			abortfb "'${DiskConfig[$(($i1-1))]}' is wrongly configured." 3
		fi
		printfb_info "Found ${#PartitionName[@]} partition(s) on disk $((i1-1))."
		remaining=$((${DiskSize[$(($i1-1))]}-7))
		partitions=()
		echo
		pcc="${pcc}${DiskName[$(($i1-1))]}+${DiskSize[$(($i1-1))]}+FPT;"
		ptc=""
		i2=0
		while ((i2 < ${#PartitionName[@]})); do
			i2="$(($i2+1))"
			if ((${PartitionSize[$((i2-1))]} < $(($((6+${#PartitionName[$((i2-1))]}))*2)))); then
				abortfb "Partition $((i2-1)) on disk $((i1-1)) is too small." 4
			fi
			tmp1=${PartitionSize[$((i2-1))]}
			tmp2=$((${DiskSize[$((i1-1))]}-7))
			if ((tmp1 > tmp2)); then
				abortfb "Partition $((i2-1)) on disk $((i1-1)) is too large." 4
			fi
			# Set up partition i2-1 on disk i1-1
			printfb_info "Setting up partition $((i2-1)) on disk $((i1-1))."
			if ! [ -d "${PartitionContent[$((i2-1))]}" ]; then
				abortfb "Directory '${PartitionContent[$((i2-1))]}' does not exist."
			fi
			printfb_info "Building filesystem."
			FSSC=()
			FSSC[0]="tFSSC"
			FSSC[1]="n${PartitionName[$((i2-1))]}"
			setup_files
			cd "$oldcd"
			list=()
			list=("${FSSC[@]}")
			echo -e "${YELLOW}Encoding filesystem...${NC}"
			encode
			if (($((${PartitionSize[$((i2-1))]} > remaining)))); then
				abortfb "Partition $((i2-1)) on disk $((i1-1)) is too large." 4
			fi
			echo "Filesystem size: ${#var} B"
			if ((${#var} > ${PartitionSize[$((i2-1))]})); then
				abortfb "Partition $((i2-1)) on disk $((i1-1)) has too large filesystem." 5
			fi
			remaining=$(($remaining-$((${PartitionSize[$((i2-1))]}))))
			echo "Remaining space on disk: ${remaining} B"
			partitions[${#partitions[@]}]="$var"
			success "Set up partition $((i2-1)) on disk $((i1-1))."
			printfb_info "Adding partition $((i2-1)) to disk $((i1-1)) code."
			pcc="${pcc}${var}"
			i3=0
			echo "Filling free space..."
			len="$((${PartitionSize[$((i2-1))]}-${#var}-1))" ch='X'
			free="$(printf '%*s' "$len" | tr ' ' "$ch")"
			pcc="${pcc}${free};"
			echo
			success "Added partition $((i2-1)) to disk $((i1-1)) code."
		done
		if [[ "${DiskBootable[$(($i1-1))]}" = "true" ]]; then
			pcc="${pcc}b;"
		elif [[ "${DiskBootable[$(($i1-1))]}" = "false" ]]; then
			pcc="${pcc}n;"
		else
			abortfb "'project.conf' is wrongly configured. (invalid DiskBootable value for disk $((i1-1)))" 1
		fi
		echo "Filling free space on disk $((i1-1))..."
		i3=0
		len="$remaining" ch='X'
		free="$(printf '%*s' "$len" | tr ' ' "$ch")"
		pcc="${pcc}${free}"
		pcc="${pcc}+/"
		success "Added disk $((i1-1)) to the PC code."
	else
		abortfb "Couldn't open ${DiskConfig[$(($i1-1))]}." 2
	fi
done
printfb_info "Writing the output to ${GREEN}output.fssc${NC}"
echo $pcc > ./output.fssc
success "Done!"
