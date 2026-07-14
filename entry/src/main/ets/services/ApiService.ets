import { promptAction } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import fs from '@ohos.file.fs'

// ============================================================
// 类型定义 —— 严格按照后端接口定义
// ============================================================

// --- 通用 ---
export interface ApiEnvelope<T> {
  code?: number
  message?: string
  data?: T
}

// --- SMS ---
export interface SendCodeRequest {
  phone: string
  type: 'register' | 'login'
}

export interface SendCodeResponse {
  success: boolean
}

// --- 用户注册/登录 ---
export interface RegisterRequest {
  avatar?: string
  nickname: string
  grade: string
  college: string
  phone: string
  code: string
  password: string
  agreeProtocol: boolean
}

export interface UserInfoBrief {
  userId: number
  phone: string
  nickname: string
  avatar: string
}

export interface RegisterResponse {
  token: string
  tokenType: string
  expiresIn: number
  userInfo: UserInfoBrief
}

export interface LoginRequest {
  phone: string
  code: string
  agreeProtocol: boolean
}

export interface LoginResponse {
  token: string
  tokenType: string
  expiresIn: number
  userInfo: UserInfoBrief
}

export interface HarmonyLoginRequest {
  authorizationCode: string
}

export interface HarmonyUserInfo {
  userId: number
  nickname: string
  avatar: string
  phone: string
  openId: string
}

export interface HarmonyLoginResponse {
  token: string
  tokenType: string
  expiresIn: number
  userInfo: HarmonyUserInfo
}

// --- 用户信息 ---
export interface UserProfile {
  userId: number
  phone: string
  nickname: string
  avatar: string
}

export interface UpdateProfileRequest {
  nickname?: string
  avatar?: string
  phone?: string
}

export interface ChangePasswordRequest {
  oldPassword: string
  newPassword: string
}

// --- 协议 ---
export interface AgreementContentItem {
  title: string
  version: string
  content: string
  updateTime: string
}

export interface AgreementResponse {
  agreement?: AgreementContentItem
  privacy?: AgreementContentItem
}

// --- 文件上传 ---
export interface FileUploadResponse {
  url: string
  filename: string
  size: number
  mimeType: string
}

// --- 胶囊 ---
export interface CreateCapsuleRequest {
  campus: string
  title: string
  summary: string
  location: string
  latitude: number
  longitude: number
  mood?: string
  color?: string
  images?: string[]
  isPublic?: boolean
}

export interface CapsuleData {
  id: number
  campus: string
  title: string
  summary: string
  location: string
  mood: string
  color: string
  latitude: number
  longitude: number
  timestamp: number
}

export interface Pagination {
  page: number
  pageSize: number
  total: number
}

export interface CapsuleListData {
  list: CapsuleData[]
  pagination: Pagination
}

export type CreateCapsuleResponse = CapsuleData

export interface ListCapsulesQuery {
  page?: number
  pageSize?: number
  campus?: string
  mood?: string
  timeRange?: number
  keyword?: string
}

export interface LikeRequest {
  capsuleId: number
}

export interface LikeResponse {
  likeCount: number
  isLiked: boolean
}

export interface DeleteRequest {
  capsuleId: number
}

export interface BatchRequest {
  capsuleIds: number[]
  action: string
}

export interface ExportRequest {
  capsuleIds: number[]
}

export interface ExportResponse {
  url: string
}

export interface NearbyCapsuleItem {
  capsuleId: number
  campus: string
  title: string
  location: string
  latitude: number
  longitude: number
  distanceMeters: number
  isPrivate: boolean
  markerType: string
  mood: string
  publishedAt: string
}

export interface GeoPoint {
  latitude: number
  longitude: number
}

export interface NearbyCapsulesResponse {
  center: GeoPoint
  radiusMeters: number
  total: number
  capsules: NearbyCapsuleItem[]
}

