import type {
  SendCodeResponse,
  RegisterResponse,
  LoginResponse,
  HarmonyLoginResponse,
  UserInfoBrief,
  HarmonyUserInfo,
  UserProfile,
  AgreementContentItem,
  FileUploadResponse,
  CreateCapsuleResponse,
  CapsuleData,
  CapsuleListData,
  LikeResponse,
  NearbyCapsulesResponse,
  CapsulePopupData,
  BindLocationResponse,
  UpdatePrivacyResponse,
  ReplyItem,
  RepliesResponse,
  ReplyNotificationItem,
  ReplyNotificationsResponse,
  MarkNotificationsReadResponse,
  MapCapsulesResponse,
  MapStatsResponse,
  EmotionStreamResponse,
  EmotionStreamItem,
  PublishedCapsulesResponse,
  FavoriteCapsulesResponse,
  EmotionDistributionResponse,
  WeeklyReportResponse,
  WeekRange,
  MoodTrend,
  PcConnectRequestData,
  PcConnectConfirmResponse,
  PcPairStartResponse,
  PcPairStatusResponse,
  PcPairDeviceInfo,
  PcPairConfirmResponse,
  AiNarrativeResponse,
  AiEmotionItem,
  AiRewriteResponse,
  AiVoiceOptimizeResponse,
  AiCodeFormatResponse,
  ExportResponse,
  Pagination,
  GeoPoint,
  CapsuleStatistics,
  SendCodeRequest,
  RegisterRequest,
  LoginRequest,
  HarmonyLoginRequest,
  UpdateProfileRequest,
  ChangePasswordRequest,
  CreateCapsuleRequest,
  ListCapsulesQuery,
  NearbyCapsulesQuery,
  BindLocationRequest,
  UpdatePrivacyRequest,
  PcConnectConfirmRequest,
  PcPairStartRequest,
  PcPairConfirmRequest,
  EmotionDistributionItem,
  PublishedCapsuleItem,
  FavoriteCapsuleItem,
  NearbyCapsuleItem,
  MapCapsuleItem,
  ApiConfig
} from './ApiService'

export type {
  SendCodeResponse,
  RegisterResponse,
  LoginResponse,
  HarmonyLoginResponse,
  UserInfoBrief,
  HarmonyUserInfo,
  UserProfile,
  AgreementContentItem,
  FileUploadResponse,
  CreateCapsuleResponse,
  CapsuleData,
  CapsuleListData,
  LikeResponse,
  NearbyCapsulesResponse,
  CapsulePopupData,
  BindLocationResponse,
  UpdatePrivacyResponse,
  ReplyItem,
  RepliesResponse,
  ReplyNotificationItem,
  ReplyNotificationsResponse,
  MarkNotificationsReadResponse,
  MapCapsulesResponse,
  MapStatsResponse,
  EmotionStreamResponse,
  EmotionStreamItem,
  PublishedCapsulesResponse,
  FavoriteCapsulesResponse,
  EmotionDistributionResponse,
  WeeklyReportResponse,
  WeekRange,
  MoodTrend,
  PcConnectRequestData,
  PcConnectConfirmResponse,
  PcPairStartResponse,
  PcPairStatusResponse,
  PcPairDeviceInfo,
  PcPairConfirmResponse,
  AiNarrativeResponse,
  AiEmotionItem,
  AiRewriteResponse,
  AiVoiceOptimizeResponse,
  AiCodeFormatResponse,
  ExportResponse,
  Pagination,
  GeoPoint,
  CapsuleStatistics,
  SendCodeRequest,
  RegisterRequest,
  LoginRequest,
  HarmonyLoginRequest,
  UpdateProfileRequest,
  ChangePasswordRequest,
  CreateCapsuleRequest,
  ListCapsulesQuery,
  NearbyCapsulesQuery,
  BindLocationRequest,
  UpdatePrivacyRequest,
  PcConnectConfirmRequest,
  PcPairStartRequest,
  PcPairConfirmRequest,
  EmotionDistributionItem,
  PublishedCapsuleItem,
  FavoriteCapsuleItem,
  NearbyCapsuleItem,
  MapCapsuleItem,
  ApiConfig
}

