#include "advvpnitemproxymodel.h"
#include "advvpnitemmodel.h"

AdvVpnItemProxyModel::AdvVpnItemProxyModel(QObject *parent) : QSortFilterProxyModel(parent) {
    setDynamicSortFilter(true);
}

bool AdvVpnItemProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const {
    QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);

    bool isHidden = sourceModel()->data(idx, AdvVpnItemModel::IsHiddenRole).toBool();

    return !isHidden;
}
