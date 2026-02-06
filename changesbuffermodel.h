#ifndef CHANGESBUFFERMODEL_H
#define CHANGESBUFFERMODEL_H

#include <QAbstractListModel>
#include "changesbuffermanager.h"

class ChangesBufferModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        TypeRole = Qt::UserRole + 1,
        TargetIdRole,
        DescriptionRole,
        GroupIdRole,
        IsGroupActionRole
    };

    explicit ChangesBufferModel(ChangesBufferManager *manager, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void undo(int index);

private slots:
    void updateFullBuffer();

private:
    ChangesBufferManager *m_manager;
};

#endif // CHANGESBUFFERMODEL_H
