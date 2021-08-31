#!/bin/bash

BTC_DIR_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include file
source "${BTC_DIR_ROOT}/../include/functions.sh"

echo 'Welcome to "Blockchain with PHP" by Liviu Balan!'
echo ''
echo 'Pleases provide your answer to the following questions.'
echo 'You can leave the default options and just press enter if you are ok with them.'
echo ''

# Prompt question
BTC_TMP_QUESTION='Temporary Git project absolute path with no trailing slash: '
BTC_TMP_ANSWER_DEFAULT=''
read -p "${BTC_TMP_QUESTION}" -e -i "${BTC_TMP_ANSWER_DEFAULT}" BTC_TMP_ANSWER

# Check empty data
if [ -z "${BTC_TMP_ANSWER}" ]; then
    echo "Value not set."
    exit 1
fi

# Check directory existence
if [ ! -d "${BTC_TMP_ANSWER}" ]; then
    echo "'${BTC_TMP_ANSWER}' is not a valid directory."
    exit 1
fi

# Remove old include
rm -rf "${BTC_DIR_ROOT}/include"

# Copy directory
cp -r "${BTC_DIR_ROOT}/include-dist" "${BTC_DIR_ROOT}/include"

# Replace value
btc_strf_replace_once "BTC_CONFIG_GIT_2=''" "BTC_CONFIG_GIT_2='${BTC_TMP_ANSWER}'" "${BTC_DIR_ROOT}/include/config.sh"

# Prompt question
BTC_TMP_QUESTION='PhpStorm absolute path: '
BTC_TMP_ANSWER_DEFAULT=''
read -p "${BTC_TMP_QUESTION}" -e -i "${BTC_TMP_ANSWER_DEFAULT}" BTC_TMP_ANSWER

# Check empty data
if [ -n "${BTC_TMP_ANSWER}" ]; then
    # Check file existence
    if [ ! -f "${BTC_TMP_ANSWER}" ]; then
        echo "'${BTC_TMP_ANSWER}' is not a valid file."
        exit 1
    fi
fi

# Replace value
btc_strf_replace_once "BTC_CONFIG_PHPSTORM=''" "BTC_CONFIG_PHPSTORM='${BTC_TMP_ANSWER}'" "${BTC_DIR_ROOT}/include/config.sh"

# Copy file
cp "${BTC_DIR_ROOT}/follow.sh" "${BTC_DIR_ROOT}/../../follow.sh"

# Replace value
btc_strf_replace_once "echo 'Follow the wizard.' && exit 1" '' "${BTC_DIR_ROOT}/../../follow.sh"
