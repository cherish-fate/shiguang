# 前后端接口对比 (openapi.yaml vs ApiService.ets)

本文档根据 entry/docs/openapi.yaml 与 entry/src/main/ets/services/ApiService.ets 进行对比。

## 概览
- 前端定义接口: 21
- OpenAPI 定义接口: 29
- 直接匹配: 4
- 前端存在但 OpenAPI 未定义: 17
- OpenAPI 存在但前端未实现: 25

## 直接匹配 (路径+方法一致)
| 前端 | OpenAPI | 备注 |
| --- | --- | --- |
| GET /agreement/content?type= | GET /agreement/content | 一致 |
| POST /user/register | POST /user/register | 一致 |
| POST /user/login | POST /user/login | 一致 |
| POST /file/upload | POST /file/upload | 一致 |

## 前端存在但 OpenAPI 未定义
| 前端 | 可能对应 | 备注 |
| --- | --- | --- |
| POST /user/send-code | POST /sms/sendCode | 路径不同 (user vs sms) |
| GET /capsules/nearby | 无 | OpenAPI 未见 nearby 列表 |
| POST /capsules | POST /capsule/create | 路径不同 (capsules vs capsule) |
| GET /capsules?campus= | GET /capsule/list | 路径不同 (capsules vs capsule) |
| GET /capsules/nearby?latitude=&longitude=&radius= | 无 | OpenAPI 未见附近接口 |
| GET /map/emotion-stream | 无 | OpenAPI 只有 /map/capsules, /map/stats |
| GET /capsules/{id}/comments | GET /capsule/replies | 路径与参数形式不同 |
| POST /capsules/{id}/comments | POST /capsule/reply | 路径与参数形式不同 |
| POST /capsules/{id}/favorite | POST /capsule/like | 路径不同 |
| GET /user/profile | POST /user/info | 方法与路径不同 |
| PUT /user/profile | POST /user/update | 方法与路径不同 |
| PUT /user/password | POST /user/password | 方法不同 |
| GET /user/stats | 无 | OpenAPI 未定义 |
| GET /user/capsules | GET /capsule/my | 路径不同 |
| GET /user/favorites | 无 | OpenAPI 未定义 |
| POST /ai/polish | POST /ai/rewrite | 路径不同 |
| POST /ai/asr | POST /ai/voice/optimize | 路径不同 |

## OpenAPI 存在但前端未实现
| OpenAPI | 备注 |
| --- | --- |
| GET / | 前端未实现 |
| GET /health | 前端未实现 |
| GET /db/probe | 前端未实现 |
| GET /user/register | 前端未实现 |
| POST /user/login/harmony | 前端未实现 |
| POST /user/logout | 前端未实现 |
| POST /user/info | 前端未实现 |
| POST /user/update | 前端未实现 |
| POST /user/password | 前端未实现 (前端为 PUT) |
| POST /capsule/create | 前端未实现 (前端为 /capsules) |
| GET /capsule/list | 前端未实现 (前端为 /capsules) |
| GET /capsule/detail | 前端未实现 |
| POST /capsule/like | 前端未实现 (前端为 /capsules/{id}/favorite) |
| DELETE /capsule/delete | 前端未实现 |
| POST /capsule/batch | 前端未实现 |
| GET /capsule/my | 前端未实现 (前端为 /user/capsules) |
| POST /capsule/export | 前端未实现 |
| POST /capsule/location/bind | 前端未实现 |
| POST /capsule/reply | 前端未实现 (前端为 /capsules/{id}/comments) |
| GET /capsule/replies | 前端未实现 (前端为 /capsules/{id}/comments) |
| GET /map/capsules | 前端未实现 |
| GET /map/stats | 前端未实现 |
| POST /ai/narrative | 前端未实现 |
| POST /ai/emotion | 前端未实现 |
| POST /ai/rewrite | 前端未实现 (前端为 /ai/polish) |
| POST /ai/voice/optimize | 前端未实现 (前端为 /ai/asr) |
| POST /ai/code/format | 前端未实现 |
| POST /sms/sendCode | 前端未实现 (前端为 /user/send-code) |

## 结论
- 当前前端接口命名和路径与 OpenAPI 存在系统性不一致 (capsule(s)、user/sms、map、ai 模块)。
- 登录 404 更可能来自路径或服务前缀不一致，而非服务未启动。

## 建议下一步
- 确认后端实际路由是否以 OpenAPI 为准。
- 选定对齐方向: 以 OpenAPI 改前端，或更新 OpenAPI 匹配现有前端。

---

# 前后端接口对比 (openapi-new-features.yaml vs ApiService.ets)

本文档根据 entry/docs/openapi-new-features.yaml 与 entry/src/main/ets/services/ApiService.ets 进行对比。

## 概览
- OpenAPI (新增) 定义接口: 12
- 直接匹配: 1
- OpenAPI (新增) 存在但前端未实现: 11
- 前端存在但 OpenAPI (新增) 未定义: 0

## 直接匹配 (路径+方法一致)
| 前端 | OpenAPI (新增) | 备注 |
| --- | --- | --- |
| GET /map/emotion-stream | GET /map/emotion-stream | 一致 |

## OpenAPI (新增) 存在但前端未实现
| OpenAPI (新增) | 备注 |
| --- | --- |
| GET /capsule/nearby | 前端为 /capsules/nearby, 参数名为 radius 而非 radiusMeters |
| GET /capsule/popup | 前端未实现 |
| GET /capsule/reply/notifications | 前端未实现 |
| POST /capsule/reply/notifications/read | 前端未实现 |
| GET /profile/capsules/published | 前端未实现 |
| GET /profile/capsules/favorites | 前端未实现 |
| GET /profile/emotion/distribution | 前端未实现 |
| GET /profile/emotion/weekly-report | 前端未实现 |
| GET /pc/connect/request | 前端未实现 |
| POST /pc/connect/confirm | 前端未实现 |
| POST /capsule/privacy/update | 前端未实现 |

## 结论
- 新增接口中，前端仅实现了 /map/emotion-stream，其余功能尚未接入或路径不一致。
