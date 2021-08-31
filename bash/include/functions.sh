#!/bin/bash

# General functions

# Check if step needs to be performed
# $1 = Step name
function btc_step_check()
{
    if [ -n "$1" ]; then
        # Check if file exists or step provided
        if [ ! -f "$BTC_SERVER_DIR_PROVISION_TMP_LAST" ] || [ "$BTC_STEP" == "$1" ]; then
            echo '1'
        else
            echo '0'
        fi
    fi
}

# Print step message
# $1 = Step name
function btc_step_info()
{
    if [ -n "$1" ]; then
        btc_print_info "Performing step '$1'"
    fi
}

# Checks if a value exists in an array
# $1 = String searched value (needle)
# $2 = Array (haystack)
# $3 = Optional "regex" mode. Possible values: 0 (false) - default; 1 (true)
function btc_in_array()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_NEEDLE="$1"

        local BTC_TMP_HAYSTACK_NAME=$2[@]
        local BTC_TMP_HAYSTACK=("${!BTC_TMP_HAYSTACK_NAME}")
        local BTC_TMP_REGEX=0
        if [ -n "$3" ]; then
            BTC_TMP_REGEX="$3"
        fi

        local BTC_TMP_RESULT=0
        local BTC_TMP=''

        for BTC_TMP in "${BTC_TMP_HAYSTACK[@]}" ; do
            # "equal" mode
            if [ '0' -eq "$BTC_TMP_REGEX" ] && [ "$BTC_TMP" == "$BTC_TMP_NEEDLE" ]; then
                BTC_TMP_RESULT=1
                break
            fi

            # "regex" mode
            if [ '1' -eq "$BTC_TMP_REGEX" ] && [ '1' -eq $(echo "$BTC_TMP_NEEDLE" | grep -c "$BTC_TMP") ]; then
                BTC_TMP_RESULT=1
                break
            fi
        done

        echo "$BTC_TMP_RESULT"
    fi
}

# Escape string used as bash single quoted param
# $1 = String to be escaped
function btc_bash_sq_escape()
{
    if [ "$#" -ge 1 ]; then
        local BTC_TMP="$1"

        # ' => '"'"'
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/'"'"'/'"'"'"'"'"'"'"'"'/g')

        echo "$BTC_TMP"
    fi
}

# Execute command as admin
# $1 = Command
function btc_exec_as_admin()
{
    if [ -n "$1" ]; then
        sudo -H -u "$BTC_USR_USER" bash -c "umask '$BTC_USR_UMASK' && $1"
    fi
}

# Execute command as root
# $1 = Command
function btc_exec_as_root()
{
    if [ -n "$1" ]; then
        sudo -H -u 'root' bash -c "umask 0027 && $1"
    fi
}

# Check if "btc_set_admin" needs to be performed
# $1 = Resource path without trailing slash
# $2 = Optional user value. Default to $BTC_USR_USER
# $3 = Optional user group. Default to www-data
# $4 = Optional access rights. Default to 775 (directory) or 664 (file)
function btc_set_admin_check()
{
    if [ -n "$1" ]; then
        local BTC_TMP_USER="$BTC_USR_USER"
        local BTC_TMP_GROUP='www-data'
        local BTC_TMP_RIGHTS='664'
        # Check if directory exists
        if [ -d "$1" ]; then
            BTC_TMP_RIGHTS='775'
        fi

        if [ -n "$2" ]; then
            BTC_TMP_USER="$2"
        fi
        if [ -n "$3" ]; then
            BTC_TMP_GROUP="$3"
        fi
        if [ -n "$4" ]; then
            BTC_TMP_RIGHTS="$4"
        fi

        local BTC_TMP_CURRENT_USER=$(sudo stat -c '%U' "$1")
        local BTC_TMP_CURRENT_GROUP=$(sudo stat -c '%G' "$1")
        local BTC_TMP_CURRENT_RIGHTS=$(sudo stat -c '%a' "$1")

        if [ "$BTC_TMP_USER" != "$BTC_TMP_CURRENT_USER" ] || [ "$BTC_TMP_GROUP" != "$BTC_TMP_CURRENT_GROUP" ] || [ "$BTC_TMP_RIGHTS" != "$BTC_TMP_CURRENT_RIGHTS" ]; then
            echo '1'
        else
            echo '0'
        fi
    fi
}

