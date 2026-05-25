import 'package:flutter/material.dart';

// 阴影常量
class AppShadows {
  // 小阴影
  static const sm = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 2,
    color: Color.fromRGBO(0, 0, 0, 0.05),
  );
  
  // 中阴影
  static const md = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 8,
    color: Color.fromRGBO(0, 0, 0, 0.08),
  );
  
  // 大阴影
  static const lg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 24,
    color: Color.fromRGBO(0, 0, 0, 0.12),
  );
}