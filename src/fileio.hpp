#ifndef FILEIO_H
#define FILEIO_H

#include <QString>
#include <QFile>
#include <QTextStream>
#include <QUrl>
#include <QDebug>

class FileIO : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString content READ readContent WRITE writeContent NOTIFY contentChanged)

public:
    explicit FileIO(QObject *parent = 0)
        :QObject(parent)    {}
    QUrl path() { return m_path; }
    void setPath(const QUrl &path) {
        m_path = path;
        emit pathChanged();
        emit contentChanged();
    }

    //TODO !!check, ob datei/pfad existiert etc...
    //TODO fehlermeldungen rückmelden
    QString readContent() {
        QString m_content = "";
        if (!m_path.isEmpty()) {
            qDebug() << "reading content...";
            QFile textfile(m_path.path());
//            qDebug() << m_path.toString() << m_path.path();
            textfile.open(QIODevice::ReadOnly | QIODevice::Text);
            QTextStream in(&textfile);
            in.setCodec("UTF-8");
            m_content = in.readAll();
            textfile.close();
            qDebug() << "reading content...finished";
        }
//        qDebug() << m_content;
        return m_content;
    }

    void writeContent(const QString &data) {
        if (!m_path.isEmpty()) {
            qDebug() << "writing content...";
            QFile textfile(m_path.path());
            textfile.open(QIODevice::WriteOnly | QIODevice::Text);
            QTextStream out(&textfile);
            out.setCodec("UTF-8");
            out << data;
            textfile.close();
            qDebug() << "writing content...finished";
        }
        emit contentChanged();
    }

signals:
    void pathChanged();
    void contentChanged();

public slots:


private:
    QUrl m_path;

};

#endif // FILEIO_H
