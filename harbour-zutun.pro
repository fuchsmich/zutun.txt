# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-zutun

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-zutun.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-zutun.spec \
    rpm/harbour-zutun.yaml \
    translations/*.ts \
    harbour-zutun.desktop \
    qml/pages/Settings.qml \
    qml/pages/TaskEdit.qml \
    qml/pages/TaskList.qml \
    qml/pages/TextSelect.qml \
    qml/pages/OtherFilters.qml \
    qml/pages/FiltersPage.qml \
    qml/cover/zutun.png \
    qml/tdt/todotxt.js \
    rpm/harbour-zutun.changes \
    qml/tdt/TodoTxt.qml \
    qml/pages/About.qml \
    qml/pages/SortPage.qml \
    qml/tdt/FileIO.qml \
    qml/python/fileio.py \
    qml/tdt/Notification.qml \
    icons/harbour-zutun.svg \
    qml/pages/DateSelect.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += \
    translations/harbour-zutun-de.ts \
    translations/harbour-zutun-es.ts \
    translations/harbour-zutun-fr.ts \
    translations/harbour-zutun-nl.ts \
    translations/harbour-zutun-nl_BE.ts \
    translations/harbour-zutun-ru.ts \
    translations/harbour-zutun-sv.ts

HEADERS +=

quickaction.path = /usr/share/lipstick/quickactions
quickaction.files = info.fuxl.zutuntxt.conf

INSTALLS += quickaction
