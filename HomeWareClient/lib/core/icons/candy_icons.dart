import 'package:flutter/material.dart';

/// 糖果轻点 — 圆润 Material Icons 映射（全站统一用 rounded 变体）
abstract final class CandyIcons {
  static IconData rounded(IconData icon) {
    return _map[icon] ?? icon;
  }

  // —— 导航 / 通用 ——
  static const add = Icons.add_rounded;
  static const arrowBack = Icons.arrow_back_rounded;
  static const arrowBackIos = Icons.arrow_back_ios_new_rounded;
  static const chevronRight = Icons.chevron_right_rounded;
  static const close = Icons.close_rounded;
  static const expandMore = Icons.expand_more_rounded;
  static const expandLess = Icons.expand_less_rounded;
  static const keyboardArrowDown = Icons.keyboard_arrow_down_rounded;
  static const keyboardArrowRight = Icons.keyboard_arrow_right_rounded;
  static const tune = Icons.tune_rounded;
  static const verticalAlignTop = Icons.vertical_align_top_rounded;
  static const fullscreen = Icons.fullscreen_rounded;

  // —— 首页 / 物品 ——
  static const home = Icons.home_rounded;
  static const kitchen = Icons.kitchen_rounded;
  static const storefront = Icons.storefront_rounded;
  static const inventory = Icons.inventory_2_rounded;
  static const stock = Icons.inventory_rounded;
  static const category = Icons.category_rounded;
  static const search = Icons.search_rounded;
  static const searchOff = Icons.search_off_rounded;
  static const place = Icons.place_rounded;
  static const event = Icons.event_rounded;
  static const calendar = Icons.calendar_today_rounded;
  static const qrScan = Icons.qr_code_scanner_rounded;
  static const qrCode = Icons.qr_code_rounded;
  static const qrCode2 = Icons.qr_code_2_rounded;
  static const removeCircle = Icons.remove_circle_rounded;
  static const restore = Icons.restore_rounded;
  static const edit = Icons.edit_rounded;
  static const editNote = Icons.edit_note_rounded;
  static const mic = Icons.mic_rounded;
  static const photoCamera = Icons.photo_camera_rounded;
  static const photoLibrary = Icons.photo_library_rounded;
  static const cameraAlt = Icons.camera_alt_rounded;
  static const addPhoto = Icons.add_a_photo_rounded;
  static const brokenImage = Icons.broken_image_rounded;
  static const shoppingBag = Icons.shopping_bag_rounded;
  static const table = Icons.table_chart_rounded;
  static const list = Icons.list_alt_rounded;
  static const flashOn = Icons.flash_on_rounded;
  static const flashOff = Icons.flash_off_rounded;

  // —— 提醒 / 通知 ——
  static const notifications = Icons.notifications_rounded;
  static const notificationsActive = Icons.notifications_active_rounded;
  static const schedule = Icons.schedule_rounded;
  static const taskAlt = Icons.task_alt_rounded;
  static const check = Icons.check_circle_rounded;
  static const error = Icons.error_outline_rounded;

  // —— 管管 / 首页装饰 ——
  static const fire = Icons.local_fire_department_rounded;
  static const eco = Icons.eco_rounded;
  static const celebration = Icons.celebration_rounded;
  static const emoji = Icons.emoji_emotions_rounded;
  static const people = Icons.people_rounded;
  static const lightbulb = Icons.lightbulb_rounded;
  static const backpack = Icons.backpack_rounded;
  static const circle = Icons.circle;

  // —— 个人 / 统计 ——
  static const campaign = Icons.campaign_rounded;
  static const barChart = Icons.bar_chart_rounded;
  static const insights = Icons.insights_rounded;
  static const shoppingCart = Icons.shopping_cart_rounded;
  static const checklist = Icons.checklist_rounded;
  static const factCheck = Icons.fact_check_rounded;
  static const groups = Icons.groups_rounded;
  static const leaderboard = Icons.leaderboard_rounded;
  static const settings = Icons.settings_rounded;
  static const inbox = Icons.inbox_rounded;
  static const download = Icons.download_rounded;
  static const upload = Icons.upload_file_rounded;
  static const description = Icons.description_rounded;
  static const palette = Icons.palette_rounded;
  static const info = Icons.info_rounded;
  static const label = Icons.label_rounded;
  static const wallet = Icons.account_balance_wallet_rounded;
  static const addBox = Icons.add_box_rounded;
  static const trendingDown = Icons.trending_down_rounded;
  static const cloudDone = Icons.cloud_done_rounded;
  static const cloudSync = Icons.cloud_sync_rounded;
  static const cloudOff = Icons.cloud_off_rounded;
  static const copy = Icons.copy_rounded;
  static const refresh = Icons.refresh_rounded;
  static const key = Icons.key_rounded;
  static const share = Icons.ios_share_rounded;
  static const deleteOutline = Icons.delete_outline_rounded;
  static const delete = Icons.delete_rounded;
  static const moreVert = Icons.more_vert_rounded;
  static const emojiEvents = Icons.emoji_events_rounded;
  static const militaryTech = Icons.military_tech_rounded;
  static const workspacePremium = Icons.workspace_premium_rounded;
  static const removeCircleOutline = Icons.remove_circle_outline_rounded;