# Set admin owner, group and access rights to $1 (resource path).
# If $1 (resource path) is a directory this apply recursively to all the children.
# $1 = Resource path without trailing slash
# $2 = Optional user value. Default to $BTC_USR_USER
# $3 = Optional user group. Default to www-data
# $4 = Optional access rights directory. Default to 775
# $5 = Optional access rights file. Default to 664
function btc_set_admin()
{
    if [ -n "$1" ]; then
        local BTC_TMP_USER="$BTC_USR_USER"
        local BTC_TMP_GROUP='www-data'
        local BTC_TMP_RIGHTS_DIR='775'
        local BTC_TMP_RIGHTS_FILE='664'

        if [ -n "$2" ]; then
            BTC_TMP_USER="$2"
        fi
        if [ -n "$3" ]; then
            BTC_TMP_GROUP="$3"
        fi
        if [ -n "$4" ]; then
            BTC_TMP_RIGHTS_DIR="$4"
        fi
        if [ -n "$5" ]; then
            BTC_TMP_RIGHTS_FILE="$5"
        fi

        sudo chown "$BTC_TMP_USER:$BTC_TMP_GROUP" "$1"

        # Check file on root level using sudo, not on current user level
        if sudo test -f "$1"; then
            #echo "file root: $1"
            sudo chmod "$BTC_TMP_RIGHTS_FILE" "$1"
        elif sudo test -d "$1"; then
            sudo chmod "$BTC_TMP_RIGHTS_DIR" "$1"

            # Check if empty directory
            BTC_TMP_FILES=$(sudo bash -c "find $1 -maxdepth 1 ! -path $1")
            if [ -n "$BTC_TMP_FILES" ]; then
                # \n to array
                mapfile -t BTC_TMP_FILES <<< "$BTC_TMP_FILES"

                # Loop files
                for BTC_TMP_FILE in "${BTC_TMP_FILES[@]}"
                do
                    if sudo test -d "$BTC_TMP_FILE"; then
                        #echo "dir:  $BTC_TMP_FILE"
                        btc_set_admin "$BTC_TMP_FILE" "$BTC_TMP_USER" "$BTC_TMP_GROUP" "$BTC_TMP_RIGHTS_DIR" "$BTC_TMP_RIGHTS_FILE"
                    elif sudo test -f "$BTC_TMP_FILE"; then
                        #echo "file: $BTC_TMP_FILE"
                        sudo chown "$BTC_TMP_USER:$BTC_TMP_GROUP" "$BTC_TMP_FILE"
                        sudo chmod "$BTC_TMP_RIGHTS_FILE" "$BTC_TMP_FILE"
                    fi
                done
            fi
        fi
    fi
}

# This function behaves like "btc_set_admin" but applies based on "btc_set_admin_check"
# Set admin owner, group and access rights to $1 (resource path).
# If $1 (resource path) is a directory this apply recursively to all the children.
# $1 = Resource path without trailing slash
# $2 = Optional user value. Default to $BTC_USR_USER
# $3 = Optional user group. Default to www-data
# $4 = Optional access rights directory. Default to 775
# $5 = Optional access rights file. Default to 664
function btc_set_admin_once()
{
    if [ -n "$1" ]; then
        if [ '1' == $(btc_set_admin_check "$1" "$2" "$3" "$4" "$5") ]; then
            btc_set_admin "$1" "$2" "$3" "$4" "$5"
        fi
    fi
}

# Set current user owner, group and rights to $1 (resource path).
# See "btc_set_admin" for more info.
# $1 = Resource path without trailing slash
function btc_set_user_current()
{
    if [ -n "$1" ]; then
        local BTC_TMP_USER=$(id -u -n)
        local BTC_TMP_GROUP=$(id -g -n)

        btc_set_admin "$1" "$BTC_TMP_USER" "$BTC_TMP_GROUP"
    fi
}