const MOCK_PHONE: string = '12345678901'
const MOCK_CODE: string = '124569'
const MOCK_TOKEN: string = 'mock-token'
const MOCK_USER_ID: number = 1001

export class ApiService {
  private static authToken: string = ''
  private static password: string = 'password123'
  private static profile: UserProfile = {
    userId: MOCK_USER_ID,
    nickname: '拾光旅人',
    phone: MOCK_PHONE,
    avatar: ''
  }
  private static capsuleIdSeed: number = 100
  private static capsules: CapsuleData[] = [
    {
      id: 1,
      campus: 'jinming',
      title: '图书馆的风',
      summary: '傍晚的风从教学楼走廊吹过，像把今天的烦躁都带走了。',
      location: '金明校区图书馆',
      mood: '平静',
      color: '#4A90D9',
      latitude: 34.815278,
      longitude: 114.302222,
      timestamp: Date.now()
    },
    {
      id: 2,
      campus: 'jinming',
      title: '操场落日',
      summary: '落日把操场染成橘色，篮球撞击地面的声音像是节拍器。',
      location: '金明校区操场',
      mood: '浪漫',
      color: '#E8917E',
      latitude: 34.814510,
      longitude: 114.300930,
      timestamp: Date.now()
    },
    {
      id: 4,
      campus: 'jinming',
      title: '代码通过了',
      summary: '一行代码跑通的瞬间，世界都清晰了。',
      location: '信息工程楼',
      mood: '极客',
      color: '#9B59B6',
      latitude: 34.816820,
      longitude: 114.304560,
      timestamp: Date.now()
    },
    {
      id: 5,
      campus: 'jinming',
      title: '明天的汇报',
      summary: '明天的汇报还有好多细节没想好，希望能顺利。',
      location: '教学楼 A 区',
      mood: '焦虑',
      color: '#5DADE2',
      latitude: 34.815910,
      longitude: 114.303880,
      timestamp: Date.now()
    },
    {
      id: 6,
      campus: 'minglun',
      title: '林荫道',
      summary: '夜里走过林荫道，听见树叶碰撞的声音。',
      location: '林荫道',
      mood: '孤独',
      color: '#7F8C8D',
      latitude: 34.813660,
      longitude: 114.301120,
      timestamp: Date.now()
    }
  ]
  private static replies: Record<number, ReplyItem[]> = {
    1: [
      { id: 1, capsuleId: 1, content: '这里的风确实很舒服。', createdAt: ApiService.nowIso() },
      { id: 2, capsuleId: 1, content: '我也在这儿写过作业。', createdAt: ApiService.nowIso() }
    ],
    2: [
      { id: 3, capsuleId: 2, content: '操场的夕阳太治愈了。', createdAt: ApiService.nowIso() }
    ],
    4: [
      { id: 4, capsuleId: 4, content: '同感，debug 成功像中彩票。', createdAt: ApiService.nowIso() },
      { id: 5, capsuleId: 4, content: '今晚也要把小功能写完！', createdAt: ApiService.nowIso() }
    ]
  }
  private static likes: Set<number> = new Set([2, 4])
  private static replyNotifications: ReplyNotificationItem[] = [
    {
      notificationId: 1,
      capsuleId: 1,
      capsuleTitle: '图书馆的风',
      replyId: 1,
      replyContent: '这里的风确实很舒服。',
      replierNickname: '同学A',
      isRead: false,
      createdAt: ApiService.nowIso()
    },
    {
      notificationId: 2,
      capsuleId: 2,
      capsuleTitle: '操场落日',
      replyId: 3,
      replyContent: '操场的夕阳太治愈了。',
      replierNickname: '同学B',
      isRead: false,
      createdAt: ApiService.nowIso()
    }
  ]

  static configure(_: ApiConfig): void {
    // no-op for mock
  }