  // —— 认证 ——
  static const visibility = Icons.visibility_rounded;
  static const visibilityOff = Icons.visibility_off_rounded;

  static final _map = <IconData, IconData>{
    Icons.add: add,
    Icons.arrow_back: arrowBack,
    Icons.arrow_back_ios: arrowBackIos,
    Icons.chevron_right: chevronRight,
    Icons.close: close,
    Icons.expand_more: expandMore,
    Icons.expand_less: expandLess,
    Icons.keyboard_arrow_down: keyboardArrowDown,
    Icons.keyboard_arrow_right: keyboardArrowRight,
    Icons.tune: tune,
    Icons.vertical_align_top: verticalAlignTop,
    Icons.fullscreen: fullscreen,
    Icons.home_outlined: home,
    Icons.home: home,
    Icons.kitchen_outlined: kitchen,
    Icons.storefront_outlined: storefront,
    Icons.inventory_2_outlined: inventory,
    Icons.inventory_2: inventory,
    Icons.inventory_outlined: stock,
    Icons.category_outlined: category,
    Icons.search: search,
    Icons.search_off: searchOff,
    Icons.place_outlined: place,
    Icons.event_outlined: event,
    Icons.calendar_today: calendar,
    Icons.qr_code_scanner_outlined: qrScan,
    Icons.qr_code: qrCode,
    Icons.qr_code_2: qrCode2,
    Icons.remove_circle_outline: removeCircleOutline,
    Icons.restore_outlined: restore,
    Icons.edit_outlined: edit,
    Icons.edit_note_outlined: editNote,
    Icons.mic_none_outlined: mic,
    Icons.photo_camera_outlined: photoCamera,
    Icons.photo_library_outlined: photoLibrary,
    Icons.camera_alt_outlined: cameraAlt,
    Icons.add_a_photo_outlined: addPhoto,
    Icons.broken_image_outlined: brokenImage,
    Icons.shopping_bag_outlined: shoppingBag,
    Icons.table_chart_outlined: table,
    Icons.list_alt_outlined: list,
    Icons.flash_on: flashOn,
    Icons.flash_off: flashOff,
    Icons.notifications_outlined: notifications,
    Icons.notifications: notifications,
    Icons.notifications_active_outlined: notificationsActive,
    Icons.schedule_outlined: schedule,
    Icons.task_alt_outlined: taskAlt,
    Icons.check_circle_outline: check,
    Icons.error_outline: error,
    Icons.local_fire_department_outlined: fire,
    Icons.eco_outlined: eco,
    Icons.celebration_outlined: celebration,
    Icons.emoji_emotions_outlined: emoji,
    Icons.people_outline: people,
    Icons.lightbulb_outline: lightbulb,
    Icons.backpack_outlined: backpack,
    Icons.campaign_outlined: campaign,
    Icons.bar_chart_outlined: barChart,
    Icons.insights_outlined: insights,
    Icons.shopping_cart_outlined: shoppingCart,
    Icons.checklist_outlined: checklist,
    Icons.fact_check_outlined: factCheck,
    Icons.groups_outlined: groups,
    Icons.leaderboard_outlined: leaderboard,
    Icons.settings_outlined: settings,
    Icons.inbox_outlined: inbox,
    Icons.download_outlined: download,
    Icons.download: download,
    Icons.upload_file_outlined: upload,
    Icons.description_outlined: description,
    Icons.palette_outlined: palette,
    Icons.info_outline: info,
    Icons.label_outlined: label,
    Icons.account_balance_wallet_outlined: wallet,
    Icons.add_box_outlined: addBox,
    Icons.trending_down_outlined: trendingDown,
    Icons.cloud_done_outlined: cloudDone,
    Icons.cloud_sync_outlined: cloudSync,
    Icons.cloud_off_outlined: cloudOff,
    Icons.copy_outlined: copy,
    Icons.refresh_outlined: refresh,
    Icons.key_outlined: key,
    Icons.ios_share_outlined: share,
    Icons.delete_outline: deleteOutline,
    Icons.delete: delete,
    Icons.more_vert: moreVert,
    Icons.emoji_events_outlined: emojiEvents,
    Icons.military_tech_outlined: militaryTech,
    Icons.workspace_premium_outlined: workspacePremium,
    Icons.add_circle_outline: Icons.add_circle_rounded,
    Icons.visibility_outlined: visibility,
    Icons.visibility_off_outlined: visibilityOff,
    Icons.clear: close,
  };
}