# Set root owner, group and rights to $1 (resource path).
# See "btc_set_admin" for more info.
# $1 = Resource path without trailing slash
function btc_set_user_root()
{
    if [ -n "$1" ]; then
        btc_set_admin "$1" 'root' 'root' '750' '640'
    fi
}

# Check if package is installed
# $1 = Package name
function btc_package_installed()
{
    if [ -n "$1" ]; then
        dpkg-query -W -f '${Status}' "$1" 2>/dev/null | grep -c 'install ok installed'
    fi
}

# Check package version
# $1 = Package name
function btc_package_version()
{
    if [ -n "$1" ]; then
        apt-cache policy "$1" | grep 'Installed:' | cut -d' ' -f4
    fi
}

# Print with color and return to the default config foreground color
# $1 = Message
# $2 = Color. Default to $BTC_COLOR_DEFAULT
function btc_print_color()
{
    if [ "$#" -ge 1 ]; then
        local BTC_COLOR_CUR="$BTC_COLOR_DEFAULT"

        if [ "$#" -ge 2 ]; then
            BTC_COLOR_CUR="$2"
        fi

        echo -e "$BTC_COLOR_CUR$1$BTC_COLOR_DEFAULT"
    fi
}

# Print default message
# $1 = Message
function btc_print_default()
{
    if [ "$#" -ge 1 ]; then
        btc_print_color "$1" "$BTC_COLOR_DEFAULT"
    fi
}

# Print success message
# $1 = Message
function btc_print_success()
{
    if [ "$#" -ge 1 ]; then
        btc_print_color "$1" "$BTC_COLOR_SUCCESS"
    fi
}

# Print info message
# $1 = Message
function btc_print_info()
{
    if [ "$#" -ge 1 ]; then
        btc_print_color "$1" "$BTC_COLOR_INFO"
    fi
}

# Print warning message
# $1 = Message
function btc_print_warning()
{
    if [ "$#" -ge 1 ]; then
        btc_print_color "$1" "$BTC_COLOR_WARNING"
    fi
}

# Print danger message
# $1 = Message
function btc_print_danger()
{
    if [ "$#" -ge 1 ]; then
        btc_print_color "$1" "$BTC_COLOR_DANGER"
    fi
}

# Print a message and exit current script execution
# $1 = Message
function btc_exit()
{
    if [ "$#" -ge 1 ]; then
        btc_print_danger "$1"
        exit 1
    fi
}