export interface NearbyCapsulesQuery {
  latitude: number
  longitude: number
  radiusMeters: number
}

export interface CapsulePopupData {
  capsuleId: number
  title: string
  contentPreview: string
  location: string
  latitude: number
  longitude: number
  mood: string
  isPrivate: boolean
  isLiked: boolean
  likeCount: number
  myFavoriteCount: number
  replyCount: number
  ownerNickname: string
}

export interface BindLocationRequest {
  capsuleId: number
  location: string
  latitude: number
  longitude: number
}

export interface BindLocationResponse {
  capsuleId: number
  location: string
  latitude: number
  longitude: number
}

export interface UpdatePrivacyRequest {
  capsuleId: number
  isPublic: boolean
}

export interface UpdatePrivacyResponse {
  capsuleId: number
  isPublic: boolean
  isPrivate: boolean
  visibilityLabel: string
}

// --- 回复 ---
export interface ReplyRequest {
  capsuleId: number
  content: string
}

export interface ReplyItem {
  id: number
  capsuleId: number
  content: string
  createdAt: string
}

export interface RepliesResponse {
  list: ReplyItem[]
  pagination: Pagination
}

export interface ReplyNotificationItem {
  notificationId: number
  capsuleId: number
  capsuleTitle: string
  replyId: number
  replyContent: string
  replierNickname: string
  isRead: boolean
  createdAt: string
}

export interface ReplyNotificationsResponse {
  items: ReplyNotificationItem[]
  unreadCount: number
  pagination: Pagination
}

export interface MarkNotificationsReadRequest {
  notificationIds: number[]
}

export interface MarkNotificationsReadResponse {
  updatedCount: number
}

// --- 地图 ---
export interface MapCapsuleItem {
  id: number
  latitude: number
  longitude: number
  mood: string
  color: string
}

export interface MapCapsulesResponse {
  capsules: MapCapsuleItem[]
}

export interface MapStatsResponse {
  totalCount: number
  moodScore: number
  distribution: Record<string, number>
}

export interface EmotionStreamItem {
  campus: string
  location: string
  latitude: number
  longitude: number
  capsuleCount: number
  moodKeywords: string[]
  isNewLocation: boolean
  updatedAt: string
}

export interface EmotionStreamResponse {
  totalLocations: number
  items: EmotionStreamItem[]
}

// --- 个人主页 ---
export interface PageQuery {
  page?: number
  pageSize?: number
}

export interface PublishedCapsuleItem {
  capsuleId: number
  title: string
  content: string
  mood: string
  location: string
  latitude: number
  longitude: number
  publishedAt: string
  timeAgo: string
  isPrivate: boolean
  visibilityLabel: string
}

export interface CapsuleStatistics {
  totalCount: number
  privateCount: number
  publicCount: number
}

export interface PublishedCapsulesResponse {
  items: PublishedCapsuleItem[]
  statistics: CapsuleStatistics
  pagination: Pagination
}

export interface FavoriteCapsuleItem {
  capsuleId: number
  title: string
  location: string
  latitude: number
  longitude: number
  mood: string
  isPrivate: boolean
  canView: boolean
  likedAt: string
}

export interface FavoriteCapsulesResponse {
  items: FavoriteCapsuleItem[]
  pagination: Pagination
}

export interface EmotionDistributionItem {
  mood: string
  count: number
  percentage: number
}

export interface EmotionDistributionResponse {
  totalCapsules: number
  topThreeTags: string[]
  topFiveTags: string[]
  distribution: EmotionDistributionItem[]
}

export interface WeekRange {
  startDate: string
  endDate: string
}

export interface MoodTrend {
  risingMoods: string[]
  fallingMoods: string[]
}

export interface WeeklyReportResponse {
  weekRange: WeekRange
  summary: string
  trend: MoodTrend
  suggestions: string[]
}

