import type {
  CapsuleType,
  CapsuleBrief,
  PublishCapsuleRequest,
  PublishCapsuleResponse,
  SendCodeRequest,
  SendCodeResponse,
  RegisterRequest,
  RegisterResponse,
  LoginRequest,
  LoginResponse,
  AgreementResponse,
  FileUploadResponse,
  AiPolishRequest,
  AiPolishResponse,
  AiAsrRequest,
  AiAsrResponse,
  CapsuleListResponse,
  EmotionStreamResponse,
  EmotionStreamItem,
  CommentResponse,
  AddCommentResponse,
  FavoriteResponse,
  UserProfile,
  UpdateProfileRequest,
  UpdatePasswordRequest,
  UserStats,
  UserCapsule,
  MoodDistribution,
  AiMoodReport
} from './ApiService'

export type {
  CapsuleType,
  CapsuleBrief,
  PublishCapsuleRequest,
  PublishCapsuleResponse,
  SendCodeRequest,
  SendCodeResponse,
  RegisterRequest,
  RegisterResponse,
  LoginRequest,
  LoginResponse,
  AgreementResponse,
  FileUploadResponse,
  AiPolishRequest,
  AiPolishResponse,
  AiAsrRequest,
  AiAsrResponse,
  CapsuleListResponse,
  EmotionStreamResponse,
  EmotionStreamItem,
  CommentResponse,
  AddCommentResponse,
  FavoriteResponse,
  UserProfile,
  UpdateProfileRequest,
  UpdatePasswordRequest,
  UserStats,
  UserCapsule,
  MoodDistribution,
  AiMoodReport
}

export interface ApiConfig {
  baseUrl?: string
  timeoutMs?: number
}

const MOCK_PHONE: string = '12345678901'
const MOCK_CODE: string = '124569'
const MOCK_TOKEN: string = 'mock-token'
const MOCK_USER_ID: string = '1001'

export class ApiService {
  private static authToken: string = ''
  private static password: string = 'password123'
  private static profile: UserProfile = {
    nickname: '拾光旅人',
    grade: '2024',
    college: '计算机学院',
    avatar: '',
    phone: MOCK_PHONE
  }
  private static capsuleIdSeed: number = 100
  private static capsules: CapsuleListResponse[] = [
    {
      id: '1',
      moodTag: '# 平静青',
      content: '傍晚的风从教学楼走廊吹过，像把今天的烦躁都带走了。',
      location: '金明校区图书馆',
      createdAt: ApiService.nowIso(),
      latitude: 34.815278,
      longitude: 144.302222,
      distanceMeters: 58,
      isPrivate: false,
      likes: 12,
      views: 64
    },
    {
      id: '2',
      moodTag: '# 浪漫粉',
      content: '落日把操场染成橘色，篮球撞击地面的声音像是节拍器。',
      location: '金明校区操场',
      createdAt: ApiService.nowIso(),
      latitude: 34.814510,
      longitude: 134.300930,
      distanceMeters: 40,
      isPrivate: false,
      likes: 9,
      views: 53
    },
    {
      id: '4',
      moodTag: '# 极客紫',
      content: '一行代码跑通的瞬间，世界都清晰了。',
      location: '信息工程楼',
      createdAt: ApiService.nowIso(),
      latitude: 34.816820,
      longitude: 114.304560,
      distanceMeters: 310,
      isPrivate: false,
      likes: 14,
      views: 70
    },
    {
      id: '5',
      moodTag: '# 焦虑蓝',
      content: '明天的汇报还有好多细节没想好，希望能顺利。',
      location: '教学楼 A 区',
      createdAt: ApiService.nowIso(),
      latitude: 34.815910,
      longitude: 114.303880,
      distanceMeters: 180,
      isPrivate: true,
      likes: 0,
      views: 4
    },
    {
      id: '6',
      moodTag: '# 孤独灰',
      content: '夜里走过林荫道，听见树叶碰撞的声音。',
      location: '林荫道',
      createdAt: ApiService.nowIso(),
      latitude: 34.813660,
      longitude: 114.301120,
      distanceMeters: 520,
      isPrivate: false,
      likes: 3,
      views: 18
    }
  ]
  private static comments: Record<string, CommentResponse[]> = {
    '1': [
      { id: 'c1', text: '这里的风确实很舒服。', createdAt: ApiService.nowIso() },
      { id: 'c2', text: '我也在这儿写过作业。', createdAt: ApiService.nowIso() }
    ],
    '2': [
      { id: 'c3', text: '操场的夕阳太治愈了。', createdAt: ApiService.nowIso() }
    ],
    '4': [
      { id: 'c4', text: '同感，debug 成功像中彩票。', createdAt: ApiService.nowIso() },
      { id: 'c5', text: '今晚也要把小功能写完！', createdAt: ApiService.nowIso() }
    ]
  }
  private static favorites: Set<string> = new Set(['2', '4'])

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