  static setAuthToken(token: string): void {
    ApiService.authToken = token.trim()
  }

  private static nowIso(): string {
    return new Date().toISOString()
  }

  private static ensureValidPhone(phone: string): void {
    if (phone.trim() !== MOCK_PHONE) {
      throw new Error('Mock only accepts phone 12345678901')
    }
  }

  private static ensureValidCode(code: string): void {
    if (code.trim() !== MOCK_CODE) {
      throw new Error('Mock only accepts code 124569')
    }
  }

  private static nextCapsuleId(): number {
    ApiService.capsuleIdSeed += 1
    return ApiService.capsuleIdSeed
  }

  private static fileNameFromPath(filePath: string): string {
    const normalized = filePath.replace(/\\/g, '/')
    const idx = normalized.lastIndexOf('/')
    return idx >= 0 ? normalized.substring(idx + 1) : normalized
  }

  // ============================================================
  // SMS
  // ============================================================

  static async sendCode(payload: SendCodeRequest): Promise<SendCodeResponse> {
    ApiService.ensureValidPhone(payload.phone)
    const result: SendCodeResponse = { success: true }
    return result
  }

  // ============================================================
  // 用户
  // ============================================================

  static async register(payload: RegisterRequest): Promise<RegisterResponse> {
    ApiService.ensureValidPhone(payload.phone)
    ApiService.ensureValidCode(payload.code)
    const updatedProfile: UserProfile = {
      userId: MOCK_USER_ID,
      nickname: payload.nickname,
      phone: payload.phone,
      avatar: payload.avatar || ''
    }
    ApiService.profile = updatedProfile
    ApiService.password = payload.password
    const userInfo: UserInfoBrief = {
      userId: MOCK_USER_ID,
      phone: payload.phone,
      nickname: payload.nickname,
      avatar: payload.avatar || ''
    }
    const result: RegisterResponse = {
      token: MOCK_TOKEN,
      tokenType: 'Bearer',
      expiresIn: 86400,
      userInfo: userInfo
    }
    return result
  }

  static async login(payload: LoginRequest): Promise<LoginResponse> {
    ApiService.ensureValidPhone(payload.phone)
    ApiService.ensureValidCode(payload.code)
    const userInfo: UserInfoBrief = {
      userId: MOCK_USER_ID,
      phone: payload.phone,
      nickname: ApiService.profile.nickname || 'MockUser',
      avatar: ApiService.profile.avatar
    }
    const result: LoginResponse = {
      token: MOCK_TOKEN,
      tokenType: 'Bearer',
      expiresIn: 86400,
      userInfo: userInfo
    }
    return result
  }

  static async harmonyLogin(_: HarmonyLoginRequest): Promise<HarmonyLoginResponse> {
    const userInfo: HarmonyUserInfo = {
      userId: MOCK_USER_ID,
      nickname: '拾光用户',
      avatar: 'https://example.com/avatar/default.png',
      phone: '138****0000',
      openId: 'mock-harmony-open-id'
    }
    const result: HarmonyLoginResponse = {
      token: MOCK_TOKEN,
      tokenType: 'Bearer',
      expiresIn: 86400,
      userInfo: userInfo
    }
    return result
  }

  static async logout(): Promise<void> {
    // no-op
  }

  static async getUserProfile(): Promise<UserProfile> {
    const result: UserProfile = {
      userId: ApiService.profile.userId,
      phone: ApiService.profile.phone,
      nickname: ApiService.profile.nickname,
      avatar: ApiService.profile.avatar
    }
    return result
  }

  static async updateUserProfile(payload: UpdateProfileRequest): Promise<UserProfile> {
    if (payload.nickname !== undefined) {
      ApiService.profile.nickname = payload.nickname
    }
    if (payload.avatar !== undefined) {
      ApiService.profile.avatar = payload.avatar
    }
    if (payload.phone !== undefined) {
      ApiService.profile.phone = payload.phone
    }
    const result: UserProfile = {
      userId: ApiService.profile.userId,
      phone: ApiService.profile.phone,
      nickname: ApiService.profile.nickname,
      avatar: ApiService.profile.avatar
    }
    return result
  }

