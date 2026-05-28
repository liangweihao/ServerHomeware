# 删除家庭功能 - Product Requirement Document

## Overview
- **Summary**: 实现 DELETE /api/v1/families/{familyId} 接口的前端调用和相关业务逻辑，包括添加 confirm_name 参数支持
- **Purpose**: 根据设计文档 Phase 3 的要求，完善删除家庭功能，支持输入家庭名称作为二次确认
- **Target Users**: 家庭所有者（owner）

## Goals
- [Primary goal 1] 更新 FamilyService.deleteFamily 方法，添加 confirm_name 参数
- [Primary goal 2] 更新前端调用逻辑，传递用户输入的确认名称
- [Primary goal 3] 添加完整的日志和注释

## Non-Goals (Out of Scope)
- 删除成员功能
- 转让所有权功能
- 其他家庭管理功能

## Background & Context
- 后端已实现 DELETE /api/v1/families/{familyId} 接口，需要 confirm_name 参数
- 前端已有完整的 UI 界面和删除确认对话框
- 需要按照 codestyle.mdc 要求添加注释和日志

## Functional Requirements
- **FR-1**: FamilyService.deleteFamily 方法接收并传递 confirm_name 参数
- **FR-2**: _handleDeleteFamily 方法传递用户输入的家庭名称
- **FR-3**: 添加完整的业务日志
- **FR-4**: 添加必要的代码注释

## Non-Functional Requirements
- **NFR-1**: 代码符合项目规范
- **NFR-2**: 保持现有功能完整性

## Constraints
- **Technical**: 遵循现有代码架构
- **Business**: 遵循设计文档规范
- **Dependencies**: 后端已实现对应接口

## Assumptions
- 用户会正确输入家庭名称进行确认
- 后端接口已正常工作

## Acceptance Criteria

### AC-1: 删除家庭功能正常工作
- **Given**: 用户是家庭所有者且不是当前家庭
- **When**: 用户点击删除家庭并正确输入家庭名称确认
- **Then**: 家庭被成功删除，UI 正确更新
- **Verification**: `human-judgment`

### AC-2: 接口参数正确传递
- **Given**: 用户点击确认删除
- **When**: 调用后端接口
- **Then**: confirm_name 参数正确传递
- **Verification**: `programmatic`

### AC-3: 日志和注释完整
- **Given**: 代码执行
- **When**: 删除家庭功能被调用
- **Then**: 日志正确打印，注释清晰
- **Verification**: `human-judgment`

## Open Questions
- 无

