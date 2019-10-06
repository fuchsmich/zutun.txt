#include <QApplication>
#include <QQmlApplicationEngine>

#include "fileio.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName("fuxl.info");
    app.setOrganizationDomain("fuxl.info");
    app.setApplicationName("zutun.txt");

    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);


    return app.exec();
}