  static async changePassword(payload: ChangePasswordRequest): Promise<void> {
    if (payload.oldPassword !== ApiService.password) {
      throw new Error('Mock password mismatch')
    }
    ApiService.password = payload.newPassword
  }

  // ============================================================
  // 协议
  // ============================================================

  static async getAgreement(type: 'agreement' | 'privacy'): Promise<AgreementContentItem> {
    const title = type === 'agreement' ? '用户协议' : '隐私政策'
    const result: AgreementContentItem = {
      title: title,
      version: '1.0.0',
      content: `Mock ${type} content`,
      updateTime: ApiService.nowIso()
    }
    return result
  }

  // ============================================================
  // 文件上传
  // ============================================================

  static async uploadFile(filePath: string): Promise<FileUploadResponse> {
    const filename = ApiService.fileNameFromPath(filePath)
    const result: FileUploadResponse = {
      url: `mock://files/${filename}`,
      filename: filename,
      size: 12345,
      mimeType: 'application/octet-stream'
    }
    return result
  }

  // ============================================================
  // 胶囊
  // ============================================================

  static async createCapsule(payload: CreateCapsuleRequest): Promise<CreateCapsuleResponse> {
    const id = ApiService.nextCapsuleId()
    const capsule: CapsuleData = {
      id: id,
      campus: payload.campus,
      title: payload.title,
      summary: payload.summary,
      location: payload.location,
      mood: payload.mood || '未标记',
      color: payload.color || '#6B7280',
      latitude: payload.latitude,
      longitude: payload.longitude,
      timestamp: Date.now()
    }
    const newList: CapsuleData[] = [capsule]
    for (let i = 0; i < ApiService.capsules.length; i++) {
      newList.push(ApiService.capsules[i])
    }
    ApiService.capsules = newList
    return capsule
  }

  static async listCapsules(query: ListCapsulesQuery): Promise<CapsuleListData> {
    let list: CapsuleData[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      let match = true
      if (query.campus && c.campus !== query.campus) { match = false }
      if (query.mood && c.mood !== query.mood) { match = false }
      if (match) { list.push(c) }
    }
    const page = query.page || 1
    const pageSize = query.pageSize || 20
    const total = list.length
    const start = (page - 1) * pageSize
    const paged: CapsuleData[] = []
    for (let i = start; i < start + pageSize && i < list.length; i++) {
      paged.push(list[i])
    }
    const pagination: Pagination = { page: page, pageSize: pageSize, total: total }
    const result: CapsuleListData = { list: paged, pagination: pagination }
    return result
  }

  static async getCapsuleDetail(capsuleId: number): Promise<CapsuleData> {
    for (let i = 0; i < ApiService.capsules.length; i++) {
      if (ApiService.capsules[i].id === capsuleId) {
        const c = ApiService.capsules[i]
        const result: CapsuleData = {
          id: c.id, campus: c.campus, title: c.title, summary: c.summary,
          location: c.location, mood: c.mood, color: c.color,
          latitude: c.latitude, longitude: c.longitude, timestamp: c.timestamp
        }
        return result
      }
    }
    throw new Error('胶囊不存在')
  }

  static async toggleLike(capsuleId: number): Promise<LikeResponse> {
    if (ApiService.likes.has(capsuleId)) {
      ApiService.likes.delete(capsuleId)
      const result: LikeResponse = { likeCount: ApiService.likes.size, isLiked: false }
      return result
    }
    ApiService.likes.add(capsuleId)
    const result: LikeResponse = { likeCount: ApiService.likes.size, isLiked: true }
    return result
  }

  static async deleteCapsule(capsuleId: number): Promise<void> {
    const newList: CapsuleData[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      if (ApiService.capsules[i].id !== capsuleId) {
        newList.push(ApiService.capsules[i])
      }
    }
    ApiService.capsules = newList
  }

