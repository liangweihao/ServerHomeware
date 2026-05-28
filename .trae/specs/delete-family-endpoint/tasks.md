# 删除家庭功能 - The Implementation Plan (Decomposed and Prioritized Task List)

## [ ] Task 1: 更新 FamilyService.deleteFamily 方法
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 修改 deleteFamily 方法签名，添加 confirmName 参数
  - 更新接口调用，在请求 body 中传递 confirm_name
  - 添加完整的业务日志
  - 添加代码注释
- **Acceptance Criteria Addressed**: [FR-1, FR-3, FR-4]
- **Test Requirements**:
  - `programmatic` TR-1.1: 方法能正确接收并传递 confirmName 参数
  - `human-judgement` TR-1.2: 日志和注释符合规范
- **Notes**: 保持向后兼容，但实际上前端必须传递该参数

## [ ] Task 2: 更新 _handleDeleteFamily 调用
- **Priority**: P0
- **Depends On**: [Task 1]
- **Description**: 
  - 修改 _handleDeleteFamily 方法，传递家庭名称
  - 更新相关调用逻辑
  - 添加日志
- **Acceptance Criteria Addressed**: [FR-2, FR-3, FR-4]
- **Test Requirements**:
  - `programmatic` TR-2.1: 家庭名称被正确传递给 service
  - `human-judgement` TR-2.2: 日志和注释符合规范
- **Notes**: 确保正确传递用户输入的家庭名称

## [ ] Task 3: 验证代码质量
- **Priority**: P1
- **Depends On**: [Task 1, Task 2]
- **Description**: 
  - 运行 flutter analyze 检查代码
  - 确保无编译错误
  - 验证功能完整性
- **Acceptance Criteria Addressed**: [NFR-1, NFR-2]
- **Test Requirements**:
  - `programmatic` TR-3.1: flutter analyze 通过
  - `human-judgement` TR-3.2: 代码符合项目规范

