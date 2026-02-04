#ifndef ADVVPNITEMPROXYMODEL_H
#define ADVVPNITEMPROXYMODEL_H

#include <QSortFilterProxyModel>

class AdvVpnItemProxyModel : public QSortFilterProxyModel {
    Q_OBJECT
public:
    explicit AdvVpnItemProxyModel(QObject *parent = nullptr);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
};

#endif
