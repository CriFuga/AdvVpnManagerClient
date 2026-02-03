#include "vpnaction.h"

QString actionTypeToString(VpnAction::Type type) {
    switch (type) {
    case VpnAction::CreateGroup:
        return "ADD_GROUP";    // Deve corrispondere al server!
    case VpnAction::DeleteGroup:
        return "DEL_GROUP";    // Coerente con ADVVpnManagerServer
    case VpnAction::RenameGroup:
        return "RENAME_GROUP";
    case VpnAction::AddIp:
        return "ADD_IP";       //
    case VpnAction::DeleteIp:
        return "DEL_IP";       //
    case VpnAction::UpdateIp:
        return "RENAME_IP";    //
    case VpnAction::UpdateId:
        return "SET_ID";       // Cruciale per handleUpdateCn
    default:
        return "UNKNOWN";
    }
}