  static async batchCapsules(capsuleIds: number[], action: string): Promise<void> {
    if (action === 'delete') {
      const newList: CapsuleData[] = []
      for (let i = 0; i < ApiService.capsules.length; i++) {
        let shouldKeep = true
        for (let j = 0; j < capsuleIds.length; j++) {
          if (ApiService.capsules[i].id === capsuleIds[j]) {
            shouldKeep = false
            break
          }
        }
        if (shouldKeep) { newList.push(ApiService.capsules[i]) }
      }
      ApiService.capsules = newList
    }
  }

  static async getMyCapsules(query: ListCapsulesQuery): Promise<CapsuleListData> {
    return ApiService.listCapsules(query)
  }

  static async exportCapsules(_: number[]): Promise<ExportResponse> {
    const result: ExportResponse = { url: `mock://exports/capsule-export-${Date.now()}.png` }
    return result
  }

  static async getNearbyCapsules(query: NearbyCapsulesQuery): Promise<NearbyCapsulesResponse> {
    const capsules: NearbyCapsuleItem[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      const dist = Math.round(Math.random() * 500 * 10) / 10
      const item: NearbyCapsuleItem = {
        capsuleId: c.id, campus: c.campus, title: c.title, location: c.location,
        latitude: c.latitude, longitude: c.longitude, distanceMeters: dist,
        isPrivate: false, markerType: 'public', mood: c.mood, publishedAt: ApiService.nowIso()
      }
      capsules.push(item)
    }
    const center: GeoPoint = { latitude: query.latitude, longitude: query.longitude }
    const result: NearbyCapsulesResponse = {
      center: center, radiusMeters: query.radiusMeters, total: capsules.length, capsules: capsules
    }
    return result
  }

  static async getCapsulePopup(capsuleId: number): Promise<CapsulePopupData> {
    let found: CapsuleData | null = null
    for (let i = 0; i < ApiService.capsules.length; i++) {
      if (ApiService.capsules[i].id === capsuleId) { found = ApiService.capsules[i]; break }
    }
    if (!found) { throw new Error('胶囊不存在') }
    const replyCount = ApiService.replies[found.id] ? ApiService.replies[found.id].length : 0
    const result: CapsulePopupData = {
      capsuleId: found.id, title: found.title, contentPreview: found.summary,
      location: found.location, latitude: found.latitude, longitude: found.longitude,
      mood: found.mood, isPrivate: false, isLiked: ApiService.likes.has(found.id),
      likeCount: ApiService.likes.size, myFavoriteCount: ApiService.likes.size,
      replyCount: replyCount, ownerNickname: '拾光旅人'
    }
    return result
  }

  static async bindCapsuleLocation(payload: BindLocationRequest): Promise<BindLocationResponse> {
    for (let i = 0; i < ApiService.capsules.length; i++) {
      if (ApiService.capsules[i].id === payload.capsuleId) {
        ApiService.capsules[i].location = payload.location
        ApiService.capsules[i].latitude = payload.latitude
        ApiService.capsules[i].longitude = payload.longitude
      }
    }
    const result: BindLocationResponse = {
      capsuleId: payload.capsuleId, location: payload.location,
      latitude: payload.latitude, longitude: payload.longitude
    }
    return result
  }

  static async updateCapsulePrivacy(payload: UpdatePrivacyRequest): Promise<UpdatePrivacyResponse> {
    const result: UpdatePrivacyResponse = {
      capsuleId: payload.capsuleId, isPublic: payload.isPublic,
      isPrivate: !payload.isPublic,
      visibilityLabel: payload.isPublic ? '公开' : '私密'
    }
    return result
  }

  // ============================================================
  // 回复
  // ============================================================

