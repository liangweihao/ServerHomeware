/// 空状态插画类型 — 与 assets/illustrations 下 SVG 一一对应
enum CartoonEmptyKind {
  items,
  search,
  alerts,
  family,
  error,
}

/// 卡通文案 — 空状态、提示语等温暖口语化
abstract final class CartoonCopy {
  /// 根据类型返回卡通化空状态文案
  static ({String title, String? subtitle, String? actionLabel})? emptyState(
    CartoonEmptyKind kind, {
    String? searchQuery,
  }) {
    switch (kind) {
      case CartoonEmptyKind.items:
        return (
          title: '箱子还是空的耶～',
          subtitle: '扫扫码或手动添加第一件宝贝吧！',
          actionLabel: '+ 添第一件宝贝',
        );
      case CartoonEmptyKind.search:
        final q = searchQuery ?? '';
        return (
          title: q.isNotEmpty ? '没找到「$q」呢' : '没找到相关物品',
          subtitle: '换个词试试，或者直接手动添加？',
          actionLabel: q.isNotEmpty ? '手动添加「$q」' : '手动添加',
        );
      case CartoonEmptyKind.alerts:
        return (
          title: '一切安好！',
          subtitle: '目前没有需要处理的提醒哦',
          actionLabel: null,
        );
      case CartoonEmptyKind.family:
        return (
          title: '还没有家庭成员',
          subtitle: '邀请家人一起管理物品吧～',
          actionLabel: '+ 邀请家人',
        );
      case CartoonEmptyKind.error:
        return (
          title: '哎呀，连接不太顺',
          subtitle: '检查一下网络再试试看？',
          actionLabel: '再试一次',
        );
    }
  }

  /// 通用 SnackBar 友好提示
  static String snackBar(String defaultMessage) {
    if (defaultMessage.contains('成功')) {
      return '搞定啦！$defaultMessage';
    }
    if (defaultMessage.contains('失败') || defaultMessage.contains('错误')) {
      return '哎呀，$defaultMessage';
    }
    return defaultMessage;
  }
}
