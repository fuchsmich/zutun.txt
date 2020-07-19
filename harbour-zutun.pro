TARGET = harbour-zutun

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-zutun.qml \
    harbour-zutun.desktop \
    qml/components/CoverListItem.qml \
    qml/components/Delegate.qml \
    qml/components/NotificationList.qml \
    qml/pages/FiltersPage.qml \
    qml/pages/TaskEditPage.qml \
    qml/pages/TaskListPage.qml \
    qml/tdt/Filters.qml \
    qml/tdt/Sorting.qml \
    qml/tdt/TaskDelegateModel.qml \
    qml/tdt/TaskListModel.qml \
    translations/*.ts \
    rpm/harbour-zutun.spec \
    rpm/harbour-zutun.yaml \
    rpm/harbour-zutun.changes \
    qml/cover/CoverPage.qml \
    qml/cover/zutun.png \
    qml/tdt/todotxt.js \
    qml/tdt/FileIO.qml \
    qml/components/Notification.qml \
    qml/pages/Settings.qml \
    qml/pages/TextSelect.qml \
    qml/pages/OtherFilters.qml \
    qml/pages/About.qml \
    qml/pages/SortPage.qml \
    qml/pages/DateSelect.qml \
    qml/python/fileio.py \
    icons/harbour-zutun.svg \
    version \
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
#//TODO mf: harbour-zutun.ts SEEMS not TO BE included when adding comments for translators?
#//TODO mf: Swedish version is not included when adding comments for translators

quickaction.path = /usr/share/lipstick/quickactions
quickaction.files = info.fuxl.zutuntxt.conf

shortcut.path = /usr/share/jolla-settings/entries
shortcut.files = info.fuxl.zutuntxt.json

INSTALLS += quickaction shortcut