  static async addReply(capsuleId: number, content: string): Promise<void> {
    const reply: ReplyItem = {
      id: Date.now(), capsuleId: capsuleId, content: content, createdAt: ApiService.nowIso()
    }
    if (!ApiService.replies[capsuleId]) {
      ApiService.replies[capsuleId] = []
    }
    const newReplies: ReplyItem[] = []
    for (let i = 0; i < ApiService.replies[capsuleId].length; i++) {
      newReplies.push(ApiService.replies[capsuleId][i])
    }
    newReplies.push(reply)
    ApiService.replies[capsuleId] = newReplies
  }

  static async getReplies(capsuleId: number, page?: number, pageSize?: number): Promise<RepliesResponse> {
    const list = ApiService.replies[capsuleId] || []
    const p = page || 1
    const ps = pageSize || 20
    const start = (p - 1) * ps
    const pagedList: ReplyItem[] = []
    for (let i = start; i < start + ps && i < list.length; i++) {
      pagedList.push(list[i])
    }
    const pagination: Pagination = { page: p, pageSize: ps, total: list.length }
    const result: RepliesResponse = { list: pagedList, pagination: pagination }
    return result
  }

  static async getReplyNotifications(page?: number, pageSize?: number): Promise<ReplyNotificationsResponse> {
    const p = page || 1
    const ps = pageSize || 10
    const start = (p - 1) * ps
    const items: ReplyNotificationItem[] = []
    for (let i = start; i < start + ps && i < ApiService.replyNotifications.length; i++) {
      items.push(ApiService.replyNotifications[i])
    }
    let unreadCount = 0
    for (let i = 0; i < ApiService.replyNotifications.length; i++) {
      if (!ApiService.replyNotifications[i].isRead) { unreadCount++ }
    }
    const pagination: Pagination = { page: p, pageSize: ps, total: ApiService.replyNotifications.length }
    const result: ReplyNotificationsResponse = { items: items, unreadCount: unreadCount, pagination: pagination }
    return result
  }

  static async markReplyNotificationsRead(notificationIds: number[]): Promise<MarkNotificationsReadResponse> {
    let count = 0
    for (let i = 0; i < ApiService.replyNotifications.length; i++) {
      for (let j = 0; j < notificationIds.length; j++) {
        if (ApiService.replyNotifications[i].notificationId === notificationIds[j] && !ApiService.replyNotifications[i].isRead) {
          ApiService.replyNotifications[i].isRead = true
          count++
        }
      }
    }
    const result: MarkNotificationsReadResponse = { updatedCount: count }
    return result
  }

  // ============================================================
  // 地图
  // ============================================================

  static async getMapCapsules(campus: string, _: number): Promise<MapCapsulesResponse> {
    const capsules: MapCapsuleItem[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      if (c.campus === campus) {
        const item: MapCapsuleItem = {
          id: c.id, latitude: c.latitude, longitude: c.longitude, mood: c.mood, color: c.color
        }
        capsules.push(item)
      }
    }
    const result: MapCapsulesResponse = { capsules: capsules }
    return result
  }

