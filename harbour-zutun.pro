TARGET = harbour-zutun

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-zutun.qml \
    qml/components/ProjectContextModel.qml \
    qml/components/TaskModel.qml \
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
    version \
    qml/pages/DateSelect.qml \
    qml/components/EditItem.qml \
    qml/components/EditContextMenu.qml \
    qml/components/EditItemContextList.qml \
    qml/components/EditItemDatePicker.qml \
    qml/components/TaskListItem.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

CONFIG += sailfishapp_i18n

TRANSLATIONS += \
    translations/harbour-zutun-de.ts \
    translations/harbour-zutun-es.ts \
    translations/harbour-zutun-fr.ts \
    translations/harbour-zutun-nl.ts \
    translations/harbour-zutun-nl_BE.ts \
    translations/harbour-zutun-ru.ts \
    translations/harbour-zutun-sv.ts

quickaction.path = /usr/share/lipstick/quickactions
quickaction.files = info.fuxl.zutuntxt.conf

shortcut.path = /usr/share/jolla-settings/entries
shortcut.files = info.fuxl.zutuntxt.json

INSTALLS += quickaction shortcut