// --- PC 连接 ---
export interface PcConnectRequestData {
  hasPendingRequest: boolean
  requestId?: string
  deviceName?: string
  deviceType?: string
  loginAt?: string
  locationHint?: string
}

export interface PcConnectConfirmRequest {
  requestId: string
  action: string
}

export interface PcConnectConfirmResponse {
  requestId: string
  action: string
  connected: boolean
}

export interface PcPairStartRequest {
  sourceDeviceType: string
  sourceDeviceName: string
  targetDeviceType: string
  targetDeviceName?: string
  locationHint?: string
}

export interface PcPairStartResponse {
  pairCode: string
  status: string
  requiresConfirmation: boolean
  trustedPreviously: boolean
  sourceDeviceType: string
  sourceDeviceName: string
  targetDeviceType: string
  targetDeviceName: string
  locationHint: string
  confirmTip: string
}

export interface PcPairDeviceInfo {
  deviceType: string
  deviceName: string
}

export interface PcPairStatusResponse {
  pairCode: string
  pairKey: string
  status: string
  requiresConfirmation: boolean
  trustedPreviously: boolean
  initiator: PcPairDeviceInfo
  target: PcPairDeviceInfo
  locationHint: string
  createdAt: string
  handledAt: string | null
}

export interface PcPairConfirmRequest {
  pairCode: string
  action: string
}

export interface PcPairConfirmResponse {
  pairCode: string
  action: string
  status: string
  requiresConfirmation: boolean
  trustedPreviously: boolean
  handledAt: string
}

// --- AI ---
export interface AiNarrativeResponse {
  text: string
  capsuleCount: number
}

export interface AiEmotionItem {
  label: string
  count: number
  color: string
}

export interface AiRewriteResponse {
  originalText: string
  polishedText: string
  style: string
}

export interface AiVoiceOptimizeResponse {
  originalText: string
  optimizedText: string
}

export interface AiCodeFormatResponse {
  originalCode: string
  formattedCode: string
  highlightHtml: string
  language: string
}

// ============================================================
// ApiService
// ============================================================

export interface ApiConfig {
  baseUrl?: string
  timeoutMs?: number
}

export interface RequestOptions {
  headers?: Record<string, string>
  query?: Record<string, string | number | boolean>
}

export class ApiService {
  private static baseUrl: string = 'http://192.168.0.234:3000'
  private static timeoutMs: number = 10000
  private static authToken: string = ''

  static configure(config: ApiConfig): void {
    if (config.baseUrl) {
      ApiService.baseUrl = config.baseUrl
    }
    if (config.timeoutMs && config.timeoutMs > 0) {
      ApiService.timeoutMs = config.timeoutMs
    }
  }

  static setAuthToken(token: string): void {
    ApiService.authToken = token.trim()
  }

  private static buildUrl(path: string, query?: Record<string, string | number | boolean>): string {
    const normalizedBase = ApiService.baseUrl.endsWith('/') ? ApiService.baseUrl.slice(0, -1) : ApiService.baseUrl
    const normalizedPath = path.startsWith('/') ? path : `/${path}`
    const rawUrl = `${normalizedBase}${normalizedPath}`
    if (!query || Object.keys(query).length === 0) {
      return rawUrl
    }
    const keys: string[] = Object.keys(query)
    const queryPairs: string[] = []
    for (let i = 0; i < keys.length; i++) {
      const key: string = keys[i]
      const value: string = String(query[key])
      queryPairs.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
    }
    const queryString = queryPairs.join('&')
    return `${rawUrl}?${queryString}`
  }