  static async getMapStats(campus: string, _: number): Promise<MapStatsResponse> {
    const distribution: Record<string, number> = {}
    let totalCount = 0
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      if (c.campus === campus) {
        totalCount++
        if (distribution[c.mood]) {
          distribution[c.mood] = distribution[c.mood] + 1
        } else {
          distribution[c.mood] = 1
        }
      }
    }
    const moodScore = totalCount > 0 ? Math.round((Object.keys(distribution).length / totalCount) * 100) : 0
    const result: MapStatsResponse = { totalCount: totalCount, moodScore: moodScore, distribution: distribution }
    return result
  }

  static async getEmotionStream(_?: string): Promise<EmotionStreamResponse> {
    const item1: EmotionStreamItem = {
      campus: 'jinming', location: '金明校区图书馆', latitude: 34.815278, longitude: 114.302222,
      capsuleCount: 18, moodKeywords: ['平静', '治愈', '专注'], isNewLocation: false, updatedAt: ApiService.nowIso()
    }
    const item2: EmotionStreamItem = {
      campus: 'minglun', location: '明伦校区主楼', latitude: 34.797120, longitude: 114.356780,
      capsuleCount: 9, moodKeywords: ['活力', '期待', '踏实'], isNewLocation: true, updatedAt: ApiService.nowIso()
    }
    const items: EmotionStreamItem[] = [item1, item2]
    const result: EmotionStreamResponse = { totalLocations: items.length, items: items }
    return result
  }

  // ============================================================
  // 个人主页
  // ============================================================

  static async getPublishedCapsules(page?: number, pageSize?: number): Promise<PublishedCapsulesResponse> {
    const p = page || 1
    const ps = pageSize || 10
    const start = (p - 1) * ps
    const items: PublishedCapsuleItem[] = []
    for (let i = start; i < start + ps && i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      const item: PublishedCapsuleItem = {
        capsuleId: c.id, title: c.title, content: c.summary, mood: c.mood,
        location: c.location, latitude: c.latitude, longitude: c.longitude,
        publishedAt: ApiService.nowIso(), timeAgo: '刚刚', isPrivate: false, visibilityLabel: '公开'
      }
      items.push(item)
    }
    const statistics: CapsuleStatistics = {
      totalCount: ApiService.capsules.length, privateCount: 0, publicCount: ApiService.capsules.length
    }
    const pagination: Pagination = { page: p, pageSize: ps, total: ApiService.capsules.length }
    const result: PublishedCapsulesResponse = { items: items, statistics: statistics, pagination: pagination }
    return result
  }

  static async getFavoriteCapsules(page?: number, pageSize?: number): Promise<FavoriteCapsulesResponse> {
    const p = page || 1
    const ps = pageSize || 10
    const likedIds: number[] = []
    ApiService.likes.forEach((value: number) => { likedIds.push(value) })
    const likedCapsules: CapsuleData[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const c = ApiService.capsules[i]
      for (let j = 0; j < likedIds.length; j++) {
        if (c.id === likedIds[j]) { likedCapsules.push(c); break }
      }
    }
    const start = (p - 1) * ps
    const items: FavoriteCapsuleItem[] = []
    for (let i = start; i < start + ps && i < likedCapsules.length; i++) {
      const c = likedCapsules[i]
      const item: FavoriteCapsuleItem = {
        capsuleId: c.id, title: c.title, location: c.location,
        latitude: c.latitude, longitude: c.longitude, mood: c.mood,
        isPrivate: false, canView: true, likedAt: ApiService.nowIso()
      }
      items.push(item)
    }
    const pagination: Pagination = { page: p, pageSize: ps, total: likedCapsules.length }
    const result: FavoriteCapsulesResponse = { items: items, pagination: pagination }
    return result
  }

  static async getEmotionDistribution(_?: number): Promise<EmotionDistributionResponse> {
    const distribution: EmotionDistributionItem[] = [
      { mood: '平静', count: 8, percentage: 36.36 },
      { mood: '快乐', count: 6, percentage: 27.27 },
      { mood: '浪漫', count: 4, percentage: 18.18 },
      { mood: '焦虑', count: 3, percentage: 13.64 },
      { mood: '孤独', count: 1, percentage: 4.55 }
    ]
    const result: EmotionDistributionResponse = {
      totalCapsules: 22, topThreeTags: ['平静', '快乐', '浪漫'],
      topFiveTags: ['平静', '快乐', '浪漫', '焦虑', '孤独'], distribution: distribution
    }
    return result
  }

  static async getWeeklyReport(_?: number): Promise<WeeklyReportResponse> {
    const weekRange: WeekRange = { startDate: '2026-07-06', endDate: '2026-07-12' }
    const trend: MoodTrend = { risingMoods: ['浪漫', '快乐'], fallingMoods: ['焦虑'] }
    const result: WeeklyReportResponse = {
      weekRange: weekRange,
      summary: '这周情绪整体平稳，浪漫与快乐占比提升，焦虑略有下降。',
      trend: trend,
      suggestions: ['给自己安排一次不看手机的散步', '把今天的小成就写成一条胶囊']
    }
    return result
  }

  // ============================================================
  // PC 连接
  // ============================================================

  static async getPcConnectRequest(): Promise<PcConnectRequestData> {
    const result: PcConnectRequestData = { hasPendingRequest: false }
    return result
  }

  static async confirmPcConnectRequest(payload: PcConnectConfirmRequest): Promise<PcConnectConfirmResponse> {
    const result: PcConnectConfirmResponse = {
      requestId: payload.requestId, action: payload.action,
      connected: payload.action === 'approve'
    }
    return result
  }

  static async startPcPair(payload: PcPairStartRequest): Promise<PcPairStartResponse> {
    const result: PcPairStartResponse = {
      pairCode: 'mock-pair-code-123', status: 'pending_confirmation',
      requiresConfirmation: true, trustedPreviously: false,
      sourceDeviceType: payload.sourceDeviceType, sourceDeviceName: payload.sourceDeviceName,
      targetDeviceType: payload.targetDeviceType,
      targetDeviceName: payload.targetDeviceName || 'Unknown Device',
      locationHint: payload.locationHint || '',
      confirmTip: 'same-account pair needs first confirmation'
    }
    return result
  }

  static async getPcPairStatus(pairCode: string): Promise<PcPairStatusResponse> {
    const initiator: PcPairDeviceInfo = { deviceType: 'mobile', deviceName: 'My Phone' }
    const target: PcPairDeviceInfo = { deviceType: 'pc', deviceName: 'My PC' }
    const result: PcPairStatusResponse = {
      pairCode: pairCode, pairKey: 'mobile:pc', status: 'pending_confirmation',
      requiresConfirmation: true, trustedPreviously: false,
      initiator: initiator, target: target, locationHint: '',
      createdAt: ApiService.nowIso(), handledAt: null
    }
    return result
  }

  static async confirmPcPair(payload: PcPairConfirmRequest): Promise<PcPairConfirmResponse> {
    const status = payload.action === 'approve' ? 'approved' : 'rejected'
    const result: PcPairConfirmResponse = {
      pairCode: payload.pairCode, action: payload.action, status: status,
      requiresConfirmation: false, trustedPreviously: true, handledAt: ApiService.nowIso()
    }
    return result
  }

  // ============================================================
  // AI
  // ============================================================

  static async generateNarrative(capsuleIds?: number[], _?: string): Promise<AiNarrativeResponse> {
    const count = capsuleIds ? capsuleIds.length : ApiService.capsules.length
    const result: AiNarrativeResponse = {
      text: '这段时光里，你在图书馆留下了平静的思考，在操场感受了浪漫的落日，在信息楼体验了代码跑通的喜悦。每一刻都是青春独特的印记。',
      capsuleCount: count
    }
    return result
  }

  static async analyzeEmotion(_?: number[], __?: string): Promise<AiEmotionItem[]> {
    const items: AiEmotionItem[] = [
      { label: '平静', count: 8, color: '#4A90D9' },
      { label: '快乐', count: 6, color: '#F5A623' },
      { label: '浪漫', count: 4, color: '#E8917E' },
      { label: '焦虑', count: 3, color: '#5DADE2' },
      { label: '孤独', count: 1, color: '#7F8C8D' }
    ]
    return items
  }

  static async aiRewrite(content: string, style?: string): Promise<AiRewriteResponse> {
    const result: AiRewriteResponse = {
      originalText: content, polishedText: `${content}（润色后）`, style: style || 'literary'
    }
    return result
  }

  static async aiVoiceOptimize(content: string): Promise<AiVoiceOptimizeResponse> {
    const result: AiVoiceOptimizeResponse = {
      originalText: content, optimizedText: `${content}（语音优化后）`
    }
    return result
  }

  static async aiFormatCode(content: string, language?: string): Promise<AiCodeFormatResponse> {
    const lang = language || 'plaintext'
    const result: AiCodeFormatResponse = {
      originalCode: content, formattedCode: content,
      highlightHtml: `<pre><code class="language-${lang}">${content}</code></pre>`,
      language: lang
    }
    return result
  }
}