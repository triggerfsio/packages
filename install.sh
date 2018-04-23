#!/bin/bash

ui=whiptail
ui=dialog
set TERM=vt220

DOWNLOAD_GITHUB_URL=https://api.github.com/repos/begriffs/postgrest/releases/latest

for i in dialog wget curl
do
    which $i > /dev/null
    if [ "$?" != 0 ] ; then
        missing_at_least_one=1
        echo "Missing packages: Looks like the package $i is not installed on this system. Please install $i and restart the installer."
    fi
done
if [ ! -z ${missing_at_least_one} ] ; then
    exit 2
fi



${ui} --title "Official triggerFS Installer" --ok-label "Proceed" --msgbox "Welcome to triggerFS.

A realtime messaging and distributed trigger system.

ATTENTION:
This application is in beta testing. You will be notified if the testing period is over.

Limitations:
As long as the testing is ongoing all features are enabled. The only limitation is one team creation per user!
" 18 80

function check_exitstatus {
    exitstatus=$?
    if [ $exitstatus != 0 ]; then
        main
    fi
}

function activate_account {
    email=$1
    ACTIVATIONCODE=$(${ui} --title "Activate account" --inputbox "please insert your activation code" 0 0 3>&2 2>&1 1>&3)
    check_exitstatus
    if [ ! -z "${ACTIVATIONCODE}" ] ; then
        RET=$(curl -sXPOST localhost:8080/rpc/activate_account -H "Content-Type: application/json" -d '{"email": "'"${email}"'", "activationcode": "'"${ACTIVATIONCODE}"'"}' | python -mjson.tool | sed 's/"//g')
        ${ui} --title "Signup" --msgbox "${RET}" 0 0
        if [ "${RET}" == "Account has been activated" ] ; then
             ${ui} --title "Activate account" --msgbox "Congratulations! Your account has been activated.

You automatically start with the free plan which is enabled for as long as triggerFS is in alpha/testing stage.

Alpha Testing Phase/Free Plan includes:
* 1 free team creation
* Unlimited access to all features

You will find the official triggerFS documentation at https://triggerfs.io.

Happy triggering!
             " 0 0
             main
        fi
    fi
}