  private static nextCapsuleId(): string {
    ApiService.capsuleIdSeed += 1
    return ApiService.capsuleIdSeed.toString()
  }

  private static fileNameFromPath(filePath: string): string {
    const normalized = filePath.replace(/\\/g, '/')
    const idx = normalized.lastIndexOf('/')
    return idx >= 0 ? normalized.substring(idx + 1) : normalized
  }

  static async queryNearbyCapsules(): Promise<CapsuleBrief[]> {
    return [
      { id: '1', name: '图书馆的风', emoji: '🍃', distanceMeters: 128 },
      { id: '2', name: '操场落日', emoji: '🌇', distanceMeters: 240 },
      { id: '4', name: '代码通过了', emoji: '💻', distanceMeters: 310 }
    ]
  }

  static async publishCapsule(payload: PublishCapsuleRequest): Promise<PublishCapsuleResponse> {
    const id = ApiService.nextCapsuleId()
    ApiService.capsules.unshift({
      id,
      moodTag: payload.moodTag,
      content: payload.content,
      location: payload.location || 'Mock Location',
      createdAt: ApiService.nowIso(),
      latitude: 34.815278,
      longitude: 114.302222,
      distanceMeters: 0,
      isPrivate: payload.isPrivate,
      likes: 0,
      views: 0
    })
    return { id, createdAt: ApiService.nowIso() }
  }

  static async sendCode(payload: SendCodeRequest): Promise<SendCodeResponse> {
    ApiService.ensureValidPhone(payload.phone)
    return { success: true }
  }

  static async register(payload: RegisterRequest): Promise<RegisterResponse> {
    ApiService.ensureValidPhone(payload.phone)
    ApiService.ensureValidCode(payload.code)
    ApiService.profile = {
      nickname: payload.nickname,
      grade: payload.grade,
      college: payload.college,
      avatar: payload.avatar || '',
      phone: payload.phone
    }
    ApiService.password = payload.password
    return {
      token: MOCK_TOKEN,
      userId: MOCK_USER_ID,
      nickname: payload.nickname
    }
  }

  static async login(payload: LoginRequest): Promise<LoginResponse> {
    ApiService.ensureValidPhone(payload.phone)
    ApiService.ensureValidCode(payload.code)
    return {
      token: MOCK_TOKEN,
      userId: MOCK_USER_ID,
      nickname: ApiService.profile.nickname || 'MockUser'
    }
  }

  static async getAgreement(type: 'agreement' | 'privacy'): Promise<AgreementResponse> {
    return { content: `Mock ${type} content` }
  }

  static async uploadFile(filePath: string): Promise<FileUploadResponse> {
    const filename = ApiService.fileNameFromPath(filePath)
    return {
      url: `mock://files/${filename}`,
      filename,
      size: 12345,
      mimeType: 'application/octet-stream'
    }
  }

  static async aiPolish(payload: AiPolishRequest): Promise<AiPolishResponse> {
    return { content: `${payload.content} (polished)` }
  }

  static async aiAsr(_: AiAsrRequest): Promise<AiAsrResponse> {
    return { text: 'mock transcription' }
  }

  static async getCapsules(_: string): Promise<CapsuleListResponse[]> {
    return [...ApiService.capsules]
  }

  static async getNearbyCapsules(_: number, __: number, ___: number): Promise<CapsuleListResponse[]> {
    return ApiService.capsules.filter(item => !item.isPrivate)
  }

  static async getEmotionStream(_: string = ''): Promise<EmotionStreamResponse> {
    const items: EmotionStreamItem[] = [
      {
        campus: 'jinming',
        location: '金明校区图书馆',
        latitude: 34.815278,
        longitude: 114.302222,
        capsuleCount: 18,
        moodKeywords: ['平静', '治愈', '专注'],
        isNewLocation: false,
        updatedAt: ApiService.nowIso()
      },
      {
        campus: 'minglun',
        location: '明伦校区主楼',
        latitude: 34.797120,
        longitude: 114.356780,
        capsuleCount: 9,
        moodKeywords: ['活力', '期待', '踏实'],
        isNewLocation: true,
        updatedAt: ApiService.nowIso()
      }
    ]
    return { totalLocations: items.length, items }
  }