  private static buildHeaders(extraHeaders?: Record<string, string>): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    if (ApiService.authToken) {
      headers.Authorization = `Bearer ${ApiService.authToken}`
    }
    if (extraHeaders) {
      const keys = Object.keys(extraHeaders)
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i]
        headers[key] = extraHeaders[key]
      }
    }
    return headers
  }

  private static extractErrorMessage(result: string | object): string {
    if (typeof result === 'string') {
      try {
        const parsed = JSON.parse(result) as ApiEnvelope<object>
        return parsed.message ? parsed.message : '服务端返回错误'
      } catch (_) {
        return result || '服务端返回错误'
      }
    }
    const responseObject = result as ApiEnvelope<object>
    return responseObject.message ? responseObject.message : '服务端返回错误'
  }

  private static hasDataField(value: object): boolean {
    return Object.keys(value).includes('data')
  }

  private static parseResult<T>(result: string | object): T {
    if (typeof result === 'string') {
      const parsed = JSON.parse(result) as ApiEnvelope<T> | T
      const envelope = parsed as ApiEnvelope<T>
      if (typeof envelope === 'object' && envelope !== null && ApiService.hasDataField(envelope)) {
        return envelope.data as T
      }
      return parsed as T
    }
    const maybeEnvelope = result as ApiEnvelope<T>
    if (typeof maybeEnvelope === 'object' && maybeEnvelope !== null && ApiService.hasDataField(maybeEnvelope)) {
      return maybeEnvelope.data as T
    }
    return result as T
  }

  private static showErrorToast(message: string): void {
    try {
      promptAction.showToast({ message: message })
    } catch (error) {
      console.error('Failed to show toast:', error)
    }
  }

  private static async request<T>(
    path: string,
    method: http.RequestMethod,
    body?: object,
    options?: RequestOptions
  ): Promise<T> {
    const client = http.createHttp()
    try {
      const query: Record<string, string | number | boolean> | undefined = options ? options.query : undefined
      const headers: Record<string, string> | undefined = options ? options.headers : undefined
      const extraData: string | undefined = body ? JSON.stringify(body) : undefined

      const response = await client.request(ApiService.buildUrl(path, query), {
        method: method,
        header: ApiService.buildHeaders(headers),
        connectTimeout: ApiService.timeoutMs,
        readTimeout: ApiService.timeoutMs,
        extraData: extraData,
        expectDataType: http.HttpDataType.STRING
      })

      if (response.responseCode < 200 || response.responseCode >= 300) {
        const message = ApiService.extractErrorMessage(response.result)
        ApiService.showErrorToast(message)
        throw new Error(`HTTP_${response.responseCode}:${message}`)
      }
      return ApiService.parseResult<T>(response.result)
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '网络请求失败，请稍后重试'
      ApiService.showErrorToast(message)
      throw error instanceof Error ? error : new Error(message)
    } finally {
      try {
        client.destroy()
      } catch (error) {
        console.error('Failed to destroy client:', error)
      }
    }
  }

  // ============================================================
  // 辅助方法：构建查询参数
  // ============================================================

  private static makeQueryObj(entries: [string, string | number | boolean][]): Record<string, string | number | boolean> {
    const result: Record<string, string | number | boolean> = {}
    for (let i = 0; i < entries.length; i++) {
      const pair = entries[i]
      result[pair[0]] = pair[1]
    }
    return result
  }

  private static makeOptionsFromQuery(q: Record<string, string | number | boolean>): RequestOptions {
    const opts: RequestOptions = { query: q }
    return opts
  }

  // ============================================================
  // SMS
  // ============================================================

  static async sendCode(payload: SendCodeRequest): Promise<SendCodeResponse> {
    await ApiService.request<SendCodeResponse>('/sms/sendCode', http.RequestMethod.POST, payload)
    const result: SendCodeResponse = { success: true }
    return result
  }

  // ============================================================
  // 用户
  // ============================================================

  static async register(payload: RegisterRequest): Promise<RegisterResponse> {
    return await ApiService.request<RegisterResponse>('/user/register', http.RequestMethod.POST, payload)
  }

  static async login(payload: LoginRequest): Promise<LoginResponse> {
    return await ApiService.request<LoginResponse>('/user/login', http.RequestMethod.POST, payload)
  }

  static async harmonyLogin(payload: HarmonyLoginRequest): Promise<HarmonyLoginResponse> {
    return await ApiService.request<HarmonyLoginResponse>('/user/login/harmony', http.RequestMethod.POST, payload)
  }

  static async logout(): Promise<void> {
    await ApiService.request<void>('/user/logout', http.RequestMethod.POST)
  }

  static async getUserProfile(): Promise<UserProfile> {
    return await ApiService.request<UserProfile>('/user/info', http.RequestMethod.POST)
  }

  static async updateUserProfile(payload: UpdateProfileRequest): Promise<UserProfile> {
    return await ApiService.request<UserProfile>('/user/update', http.RequestMethod.POST, payload)
  }

  static async changePassword(payload: ChangePasswordRequest): Promise<void> {
    await ApiService.request<void>('/user/password', http.RequestMethod.POST, payload)
  }

  // ============================================================
  // 协议
  // ============================================================

  static async getAgreement(type: 'agreement' | 'privacy'): Promise<AgreementContentItem> {
    const query: Record<string, string | number | boolean> = ApiService.makeQueryObj([['type', type]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(query)
    const response = await ApiService.request<AgreementResponse>('/agreement/content', http.RequestMethod.GET, undefined, opts)
    if (type === 'agreement' && response.agreement) {
      return response.agreement
    }
    if (type === 'privacy' && response.privacy) {
      return response.privacy
    }
    throw new Error('协议内容获取失败')
  }

  // ============================================================
  // 文件上传
  // ============================================================

  static async uploadFile(filePath: string): Promise<FileUploadResponse> {
    const client = http.createHttp()
    try {
      const file: fs.File = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      const fileStat = fs.statSync(filePath)
      const buffer: Uint8Array = new Uint8Array(fileStat.size)
      fs.readSync(file.fd, buffer)
      fs.closeSync(file.fd)

      const fileContent: ArrayBuffer = buffer.buffer as ArrayBuffer
      const boundary: string = '----WebKitFormBoundary' + Date.now().toString(36)
      const filename: string = filePath.substring(filePath.lastIndexOf('/') + 1)

      const base64Content: string = ApiService.arrayBufferToBase64(fileContent)

      const bodyParts: string[] = []
      const part1: string = `--${boundary}`
      bodyParts.push(part1)
      const part2: string = `Content-Disposition: form-data; name="file"; filename="${filename}"`
      bodyParts.push(part2)
      bodyParts.push('Content-Type: application/octet-stream')
      bodyParts.push('')
      bodyParts.push(base64Content)
      const partEnd: string = `--${boundary}--`
      bodyParts.push(partEnd)
      bodyParts.push('')

      const body: string = bodyParts.join('\r\n')

      const uploadHeaders: Record<string, string> = { 'Content-Type': `multipart/form-data; boundary=${boundary}` }
      const response: http.HttpResponse = await client.request(ApiService.buildUrl('/file/upload'), {
        method: http.RequestMethod.POST,
        header: ApiService.buildHeaders(uploadHeaders),
        extraData: body,
        connectTimeout: ApiService.timeoutMs,
        readTimeout: ApiService.timeoutMs
      })
      if (response.responseCode < 200 || response.responseCode >= 300) {
        const message = ApiService.extractErrorMessage(response.result)
        ApiService.showErrorToast(message)
        throw new Error(`HTTP_${response.responseCode}:${message}`)
      }
      return ApiService.parseResult<FileUploadResponse>(response.result)
    } catch (error) {
      const message: string = error instanceof Error ? error.message : '文件上传失败'
      ApiService.showErrorToast(message)
      throw error instanceof Error ? error : new Error(message)
    } finally {
      client.destroy()
    }
  }

  private static arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes: Uint8Array = new Uint8Array(buffer)
    const base64Chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    let result: string = ''
    let padding: number = 0

    for (let i: number = 0; i < bytes.length; i += 3) {
      const byte1: number = bytes[i] || 0
      const byte2: number = bytes[i + 1] || 0
      const byte3: number = bytes[i + 2] || 0

      const triple: number = (byte1 << 16) | (byte2 << 8) | byte3

      result += base64Chars[(triple >> 18) & 63]
      result += base64Chars[(triple >> 12) & 63]
      result += base64Chars[(triple >> 6) & 63]
      result += base64Chars[triple & 63]

      if (i + 1 >= bytes.length) padding++
      if (i + 2 >= bytes.length) padding++
    }

    return result.substring(0, result.length - padding) + '=='.substring(0, padding)
  }

  // ============================================================
  // 胶囊
  // ============================================================

  static async createCapsule(payload: CreateCapsuleRequest): Promise<CreateCapsuleResponse> {
    return await ApiService.request<CreateCapsuleResponse>('/capsule/create', http.RequestMethod.POST, payload)
  }

  static async listCapsules(query: ListCapsulesQuery): Promise<CapsuleListData> {
    const q: Record<string, string | number | boolean> = {}
    if (query.page) { q['page'] = query.page }
    if (query.pageSize) { q['pageSize'] = query.pageSize }
    if (query.campus) { q['campus'] = query.campus }
    if (query.mood) { q['mood'] = query.mood }
    if (query.timeRange) { q['timeRange'] = query.timeRange }
    if (query.keyword) { q['keyword'] = query.keyword }
    const opts: RequestOptions = { query: q }
    return await ApiService.request<CapsuleListData>('/capsule/list', http.RequestMethod.GET, undefined, opts)
  }

  static async getCapsuleDetail(capsuleId: number): Promise<CapsuleData> {
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['id', capsuleId]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<CapsuleData>('/capsule/detail', http.RequestMethod.GET, undefined, opts)
  }

  static async toggleLike(capsuleId: number): Promise<LikeResponse> {
    const body: LikeRequest = { capsuleId: capsuleId }
    return await ApiService.request<LikeResponse>('/capsule/like', http.RequestMethod.POST, body)
  }

  static async deleteCapsule(capsuleId: number): Promise<void> {
    const body: DeleteRequest = { capsuleId: capsuleId }
    await ApiService.request<void>('/capsule/delete', http.RequestMethod.DELETE, body)
  }

  static async batchCapsules(capsuleIds: number[], action: string): Promise<void> {
    const body: BatchRequest = { capsuleIds: capsuleIds, action: action }
    await ApiService.request<void>('/capsule/batch', http.RequestMethod.POST, body)
  }

  static async getMyCapsules(query: ListCapsulesQuery): Promise<CapsuleListData> {
    const q: Record<string, string | number | boolean> = {}
    if (query.page) { q['page'] = query.page }
    if (query.pageSize) { q['pageSize'] = query.pageSize }
    if (query.campus) { q['campus'] = query.campus }
    if (query.timeRange) { q['timeRange'] = query.timeRange }
    const opts: RequestOptions = { query: q }
    return await ApiService.request<CapsuleListData>('/capsule/my', http.RequestMethod.GET, undefined, opts)
  }

  static async exportCapsules(capsuleIds: number[]): Promise<ExportResponse> {
    const body: ExportRequest = { capsuleIds: capsuleIds }
    return await ApiService.request<ExportResponse>('/capsule/export', http.RequestMethod.POST, body)
  }

  static async getNearbyCapsules(query: NearbyCapsulesQuery): Promise<NearbyCapsulesResponse> {
    const q: Record<string, string | number | boolean> = {}
    q['latitude'] = query.latitude
    q['longitude'] = query.longitude
    q['radiusMeters'] = query.radiusMeters
    const opts: RequestOptions = { query: q }
    return await ApiService.request<NearbyCapsulesResponse>('/capsule/nearby', http.RequestMethod.GET, undefined, opts)
  }

  static async getCapsulePopup(capsuleId: number): Promise<CapsulePopupData> {
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['capsuleId', capsuleId]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<CapsulePopupData>('/capsule/popup', http.RequestMethod.GET, undefined, opts)
  }

  static async bindCapsuleLocation(payload: BindLocationRequest): Promise<BindLocationResponse> {
    return await ApiService.request<BindLocationResponse>('/capsule/location/bind', http.RequestMethod.POST, payload)
  }

  static async updateCapsulePrivacy(payload: UpdatePrivacyRequest): Promise<UpdatePrivacyResponse> {
    return await ApiService.request<UpdatePrivacyResponse>('/capsule/privacy/update', http.RequestMethod.POST, payload)
  }

  // ============================================================
  // 回复
  // ============================================================

  static async addReply(capsuleId: number, content: string): Promise<void> {
    const body: ReplyRequest = { capsuleId: capsuleId, content: content }
    await ApiService.request<void>('/capsule/reply', http.RequestMethod.POST, body)
  }

  static async getReplies(capsuleId: number, page?: number, pageSize?: number): Promise<RepliesResponse> {
    const p = page ?? 1
    const ps = pageSize ?? 20
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([
      ['capsuleId', capsuleId], ['page', p], ['pageSize', ps]
    ])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<RepliesResponse>('/capsule/replies', http.RequestMethod.GET, undefined, opts)
  }

  static async getReplyNotifications(page?: number, pageSize?: number): Promise<ReplyNotificationsResponse> {
    const p = page ?? 1
    const ps = pageSize ?? 10
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['page', p], ['pageSize', ps]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<ReplyNotificationsResponse>('/capsule/reply/notifications', http.RequestMethod.GET, undefined, opts)
  }

  static async markReplyNotificationsRead(notificationIds: number[]): Promise<MarkNotificationsReadResponse> {
    const body: MarkNotificationsReadRequest = { notificationIds: notificationIds }
    return await ApiService.request<MarkNotificationsReadResponse>('/capsule/reply/notifications/read', http.RequestMethod.POST, body)
  }

  // ============================================================
  // 地图
  // ============================================================

  static async getMapCapsules(campus: string, timeRange: number): Promise<MapCapsulesResponse> {
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['campus', campus], ['timeRange', timeRange]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<MapCapsulesResponse>('/map/capsules', http.RequestMethod.GET, undefined, opts)
  }

  static async getMapStats(campus: string, timeRange: number): Promise<MapStatsResponse> {
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['campus', campus], ['timeRange', timeRange]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<MapStatsResponse>('/map/stats', http.RequestMethod.GET, undefined, opts)
  }

  static async getEmotionStream(updatedAfter?: string): Promise<EmotionStreamResponse> {
    const q: Record<string, string | number | boolean> = {}
    if (updatedAfter) {
      q['updatedAfter'] = updatedAfter
    }
    const opts: RequestOptions = { query: q }
    return await ApiService.request<EmotionStreamResponse>('/map/emotion-stream', http.RequestMethod.GET, undefined, opts)
  }

  // ============================================================
  // 个人主页
  // ============================================================

  static async getPublishedCapsules(page?: number, pageSize?: number): Promise<PublishedCapsulesResponse> {
    const p = page ?? 1
    const ps = pageSize ?? 10
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['page', p], ['pageSize', ps]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<PublishedCapsulesResponse>('/profile/capsules/published', http.RequestMethod.GET, undefined, opts)
  }

  static async getFavoriteCapsules(page?: number, pageSize?: number): Promise<FavoriteCapsulesResponse> {
    const p = page ?? 1
    const ps = pageSize ?? 10
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['page', p], ['pageSize', ps]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<FavoriteCapsulesResponse>('/profile/capsules/favorites', http.RequestMethod.GET, undefined, opts)
  }

  static async getEmotionDistribution(timeRangeDays?: number): Promise<EmotionDistributionResponse> {
    const q: Record<string, string | number | boolean> = {}
    if (timeRangeDays) {
      q['timeRangeDays'] = timeRangeDays
    }
    const opts: RequestOptions = { query: q }
    return await ApiService.request<EmotionDistributionResponse>('/profile/emotion/distribution', http.RequestMethod.GET, undefined, opts)
  }

  static async getWeeklyReport(weekOffset?: number): Promise<WeeklyReportResponse> {
    const q: Record<string, string | number | boolean> = {}
    if (weekOffset !== undefined) {
      q['weekOffset'] = weekOffset
    }
    const opts: RequestOptions = { query: q }
    return await ApiService.request<WeeklyReportResponse>('/profile/emotion/weekly-report', http.RequestMethod.GET, undefined, opts)
  }

  // ============================================================
  // PC 连接
  // ============================================================

  static async getPcConnectRequest(): Promise<PcConnectRequestData> {
    return await ApiService.request<PcConnectRequestData>('/pc/connect/request', http.RequestMethod.GET)
  }

  static async confirmPcConnectRequest(payload: PcConnectConfirmRequest): Promise<PcConnectConfirmResponse> {
    return await ApiService.request<PcConnectConfirmResponse>('/pc/connect/confirm', http.RequestMethod.POST, payload)
  }

  static async startPcPair(payload: PcPairStartRequest): Promise<PcPairStartResponse> {
    return await ApiService.request<PcPairStartResponse>('/pc/connect/pair/start', http.RequestMethod.POST, payload)
  }

  static async getPcPairStatus(pairCode: string): Promise<PcPairStatusResponse> {
    const q: Record<string, string | number | boolean> = ApiService.makeQueryObj([['pairCode', pairCode]])
    const opts: RequestOptions = ApiService.makeOptionsFromQuery(q)
    return await ApiService.request<PcPairStatusResponse>('/pc/connect/pair/status', http.RequestMethod.GET, undefined, opts)
  }

  static async confirmPcPair(payload: PcPairConfirmRequest): Promise<PcPairConfirmResponse> {
    return await ApiService.request<PcPairConfirmResponse>('/pc/connect/pair/confirm', http.RequestMethod.POST, payload)
  }

  // ============================================================
  // AI
  // ============================================================

  static async generateNarrative(capsuleIds?: number[], style?: string): Promise<AiNarrativeResponse> {
    const body: Record<string, Object | undefined> = {}
    body['capsuleIds'] = capsuleIds
    body['style'] = style
    return await ApiService.request<AiNarrativeResponse>('/ai/narrative', http.RequestMethod.POST, body)
  }

  static async analyzeEmotion(capsuleIds?: number[], period?: string): Promise<AiEmotionItem[]> {
    const body: Record<string, Object | undefined> = {}
    body['capsuleIds'] = capsuleIds
    body['period'] = period
    return await ApiService.request<AiEmotionItem[]>('/ai/emotion', http.RequestMethod.POST, body)
  }

  static async aiRewrite(content: string, style?: string): Promise<AiRewriteResponse> {
    const body: Record<string, Object | undefined> = {}
    body['content'] = content
    body['style'] = style
    return await ApiService.request<AiRewriteResponse>('/ai/rewrite', http.RequestMethod.POST, body)
  }

  static async aiVoiceOptimize(content: string): Promise<AiVoiceOptimizeResponse> {
    const body: Record<string, Object> = {}
    body['content'] = content
    return await ApiService.request<AiVoiceOptimizeResponse>('/ai/voice/optimize', http.RequestMethod.POST, body)
  }

  static async aiFormatCode(content: string, language?: string): Promise<AiCodeFormatResponse> {
    const body: Record<string, Object | undefined> = {}
    body['content'] = content
    body['language'] = language
    return await ApiService.request<AiCodeFormatResponse>('/ai/code/format', http.RequestMethod.POST, body)
  }
}