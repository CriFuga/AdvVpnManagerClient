#ifndef ADVVPNGROUPPROXYMODEL_H
#define ADVVPNGROUPPROXYMODEL_H


#include <qsortfilterproxymodel.h>

class AdvVpnGroupProxyModel : public QSortFilterProxyModel {
    Q_OBJECT

public:

    explicit AdvVpnGroupProxyModel(QObject *parent = nullptr);

protected:

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
};

#endif // ADVVPNGROUPPROXYMODEL_H