  static async getComments(capsuleId: string): Promise<CommentResponse[]> {
    const existing = ApiService.comments[capsuleId]
    return existing ? existing.slice() : []
  }

  static async addComment(capsuleId: string, text: string): Promise<AddCommentResponse> {
    const comment: CommentResponse = {
      id: `c${Date.now()}`,
      text,
      createdAt: ApiService.nowIso()
    }
    if (!ApiService.comments[capsuleId]) {
      ApiService.comments[capsuleId] = []
    }
    ApiService.comments[capsuleId].push(comment)
    return { success: true, commentId: comment.id }
  }

  static async toggleFavorite(capsuleId: string): Promise<FavoriteResponse> {
    if (ApiService.favorites.has(capsuleId)) {
      ApiService.favorites.delete(capsuleId)
      return { success: true, favorited: false }
    }
    ApiService.favorites.add(capsuleId)
    return { success: true, favorited: true }
  }

  static async getUserProfile(): Promise<UserProfile> {
    return ApiService.cloneUserProfile(ApiService.profile)
  }

  static async updateUserProfile(payload: UpdateProfileRequest): Promise<UserProfile> {
    if (payload.nickname !== undefined) {
      ApiService.profile.nickname = payload.nickname
    }
    if (payload.grade !== undefined) {
      ApiService.profile.grade = payload.grade
    }
    if (payload.college !== undefined) {
      ApiService.profile.college = payload.college
    }
    if (payload.avatar !== undefined) {
      ApiService.profile.avatar = payload.avatar
    }
    return ApiService.cloneUserProfile(ApiService.profile)
  }

  static async updatePassword(payload: UpdatePasswordRequest): Promise<void> {
    if (payload.oldPassword !== ApiService.password) {
      throw new Error('Mock password mismatch')
    }
    ApiService.password = payload.newPassword
  }

  static async getUserStats(): Promise<UserStats> {
    const stats: UserStats = {
      capsuleCount: ApiService.capsules.length,
      favoriteCount: ApiService.favorites.size,
      locationCount: 3
    }
    return stats
  }

  static async getUserCapsules(): Promise<UserCapsule[]> {
    const results: UserCapsule[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      results.push(ApiService.toUserCapsule(ApiService.capsules[i]))
    }
    return results
  }

  static async getUserFavorites(): Promise<UserCapsule[]> {
    const favoriteIds = Array.from(ApiService.favorites)
    const results: UserCapsule[] = []
    for (let i = 0; i < ApiService.capsules.length; i++) {
      const capsule = ApiService.capsules[i]
      if (favoriteIds.includes(capsule.id)) {
        results.push(ApiService.toUserCapsule(capsule))
      }
    }
    return results
  }

  static async getUserMoodDistribution(): Promise<MoodDistribution[]> {
    return [
      { label: '平静', count: 8, percent: 36 },
      { label: '快乐', count: 6, percent: 27 },
      { label: '浪漫', count: 4, percent: 18 },
      { label: '焦虑', count: 3, percent: 14 },
      { label: '孤独', count: 1, percent: 5 }
    ]
  }

  static async getAiMoodReport(): Promise<AiMoodReport> {
    return {
      summary: '这周情绪整体平稳，浪漫与快乐占比提升，焦虑略有下降。',
      suggestions: ['给自己安排一次不看手机的散步', '把今天的小成就写成一条胶囊']
    }
  }

  private static cloneUserProfile(profile: UserProfile): UserProfile {
    const cloned: UserProfile = {
      nickname: profile.nickname,
      grade: profile.grade,
      college: profile.college,
      avatar: profile.avatar,
      phone: profile.phone
    }
    return cloned
  }

  private static toUserCapsule(item: CapsuleListResponse): UserCapsule {
    const capsule: UserCapsule = {
      id: item.id,
      moodTag: item.moodTag,
      content: item.content,
      location: item.location,
      createdAt: item.createdAt,
      isPrivate: item.isPrivate,
      likes: item.likes,
      views: item.views
    }
    return capsule
  }
}