# Escape search or replace param used in "perl" command
# $1 = String to be escaped
function btc_perl_escape()
{
    if [ "$#" -ge 1 ]; then
        local BTC_TMP="$1"

        # Replace \ first
        # \ => \\
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\\/\\\\/g')

        # . => \.
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\./\\./g')

        # ^ => \^
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\^/\\^/g')

        # $ => \$
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\$/\\$/g')

        # * => \*
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\*/\\*/g')

        # + => \+
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\+/\\+/g')

        # ? => \?
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\?/\\?/g')

        # ( => \(
        BTC_TMP=$(echo "$BTC_TMP" | sed -re 's/[(]/\\(/g')

        # ) => \)
        BTC_TMP=$(echo "$BTC_TMP" | sed -re 's/[)]/\\)/g')

        # [ => \[
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\[/\\[/g')

        # { => \{
        BTC_TMP=$(echo "$BTC_TMP" | sed -re 's/[{]/\\{/g')

        # | => \|
        BTC_TMP=$(echo "$BTC_TMP" | sed -re 's/[|]/\\|/g')

        # / => \/
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\//\\\//g')

        # @ => \@
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\@/\\@/g')

        echo "$BTC_TMP"
    fi
}

# Escape string used in "sed" command
# $1 = String to be escaped
function btc_sed_escape()
{
    if [ "$#" -ge 1 ]; then
        local BTC_TMP="$1"

        # Replace \ first
        # \ => \\
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\\/\\\\/g')

        # * => \*
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\*/\\*/g')

        # [ => \[
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\[/\\[/g')

        # / => \/
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\//\\\//g')

        # _ => \_
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\_/\\_/g')

        # & => \&
        BTC_TMP=$(echo "$BTC_TMP" | sed 's/\&/\\&/g')

        echo "$BTC_TMP"
    fi
}

# Replace all occurrences of the search string with the replacement string.
# $1 and $2 are escaped so you cannot use patterns inside of them.
# $1 = Search
# $2 = Replace
# $3 = Subject
function btc_str_replace()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_SEARCH=$(btc_perl_escape "$1")
        local BTC_TMP_REPLACE=$(btc_perl_escape "$2")

        echo "$3" | perl -0777 -pe "s/$BTC_TMP_SEARCH/$BTC_TMP_REPLACE/gs"
    fi
}

# Replace current $3 (subject) line with $2 (replace) if $1 (search) matches the start of the line.
# $1 and $2 are escaped so you cannot use patterns inside of them.
# $1 = Search
# $2 = Replace
# $3 = Subject
function btc_str_line_replace()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_SEARCH=$(btc_sed_escape "$1")
        local BTC_TMP_REPLACE=$(btc_sed_escape "$2")

        echo "$3" | sed "s/^$BTC_TMP_SEARCH.*$/$BTC_TMP_REPLACE/g"
    fi
}

# Replace all occurrences of the search string with the replacement string inside of a file.
# $1 and $2 are escaped so you cannot use patterns inside of them.
# $1 = Search
# $2 = Replace
# $3 = File path
function btc_strf_replace()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_EXISTS='0'
        local BTC_TMP_SUBJECT=''
        local BTC_TMP_REPLACED=''

        if sudo test -f "$3"; then
            BTC_TMP_EXISTS='1'
            BTC_TMP_SUBJECT=$(sudo cat "$3")
        fi

        BTC_TMP_REPLACED=$(btc_str_replace "$1" "$2" "$BTC_TMP_SUBJECT")
        BTC_TMP_REPLACED=$(btc_bash_sq_escape "$BTC_TMP_REPLACED")

        sudo bash -c "echo '$BTC_TMP_REPLACED' > '$3'"

        # File created
        if [ '0' -eq "$BTC_TMP_EXISTS" ]; then
            btc_set_user_current "$3"
        fi
    fi
}

# Replace current $3 (file path) line with $2 (replace) if $1 (search) matches the start of the line.
# This function is useful on config files where you will want to alter the line without rely on param value.
# $1 and $2 are escaped so you cannot use patterns inside of them.
# $1 = Search
# $2 = Replace
# $3 = File path
function btc_strf_line_replace()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_EXISTS='0'
        local BTC_TMP_SUBJECT=''
        local BTC_TMP_REPLACED=''

        if sudo test -f "$3"; then
            BTC_TMP_EXISTS='1'
            BTC_TMP_SUBJECT=$(sudo cat "$3")
        fi

        BTC_TMP_REPLACED=$(btc_str_line_replace "$1" "$2" "$BTC_TMP_SUBJECT")
        BTC_TMP_REPLACED=$(btc_bash_sq_escape "$BTC_TMP_REPLACED")

        sudo bash -c "echo '$BTC_TMP_REPLACED' > '$3'"

        # File created
        if [ '0' -eq "$BTC_TMP_EXISTS" ]; then
            btc_set_user_current "$3"
        fi
    fi
}

# Append $1 (string) to $2 (subject) file
# $1 = String
# $2 = Subject file path
function btc_str_append()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_EXISTS='0'
        local BTC_TMP_STRING=$(btc_bash_sq_escape "$1")

        if sudo test -e "$2"; then
            BTC_TMP_EXISTS='1'
        fi

        sudo bash -c "echo '$BTC_TMP_STRING' >> '$2'"

        # File created
        if [ '0' -eq "$BTC_TMP_EXISTS" ]; then
            btc_set_user_current "$2"
        fi
    fi
}

