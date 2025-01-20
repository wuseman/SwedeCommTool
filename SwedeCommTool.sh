#!/usr/bin/env bash

# - iNFO --------------------------------------
#
#   Author: wuseman <wuseman@nr1.nu>
# FileName: CallTheSwede.sh
#  Created: 2023-07-08 (07:22:51)
# Modified: 2023-07-09 (03:21:53)
#  Version: 1.0
#  License: MIT
#
#      iRC: wuseman (Libera/EFnet/LinkNet)
#   GitHub: https://github.com/wuseman/
#
# ----------------------------------------------

prefix=""
phone_number=""
sms_number=""
sms_message=""
random_call=false
random_sms=false
parallel=false

display_usage() {

	cat <<EOF

Usage: $(basename "$0") [OPTIONS]

    --prefix PREFIX            | Specify a prefix for phone numbers (range: 70-79)

Options:

    --call NUMBER              | Make a call to the specified phone NUMBER
    --send-sms NUMBER MESSAGE  | Send an SMS to the specified phone NUMBER with the given MESSAGE
    --random-call              | Make a random call to a Swedish number
    --random-sms TEXT          | Send a random SMS with the given TEXT
    -p, --parallel N           | Send random SMS messages in parallel (N is the number of parallel messages)
    -h, --help                 | Display this help message

Description:

This script allows you to perform various actions related to phone calls and SMS on an Android device using ADB.

    Examples:

        $(basename "$0") --prefix 73 --call 123456789
        $(basename "$0") --send-sms 987654321 "Hello, how are you?"
        $(basename "$0") --random-call
        $(basename "$0") --random-sms "I'm feeling lucky"
        $(basename "$0") -p 5 --random-sms "Have a great day!"

EOF
}

make_call() {
	local number="$1"
	echo "Calling $number..."
	adb shell am start -a android.intent.action.CALL -d "tel:$number"
	read -rp "Press Enter to end the call..."
	echo "Ending call."
	adb shell input keyevent KEYCODE_ENDCALL
}

send_sms() {
	local number="$1"
	local message="$2"
	echo "Sending SMS to $number: $message..."
	adb shell am start -a android.intent.action.SENDTO -d "smsto:$number" --es sms_body "$message" --ez exit_on_sent true >/dev/null 2>&1

	if [[ $? -eq 0 ]]; then
		echo "SMS sent."
	else
		echo "Failed to send SMS."
	fi

	adb shell input keyevent KEYCODE_HOME
	while [[ $(adb shell dumpsys activity | grep -i mCurrentFocus | awk 'NR==1{print $3}' | cut -d'}' -f1) != *"Launcher"* ]]; do
		sleep 1
	done
}

generate_random_swedish_number() {
	local prefix="+467"
	local random_suffix=$(shuf -i 10000000-99999999 -n 1)
	echo "$prefix$random_suffix"
}

generate_random_sms_message() {
	local text="$1"
	local random_message=$(shuf -n 1 <<<"$text")
	echo "${random_message// /\\ }"
}

end_call() {
	echo "Ending call."

	# Add your adb shell command here to end the call
	adb shell input keyevent KEYCODE_ENDCALL
	exit 0
}

trap end_call SIGINT SIGTERM

while [[ $# -gt 0 ]]; do
	case "$1" in
	--prefix | -p)
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		prefix="$1"
		;;
	--call | -c)
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		phone_number="$1"
		;;
	--send-sms | -s)
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		sms_number="$1"
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		sms_message="$1"
		;;
	--random-call | -r)
		random_call=true
		;;
	--random-sms)
		random_sms=true
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		sms_message="$1"
		;;
	--parallel | -p)
		parallel=true
		shift
		if [[ $# -eq 0 ]]; then
			display_usage >&2
			exit 1
		fi
		num_parallel="$1"
		;;
	--help | -h)
		display_usage
		exit 0
		;;
	*)
		display_usage >&2
		exit 1
		;;
	esac
	shift
done

if [[ ! -z $prefix ]] && [[ ($prefix -lt 70) || ($prefix -gt 79) ]]; then
	echo "Prefix must be between 70 and 79"
	exit 1
fi

if [[ ! -z $prefix ]]; then
	for ((i = prefix; i <= 79; i++)); do
		seq -w 0000000 9999999 | xargs -I {} -P 4 echo "+46${i}{}"
	done
fi

if [[ ! -z $phone_number ]]; then
	make_call "$phone_number"
fi

if [[ ! -z $sms_number ]] && [[ ! -z $sms_message ]]; then
	send_sms "$sms_number" "$sms_message"
fi

if [[ $random_call == true ]]; then
	random_number=$(generate_random_swedish_number)
	make_call "$random_number"
fi

if [[ $random_sms == true ]] && [[ $parallel == true ]]; then
	if [[ -z $num_parallel ]]; then
		echo "Please specify the number of parallel SMS messages using the --parallel option."
		exit 1
	fi
	if ! [[ $num_parallel =~ ^[1-9][0-9]*$ ]]; then
		echo "Invalid value for the number of parallel SMS messages. Please provide a positive integer."
		exit 1
	fi

	echo "Sending $num_parallel random SMS messages in parallel..."

	numbers=()
	for ((i = 0; i < num_parallel; i++)); do
		numbers+=("$(generate_random_swedish_number)")
	done

	messages=()
	for ((i = 0; i < num_parallel; i++)); do
		messages+=("$(generate_random_sms_message "$sms_message")")
	done

	i=1
	while IFS= read -r number && IFS= read -r message; do
		send_sms "$number" "$message"
		echo "SMS $i sent."
		((i++))
	done < <(paste -d'\n' <(printf "%s\n" "${numbers[@]}") <(printf "%s\n" "${messages[@]}"))
fi

((!$#)) && display_usage
