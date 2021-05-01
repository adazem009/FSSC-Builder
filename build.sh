#!/bin/bash

# --- FSSC Builder ---
# 2021 - adazem009
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
		FSSC[${#FSSC[@]}]="$cd"
		FSSC[${#FSSC[@]}]="${#partfiles[@]}"
		i5=0
		while ((i5 < ${#partfiles[@]})); do
			i5="$(($i5+1))"
			if [ -d "${partfiles[$((i5-1))]}" ]; then
				echo "Adding directory ${dirs[$((i4-1))]}/${partfiles[$((i5-1))]}"
				findatt "$(remdot ${dirs[$((i4-1))]}/${partfiles[$((i5-1))]})"
				if [[ "$att" == '' ]]; then
					printfb_info "${RED}File attributes are not set!${NC} Using defaults."
					ins=$((ins+1))
					att="rw-rw-rw-;root;root;"
				fi
				echo "Attributes: $att"
				getatt "$att"
				FSSC[${#FSSC[@]}]=0
				FSSC[${#FSSC[@]}]="${partfiles[$((i5-1))]}"
				FSSC[${#FSSC[@]}]=""
			else
				list=()
				IFS=$'\r\n' GLOBIGNORE='*' command eval  'list=($(cat "${dirs[$((i4-1))]}/${partfiles[$((i5-1))]}"))'
				echo "Adding file ${dirs[$((i4-1))]}/${partfiles[$((i5-1))]}"
				encode
				findatt "$(remdot ${dirs[$((i4-1))]}/${partfiles[$((i5-1))]})"
				if [[ "$att" == '' ]]; then
					printfb_info "${RED}File attributes are not set!${NC} Using defaults."
					ins=$((ins+1))
					att="rwxrwxrwx;root;root;"
				fi
				echo "Attributes: $att"
				getatt "$att"
				FSSC[${#FSSC[@]}]=1
				FSSC[${#FSSC[@]}]="${partfiles[$((i5-1))]}"
				FSSC[${#FSSC[@]}]="$var"
			fi
			FSSC[${#FSSC[@]}]="$permissions"
			FSSC[${#FSSC[@]}]="$owner"
			FSSC[${#FSSC[@]}]="$group"
			FSSC[${#FSSC[@]}]="$attributes"
			echo
		done
	done
}
encode()
{
	if [[ "$auto" = "1" ]]; then
		echo "Converting..."
	else
		echo "Converting... 0%"
	fi
	var=""
	local line=""
	local len=0
	local ci=0
	while (( ci < ${#list[@]} )); do
		ci=$((ci+1))
		if [[ "$auto" != "1" ]]; then
			echo -e "\e[1A\e[KConverting... $(($((ci*100))/${#list[@]}))%"
		fi
		line="${list[$((ci-1))]}"
		len=${#line}
		var="${var}${len};${line}"
	done
	if [[ "$auto" != "1" ]]; then
		echo -e "\e[1A\e[KConverting... 100%"
	fi
	#echo "Encoding... 0%"
	#temp="${list[*]}"
	#tempi=0
	#var=""
	#item=0
	#while ((item < ${#list[@]})); do
	#	item="$(($item+1))"
	#	letter=0
	#	tempi1=0
	#	while ((tempi1 < ${#list[$((item-1))]})); do
	#		tempi1="$(($tempi1+1))"
	#		tempi="$(($tempi+1))"
	#		letter="$(($letter+1))"
	#		symbol=1
	#		until [[ "${characters:$((symbol-1)):1}" = "${list[$((item-1))]:$((letter-1)):1}" ]] || ((symbol > ${#characters})); do
	#			symbol="$(($symbol+1))"
	#		done
	#		if ((symbol <= ${#characters})); then
	#			if ((${#symbol} < 2)); then
	#				symbol="0${symbol}"
	#			fi
	#			if [[ "${list[$((item-1))]:$((letter-1)):1}" = ' ' ]]; then
	#				symbol=95
	#			fi
	#			var="${var}${symbol:0:1}${symbol:1:1}"
	#		fi
	#		echo -e "\e[1A\e[KEncoding... $(($((tempi*100))/${#temp}))%"
	#	done
	#	tempi1="$(($tempi1+1))"
	#	var="${var}00"
	#done
	#echo -e "\e[1A\e[KEncoding... 100%"
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
remdot()
{
	local i6=1
	local nodot=""
	local dotstring="$1"
	while ((i6 < ${#dotstring})); do
		i6=$((i6+1))
		nodot="${nodot}${dotstring:$((i6-1)):1}"
	done
	echo $nodot
}
findatt()
{
	local i6=0
	local attpath="$1"
	att=""
	while ((i6 < ${#fattn[@]})); do
		i6=$((i6+1))
		if [[ "${fattn[$((i6-1))]}" == "$attpath" ]]; then
			att="${fatt[$((i6-1))]}"
			break
		fi
	done
}
getatt()
{
	local gi=0
	local catt="$1"
	local sep=()
	local tmp=""
	while (( gi < ${#catt} )); do
		gi=$((gi+1))
		if [[ "${catt:$((gi-1)):1}" = ";" ]]; then
			sep[${#sep[@]}]="$tmp"
			tmp=""
		else
			tmp="${tmp}${catt:$((gi-1)):1}"
		fi
	done
	permissions="${sep[0]}"
	owner="${sep[1]}"
	group="${sep[2]}"
	attributes="${sep[3]}"
}
# Init
auto="$1"
if [[ "$auto" = 1 ]]; then
	RED=''
	GREEN=''
	YELLOW=''
	NC=''
else
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[1;33m'
	NC='\033[0m'
fi
characters='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~`!$^&*()-_=+[]/;:",.<>?\|%{}'
characters="${characters}'#@ °€"
ins=0
printfb_info "Welcome to FSSC Builder by adazem009."
echo
printfb_info "Reading project configuration."
source ./project.conf
echo
pcc=""
DiskContent=()
i1=1
DiskContent[$(($i1-1))]=""
# Set up disk
printfb_info "Setting up disk..."
printfb_info "Found ${#PartitionName[@]} partition(s)."
remaining=$((${DiskSize}))
partitions=()
echo
dname="${DiskName[$(($i1-1))]}"
dsize="${DiskSize[$(($i1-1))]}"
if ! [ -f mbr ]; then
	abortfb "The 'mbr' file does not exist." 3
fi
MBR=`cat mbr`
if (( ${#MBR} != 4096 )); then
	abortfb "The MBR size isn't 4096 bytes." 4
fi
#diskc="${#dname};${dname}${#dsize};${dsize}${dsize};$MBR"
diskc="$MBR"
ptc=""
i2=0
while ((i2 < ${#PartitionName[@]})); do
	i2="$(($i2+1))"
	if ((${PartitionSize[$((i2-1))]} < $(($((6+${#PartitionName[$((i2-1))]}))*2)))); then
		abortfb "Partition $((i2-1)) is too small." 4
	fi
	tmp1=${PartitionSize[$((i2-1))]}
	tmp2=$((${DiskSize}))
	if ((tmp1 > tmp2)); then
		abortfb "Partition $((i2-1)) is too large." 4
	fi
	# Set up partition i2-1
	printfb_info "Setting up partition $((i2-1))."
	if ! [ -d "${PartitionContent[$((i2-1))]}" ]; then
		abortfb "Directory '${PartitionContent[$((i2-1))]}' does not exist." 3
	fi
	if ! [ -f "${PartitionAttributes[$((i2-1))]}" ]; then
		abortfb "File '${PartitionAttributes[$((i2-1))]}' does not exist." 3
	fi
	chmod +x "${PartitionAttributes[$((i2-1))]}"
	source "${PartitionAttributes[$((i2-1))]}"
	printfb_info "Building filesystem."
	FSSC=()
	FSSC[0]="FSSC2" # current FSSC format string
	setup_files
	#printf '%s\n' "${FSSC[@]}"
	cd "$oldcd"
	list=()
	list=("${FSSC[@]}")
	echo -e "${YELLOW}Converting filesystem...${NC}"
	encode
	if (($((${PartitionSize[$((i2-1))]} > remaining)))); then
		abortfb "Partition $((i2-1)) is too large." 4
	fi
	echo "Filesystem size: ${#var} B"
	additional="${#pname};${pname}${#psize};${psize}${#var};${var}"
	if ((${#var} > ${PartitionSize[$((i2-1))]})) || (( ${#additional} > ${PartitionSize[$((i2-1))]} )); then
		abortfb "Partition $((i2-1)) has too large filesystem." 5
	fi
	remaining=$(($remaining-$((${PartitionSize[$((i2-1))]}))))
	echo "Remaining space on disk: ${remaining} B"
	partitions[${#partitions[@]}]="$var"
	success "Set up partition $((i2-1))."
	printfb_info "Adding partition $((i2-1))"
	pname="${PartitionName[$((i2-1))]}"
	psize="${PartitionSize[$((i2-1))]}"
	diskc="${diskc}$additional"
	i3=0
	echo
	success "Added partition $((i2-1))"
	echo
done
pcc="${pcc}${diskc}"
success "A media image was created."
echo && echo
printfb_info "Writing the output to ${GREEN}output.fssc${NC}"
echo $pcc > ./output.fssc
success "Done!"
if ((ins > 0)); then
	if ((ins > 1)); then
		temp0="s"
		temp1="don't"
		temp2="They"
	else
		temp0=""
		temp1="doesn't"
		temp2="It"
	fi
	printfb_info "The build succeeded, but $ins file$temp0 $temp1 have attributes defined. ${temp2}'ll be ${RED}world-writable${NC}."
fi