# Append $1 (string) file to $2 (subject) file
# $1 = String file path
# $2 = Subject file path
function btc_strf_append()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_EXISTS='0'
        local BTC_TMP_STRING=''

        if sudo test -f "$1"; then
            if sudo test -f "$2"; then
                BTC_TMP_EXISTS='1'
            fi

            BTC_TMP_STRING=$(sudo cat "$1")
            BTC_TMP_STRING=$(btc_bash_sq_escape "$BTC_TMP_STRING")

            sudo bash -c "echo '$BTC_TMP_STRING' >> '$2'"

            # File created
            if [ '0' -eq "$BTC_TMP_EXISTS" ]; then
                btc_set_user_current "$2"
            fi
        fi
    fi
}

# Check if $1 (haystack) contains $2 (needle).
# Return: 0 = do not contain; 1 = contains
# $1 = Haystack
# $2 = Needle
function btc_str_contains()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_REPLACED=$(btc_str_replace "$2" '' "$1")

        if [ "$BTC_TMP_REPLACED" == "$1" ]; then
            echo '0'
        else
            echo '1'
        fi
    fi
}

# This function behaves like "btc_str_replace" but applies only if $2 (replace) is not found in $3 (subject)
# $1 = Search
# $2 = Replace
# $3 = Subject
function btc_str_replace_once()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_CONTAINS=$(btc_str_contains "$3" "$2")

        if [ '0' -eq "$BTC_TMP_CONTAINS" ]; then
            btc_str_replace "$1" "$2" "$3"
        else
            echo "$3"
        fi
    fi
}

# This function behaves like "btc_strf_replace" but applies only if $2 (replace) is not found in $3 (file path)
# $1 and $2 are escaped so you cannot use patterns inside of them.
# $1 = Search
# $2 = Replace
# $3 = File path
function btc_strf_replace_once()
{
    if [ "$#" -ge 3 ]; then
        local BTC_TMP_SUBJECT=''
        local BTC_TMP_CONTAINS='0'

        if sudo test -f "$3"; then
            BTC_TMP_SUBJECT=$(sudo cat "$3")
        fi

        BTC_TMP_CONTAINS=$(btc_str_contains "$BTC_TMP_SUBJECT" "$2")

        if [ '0' -eq "$BTC_TMP_CONTAINS" ]; then
            btc_strf_replace "$1" "$2" "$3"
        fi
    fi
}

# This function behaves like "btc_str_append" but applies only if $1 (string) is not found in $2 (subject) content
# $1 = String
# $2 = Subject file path
function btc_str_append_once()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_SUBJECT=''
        local BTC_TMP_CONTAINS='0'

        if sudo test -f "$2"; then
            BTC_TMP_SUBJECT=$(sudo cat "$2")
        fi

        BTC_TMP_CONTAINS=$(btc_str_contains "$BTC_TMP_SUBJECT" "$1")

        if [ '0' -eq "$BTC_TMP_CONTAINS" ]; then
            btc_str_append "$1" "$2"
        fi
    fi
}

# This function behaves like "btc_strf_append" but applies only if $1 (string) content is not found in $2 (subject) content
# $1 = String file path
# $2 = Subject file path
function btc_strf_append_once()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_STRING=''
        local BTC_TMP_SUBJECT=''
        local BTC_TMP_CONTAINS='0'

        if sudo test -f "$1"; then
            BTC_TMP_STRING=$(sudo cat "$1")
        fi

        if sudo test -f "$2"; then
            BTC_TMP_SUBJECT=$(sudo cat "$2")
        fi

        BTC_TMP_CONTAINS=$(btc_str_contains "$BTC_TMP_SUBJECT" "$BTC_TMP_STRING")

        if [ '0' -eq "$BTC_TMP_CONTAINS" ]; then
            btc_strf_append "$1" "$2"
        fi
    fi
}

