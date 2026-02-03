#include "advvpngroupproxymodel.h"
#include "advvpngroupmodel.h"

AdvVpnGroupProxyModel::AdvVpnGroupProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
}

bool AdvVpnGroupProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const {
    QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);

    bool isHidden = sourceModel()->data(idx, AdvVpnGroupModel::IsHiddenRole).toBool();
    if (isHidden) return false;

    QString name = sourceModel()->data(idx, AdvVpnGroupModel::NameRole).toString();
    return name.contains(filterRegularExpression());
}