function do_signup {
    ${ui} --title "Signup" --msgbox "To sign up for triggerFS you need to provide an identity, your email address and a password.


    * the identity will be the string you will use to log into your 
      account. it has to be at least 5 characters in length and
      must contain only strings and numbers (^[A-Za-z0-9]+$)

    * the given email address must be a valid email address 
      and will be used to activate your account

    * the password has to be at least 12 characters in length" 0 0

    check_exitstatus
    IDENTITY=$(${ui} --title "Choose identity" --inputbox "please choose an identity" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus
    NAME=$(${ui} --title "Your name" --inputbox "please provide your name (optional)" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus
    EMAIL=$(${ui} --title "Enter email address" --inputbox "please enter your email address" 0 0 3>&2 2>&1 1>&3)
    check_exitstatus
    PASSWORD=$(${ui} --title "Enter password" --clear --insecure --passwordbox "please enter your secret password" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus
    PASSWORD2=$(${ui} --title "Repeat password" --clear --insecure --passwordbox "repeat secret password" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus

    if [ -z "${NAME}" ] ; then
        NAME=""
    fi
    if [ "${PASSWORD}" == "${PASSWORD2}" ] ; then
        RET=$(curl -sXPOST http://localhost:8080/rpc/signup -H "Content-Type: application/json" -d '{"identity": "'"${IDENTITY}"'","name":"'"${NAME}"'", "email": "'"${EMAIL}"'", "password": "'"${PASSWORD}"'"}' | python -mjson.tool | sed 's/"//g')
        if [ "${RET}" == "Signup successful" ] ; then
            ${ui} --title "Signup" --msgbox "Signup successful" 0 0
            ${ui} --title "Activation Code" --msgbox "An activation code is on its way to you.

Please check your mailbox and copy your activation code to proceed with activating your account next." 0 0
            activate_account ${EMAIL}
        fi
    else
        ${ui} --title "Password mismatch" --msgbox "Passwords don't match." --ok-button "Cancel" 0 0
    fi
}

function login {
    ${ui} --title "Login" --msgbox "You will be prompted for your identity and password now." 0 0
    IDENTITY=$(${ui} --title "Enter identity" --inputbox "please enter your identity" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus
    PASSWORD=$(${ui} --title "Enter password" --clear --insecure --passwordbox "please enter your password" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus

    RET=$(curl -sXPOST http://localhost:8080/rpc/login -H "Content-Type: application/json" -d '{"type": "user", "identity": "'"${IDENTITY}"'", "secret": "'"${PASSWORD}"'"}' | python -mjson.tool)
    TMPRET=$( echo ${RET} | python -mjson.tool | grep token | awk -F':' '{print $NF}' | sed 's/[ "]//g')
    if [ -z "${TMPRET}" ] ; then
        ${ui} --title "Login" --msgbox "${RET}" 0 0
        login
    else
        ${ui} --title "Login" --msgbox "Login successful." 0 0
        JWT=${TMPRET}
    fi
}

function create_team {
   ${ui} --title "Create Team" --msgbox "A team is your own space in the triggerFS world, your own environment where you manage your own platform.

Every user needs a team to be able to use triggerFS. Beside joining other teams, where you are just a member of another team, managed by other people,
your own team exclusively belongs to you and everything within it. That means, no one can access your workers, services or any other thing.

After creating your own team you will:
* have an isolated environment to work with triggerFS
* be the admin of your team
* be able to create workers, services, triggers
* communicate with your services within that team

Continue with creating your own team now.
    " 24 78

    TEAMNAME=$(${ui} --title "Create Team" --inputbox "please choose a name for your team" 0 0  3>&2 2>&1 1>&3)
    check_exitstatus
    if [ -z "${TEAMNAME}" ] ; then
        create_team
    else
        RET=$(curl -XPOST http://localhost:8080/rpc/create_team -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" -d '{"name": "'"${TEAMNAME}"'"}')
        if [ -z "${RET}" ] ; then
            ${ui} --title "Create Team" --msgbox "Team has been created." 0 0
            ${ui} --title "Create Team" --ok-label "Exit" --msgbox "Congratulations. You are now ready to use triggerFS. 
Check out the official triggerfs documentation at https://triggerfs.io

Happy triggering!" 0 0
        exit 0
        else
            ${ui} --title "Create Team" --msgbox "${RET}" 0 0
        fi
        # TMPRET=$( echo ${RET} | python -mjson.tool | grep token | awk -F':' '{print $NF}' | sed 's/[ "]//g')
        # if [ -z "${TMPRET}" ] ; then
        #     ${ui} --title "Login" --msgbox "${RET}" 0 0
        #     login
        # else
        #     ${ui} --title "Login" --msgbox "Login successful." 0 0
        #     JWT=${TMPRET}
        # fi
    fi
}

function download_modules {
    ${ui} --title "Starting download" --ok-button "Continue" --msgbox "Starting download of modules now" 0 0
    dirpath=$1
    for i in $(curl -s ${DOWNLOAD_GITHUB_URL} | grep browser_download_url | cut -d '"' -f 4)
    do
        wget $i -P ${dirpath} 2>&1 |  stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' |  ${ui} --gauge "Downloading module $(echo $i | awk -F'/' '{ print $NF}')" 0 100
    done
}

function main {
    status="0"
    while [ "$status" -eq 0 ]  
    do
        choice=$(${ui} --title "Official triggerFS Installer" --menu "Choose option" 16 78 5 \
        "Signup" "Register a new account" \
        "Activate Account" "Activate existing account with an activation code" \
        "Create Team" "Create a team and start using triggerFS" \
        "Download modules" "Download all triggerFS modules" 3>&2 2>&1 1>&3) 
            
        # Change to lower case and remove spaces.
        option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
        case "${option}" in
            signup) 
                do_signup
            ;;
            activateaccount)
                EMAIL=$(${ui} --title "Enter email address" --inputbox "please enter your email address" 0 0 3>&2 2>&1 1>&3)
                check_exitstatus
                if [ ! -z "${EMAIL}" ] ; then
                    activate_account ${EMAIL}
                fi
            ;;
            createteam)
                if [ -z "${JWT}" ] ; then
                    login
                fi
                create_team
            ;;
            downloadmodules)
                ${ui} --title "Download triggerFS modules" --msgbox "This will download all four triggerFS modules in a directory of your choice.

The binaries are statically linked so you shouldn't need any dependencies for them to work.
If you experience problems with running the binaries please do not hesitate to contact the triggerFS support at support@triggerfs.io.


Please notice that you can also use the official triggerFS docker images
at https://hub.docker.com/r/triggerfsio/ if you want to use docker instead." 0 0
            DIRPATH=$(${ui} --title "Download triggerFS modules" --inputbox "please specify a path to a directory" 0 0 3>&2 2>&1 1>&3)
                if [ ! -z "${DIRPATH}" ] ; then
                    if [ -d "${DIRPATH}" ] ; then
                        download_modules ${DIRPATH}
                    else
                        ${ui} --title "Download triggerFS modules" --msgbox "${DIRPATH} is not a valid path to a directory or directory does not exist" 0 0
                        main
                    fi
                fi
            ;;
            *) 
            # ${ui} --title "Testing" --msgbox "You cancelled or have finished." 0 0
                # status=1
                exit
            ;;
        esac
        exitstatus1=$status1
    done
}

main