# Archive $1 (source absolute path) to "$1$BTC_ARCH_EXT" and remove $1 (original file)
# $1 = Source absolute path
# $2 = Run as sudo. Possible values: 0 (false) - default; 1 (true)
function btc_archive_create()
{
    if [ "$#" -ge 1 ]; then
        local BTC_TMP_SOURCE="$1"

        # Check if resource exists
        if [ -e "$BTC_TMP_SOURCE" ]; then
            local BTC_TMP_SOURCE_DIR=$(dirname "$BTC_TMP_SOURCE")
            local BTC_TMP_SOURCE_FILE=$(basename "$BTC_TMP_SOURCE")
            local BTC_TMP_DESTINATION="$BTC_TMP_SOURCE$BTC_ARCH_EXT"
            local BTC_TMP_SUDO='0'
            local BTC_TMP_COMMAND_TAR="tar -cjf '$BTC_TMP_DESTINATION' -C '$BTC_TMP_SOURCE_DIR' '$BTC_TMP_SOURCE_FILE'"
            local BTC_TMP_COMMAND_RM="rm -rf '$BTC_TMP_SOURCE'"

            if [ -n "$2" ]; then
                BTC_TMP_SUDO="$2"
            fi

            if [ '1' -eq "$BTC_TMP_SUDO" ]; then
                eval "sudo $BTC_TMP_COMMAND_TAR"
                eval "sudo $BTC_TMP_COMMAND_RM"
            else
                eval "$BTC_TMP_COMMAND_TAR"
                eval "$BTC_TMP_COMMAND_RM"
            fi
        fi
    fi
}

# Extract archive $1 (source absolute path) and remove $1 (original archive file)
# $1 = Source absolute path
# $2 = Run as sudo. Possible values: 0 (false) - default; 1 (true)
function btc_archive_extract()
{
    if [ "$#" -ge 1 ]; then
        local BTC_TMP_SOURCE="$1"

        # Check if resource exists
        if [ -e "$1" ]; then
            local BTC_TMP_SOURCE_DIR=$(dirname "$BTC_TMP_SOURCE")
            local BTC_TMP_SUDO='0'
            local BTC_TMP_COMMAND_TAR="tar -xjf '$1' -C '$BTC_TMP_SOURCE_DIR'"
            local BTC_TMP_COMMAND_RM="rm -rf '$1'"

            if [ -n "$2" ]; then
                BTC_TMP_SUDO="$2"
            fi

            if [ '1' -eq "$BTC_TMP_SUDO" ]; then
                eval "sudo $BTC_TMP_COMMAND_TAR"
                eval "sudo $BTC_TMP_COMMAND_RM"
            else
                eval "$BTC_TMP_COMMAND_TAR"
                eval "$BTC_TMP_COMMAND_RM"
            fi
        fi
    fi
}

# Get data from CLI param or standard input
# $1 = CLI param
# $2 = Message when reading from standard input
function btc_read_cli_stdin()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_INPUT=''

        if [ -z "$1" ]; then
            # Read one line from standard input
            echo "$2" >&2
            read BTC_TMP_INPUT
        else
            # Input data from CLI param
            BTC_TMP_INPUT="$1"
        fi

        echo "$BTC_TMP_INPUT"
    fi
}

# Generate script $2 (destination) based on $1 (source) and $3 (optional "tests" mode)
# $1 = Source absolute path
# $2 = Destination absolute path
# $3 = Optional "tests" mode. Possible values: 0 (false) - default; 1 (true)
function btc_script_generate()
{
    if [ "$#" -ge 2 ]; then
        # Check if file exists
        if [ -f "$1" ]; then
            local BTC_TMP_EXISTS='0'
            local BTC_TMP_SEARCH=$(cat "$BTC_DIR_RES_FUNCTIONS_DIR/btc_script_generate/search.sh")
            local BTC_TMP_REPLACE=$(cat "$BTC_DIR_RES_FUNCTIONS_DIR/btc_script_generate/replace.sh")

            if sudo test -e "$2"; then
                BTC_TMP_EXISTS='1'
            fi

            # Copy script
            sudo cp "$1" "$2"

            # Include config and functions files
            if [ -n "$3" ]; then
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_BOOTSTRAP"' "'$BTC_DIR_TESTS_INCLUDE_CONFIG_BOOTSTRAP'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_ENV_SCRIPT"' "'$BTC_DIR_RES_CONFIG_ENV'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_FUNCTIONS"' "'$BTC_DIR_RES_FUNCTIONS'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG"' "'$BTC_DIR_RES_CONFIG'" "$BTC_TMP_REPLACE")
            else
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_BOOTSTRAP"' "'$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_BOOTSTRAP'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_ENV_SCRIPT"' "'$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG_ENV_SCRIPT'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_FUNCTIONS"' "'$BTC_SERVER_DIR_SCRIPT_INCLUDE_FUNCTIONS'" "$BTC_TMP_REPLACE")
                BTC_TMP_REPLACE=$(btc_str_replace '"$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG"' "'$BTC_SERVER_DIR_SCRIPT_INCLUDE_CONFIG'" "$BTC_TMP_REPLACE")
            fi
            btc_strf_replace "$BTC_TMP_SEARCH" "$BTC_TMP_REPLACE" "$2"

            # File created
            if [ '0' -eq "$BTC_TMP_EXISTS" ]; then
                btc_set_user_current "$2"
            fi
        fi
    fi
}

