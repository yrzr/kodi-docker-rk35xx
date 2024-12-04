#!/bin/sh

SETTING_FOLDER=/usr/local/share/kodi/portable_data/userdata
SETTING_FILE=${SETTING_FOLDER}/guisettings.xml

if [ ! -f ${SETTING_FILE} ]; then
    mkdir -p ${SETTING_FOLDER}

    cat <<EOL >${SETTING_FILE}
<settings version="2">
    <setting id="videoplayer.useprimedecoder">true</setting>
    <setting id="videoplayer.useprimedecoderforhw" default="true">true</setting>
    <setting id="videoplayer.useprimerenderer">0</setting>
</settings>
EOL
fi

XML_CONTENT=$(cat ${SETTING_FILE})

# enable webserver
if [ -n "$WEBSERVER_ENABLED" ]; then
    if ! grep -q 'setting id="services.webserver"' ${SETTING_FILE}; then
        XML_CONTENT=$(echo "$XML_CONTENT" | sed '/<\/settings>/i \    <setting id="services.webserver">'$WEBSERVER_ENABLED'</setting>')
    else
        XML_CONTENT=$(echo "$XML_CONTENT" | sed 's/<setting id="services.webserver">[^<]*<\/setting>/<setting id="services.webserver">'$WEBSERVER_ENABLED'<\/setting>/')
    fi
fi
# webserver port
if [ -n "$WEBSERVER_PORT" ]; then
    if ! grep -q 'setting id="services.webserverport"' ${SETTING_FILE}; then
        XML_CONTENT=$(echo "$XML_CONTENT" | sed '/<\/settings>/i \    <setting id="services.webserverport" default="true">'$WEBSERVER_PORT'</setting>')
    else
        XML_CONTENT=$(echo "$XML_CONTENT" | sed 's/<setting id="services.webserverport" default="true">[^<]*<\/setting>/<setting id="services.webserverport" default="true">'$WEBSERVER_PORT'<\/setting>/')
    fi
fi
# set webserver authentication
if [ -n "$WEBSERVER_AUTHENTICATION" ]; then
    if ! grep -q 'setting id="services.webserverauthentication"' ${SETTING_FILE}; then
        XML_CONTENT=$(echo "$XML_CONTENT" | sed '/<\/settings>/i \    <setting id="services.webserverauthentication" default="true">'$WEBSERVER_AUTHENTICATION'</setting>')
    else
        XML_CONTENT=$(echo "$XML_CONTENT" | sed 's/<setting id="services.webserverauthentication"  default="true">[^<]*<\/setting>/<setting id="services.webserverauthentication" default="true">'$WEBSERVER_AUTHENTICATION'<\/setting>/')
    fi
fi
# set webserver username and password
if [ -n "$WEBSERVER_USERNAME" ]; then
    if ! grep -q 'setting id="services.webserverusername"' ${SETTING_FILE}; then
        XML_CONTENT=$(echo "$XML_CONTENT" | sed '/<\/settings>/i \    <setting id="services.webserverusername" default="true">'$WEBSERVER_USERNAME'</setting>')
    else
        XML_CONTENT=$(echo "$XML_CONTENT" | sed 's/<setting id="services.webserverusername" default="true">[^<]*<\/setting>/<setting id="services.webserverusername" default="true">'$WEBSERVER_USERNAME'<\/setting>/')
    fi
fi
if [ -n "$WEBSERVER_PASSWORD" ]; then
    if ! grep -q '<setting id="services.webserverpassword">' ${SETTING_FILE}; then
        XML_CONTENT=$(echo "$XML_CONTENT" | sed '/<\/settings>/i \    <setting id="services.webserverpassword">'$WEBSERVER_PASSWORD'</setting>')
    else
        XML_CONTENT=$(echo "$XML_CONTENT" | sed 's/<setting id="services.webserverpassword">[^<]*<\/setting>/<setting id="services.webserverpassword">'$WEBSERVER_PASSWORD'<\/setting>/')
    fi
fi

echo "$XML_CONTENT" >${SETTING_FILE}

exec /usr/local/bin/kodi-standalone "$@"