# Run hooks $2 (file basename) from $1 (directory name)
# $1 = Directory name
# $2 = File basename
function btc_hooks_run()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_DIR_ENV=''
        local BTC_TMP_DIR=''
        local BTC_TMP_DIR_NAME=''
        local BTC_TMP_DIR_WWW=''
        local BTC_TMP_FILE=''

        for BTC_TMP_DIR_ENV in "$BTC_DIR_ENV"/*; do
            # Check if directory exists and is not config directory
            if [ -d "$BTC_TMP_DIR_ENV" ] && [ "$BTC_DIR_ENV_CONFIG" != "$BTC_TMP_DIR_ENV" ]; then
                for BTC_TMP_DIR in "$BTC_TMP_DIR_ENV/$1"/*; do
                    # Check if directory exists
                    if [ -d "$BTC_TMP_DIR" ]; then
                        BTC_TMP_DIR_SHARE="$BTC_TMP_DIR_ENV/$BTC_DIR_ENV_SHARE"
                        BTC_TMP_DIR_NAME=$(basename "$BTC_TMP_DIR")
                        BTC_TMP_DIR_WWW="/var/www/$BTC_TMP_DIR_NAME"
                        BTC_TMP_FILE="$BTC_TMP_DIR/$2"

                        # Check if file exists
                        if [ -f "$BTC_TMP_FILE" ]; then
                            source "$BTC_TMP_FILE"
                        fi
                    fi
                done
            fi
        done
    fi
}

# Clone $1 (Git repository) into $2 (directory absolute path) if $2 doesn't exist and config Git repository
# $1 = Git repository
# $2 = Directory absolute path
function btc_git_setup_as_admin()
{
    local BTC_TMP_FILE=''

    if [ "$#" -ge 2 ]; then
        # Display info
        echo ''
        echo "Git setup $2"

        # Check if directory exists
        if ! sudo test -d "$2"; then
            # Clone Git repository into a new directory
            btc_exec_as_admin "git clone $1 $2"
        fi

        BTC_TMP_FILE="$2/.git/hooks/commit-msg"
        # Check if file exists and is a symbolic link
        if ! sudo test -L "$BTC_TMP_FILE"; then
            # Create symbolic link.
            # Git hooks scripts from "$BTC_SERVER_DIR_GIT_HOOKS" should be executable
            btc_exec_as_admin "ln -s $BTC_SERVER_DIR_GIT_HOOKS/commit-msg.sh $BTC_TMP_FILE"
        fi
    fi
}

# Append $1 (string) to $BTC_SERVER_DIR_CRON_FILE and log data to $2 (log name)
# $1 = String
# $2 = Log name
function btc_cron_append_once()
{
    if [ "$#" -ge 2 ]; then
        local BTC_TMP_STRING="$1"
        BTC_TMP_STRING="$BTC_TMP_STRING > ${BTC_SERVER_DIR_CRON_LOG}/${2}.log 2>&1"

        if sudo test -s "$BTC_SERVER_DIR_CRON_FILE"; then
            btc_str_append '' "$BTC_SERVER_DIR_CRON_FILE"
        fi
        btc_str_append_once "$BTC_TMP_STRING" "$BTC_SERVER_DIR_CRON_FILE"
        btc_set_admin "$BTC_SERVER_DIR_CRON_FILE" 'root' 'root' '' '644'
    fi
}
