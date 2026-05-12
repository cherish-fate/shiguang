import { promptAction } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import fs from '@ohos.file.fs'

export type CapsuleType = 'text' | 'audio' | 'code'

export interface CapsuleBrief {
  id: string
  name: string
  emoji: string
  distanceMeters: number
}

export interface PublishCapsuleRequest {
  type: CapsuleType
  moodTag: string
  content: string
  attachments: string[]
  location: string,
  isPrivate:boolean
}

export interface PublishCapsuleResponse {
  id: string
  createdAt: string
}

export interface SendCodeRequest {
  phone: string
}

export interface SendCodeResponse {
  success: boolean
}

export interface RegisterRequest {
  nickname: string
  phone: string
  code: string
  password: string
  grade: string
  college: string
  avatar?: string
}

export interface UserProfile {
  nickname: string
  grade: string
  college: string
  avatar: string
  phone: string
}

export interface UpdateProfileRequest {
  nickname?: string
  grade?: string
  college?: string
  avatar?: string
}

export interface UpdatePasswordRequest {
  oldPassword: string
  newPassword: string
}

export interface UserStats {
  capsuleCount: number
  favoriteCount: number
  locationCount: number
}

export interface UserCapsule {
  id: string
  moodTag: string
  content: string
  location: string
  createdAt: string
  isPrivate: boolean
  likes: number
  views: number
}

export interface MoodDistribution {
  label: string
  count: number
  percent: number
}

export interface AiMoodReport {
  summary: string
  suggestions: string[]
}

export interface RegisterResponse {
  token: string
  userId: string
  nickname: string
}

export interface LoginRequest {
  phone: string
  code: string
}

export interface LoginResponse {
  token: string
  userId: string
  nickname: string
}

export interface AgreementRequest {
  type: 'agreement' | 'privacy'
}

export interface AgreementResponse {
  content: string
}

export interface FileUploadResponse {
  url: string
  filename: string
  size: number
  mimeType: string
}

export interface AiPolishRequest {
  content: string
}

export interface AiPolishResponse {
  content: string
}

export interface AiAsrRequest {
  audioBase64: string
}

export interface AiAsrResponse {
  text: string
}

export interface CapsuleListResponse {
  id: string
  moodTag: string
  content: string
  location: string
  createdAt: string
  latitude: number
  longitude: number
  distanceMeters: number
  isPrivate: boolean
  likes: number
  views: number
}

export interface EmotionStreamResponse {
  totalLocations: number
  items: EmotionStreamItem[]
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

export interface NearbyCapsuleRequest {
  latitude: number
  longitude: number
  radius: number
}

export interface CommentResponse {
  id: string
  text: string
  createdAt: string
}

export interface AddCommentRequest {
  capsuleId: string
  text: string
}

export interface AddCommentBody {
  text: string
}

export interface AddCommentResponse {
  success: boolean
  commentId: string
}

export interface FavoriteResponse {
  success: boolean
  favorited: boolean
}

interface ApiEnvelope<T> {
  code?: number
  message?: string
  data?: T
}

export interface ApiConfig {
  baseUrl?: string
  timeoutMs?: number
}

export interface RequestOptions {
  headers?: Record<string, string>
  query?: Record<string, string | number | boolean>
}

export class ApiService {
  private static baseUrl: string = 'http://10.16.149.127:3000'
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
      promptAction.showToast({ message })
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
        method,
        header: ApiService.buildHeaders(headers),
        connectTimeout: ApiService.timeoutMs,
        readTimeout: ApiService.timeoutMs,
        extraData,
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

  static async queryNearbyCapsules(): Promise<CapsuleBrief[]> {
    return await ApiService.request<CapsuleBrief[]>('/capsules/nearby', http.RequestMethod.GET)
  }

  static async publishCapsule(payload: PublishCapsuleRequest): Promise<PublishCapsuleResponse> {
    return await ApiService.request<PublishCapsuleResponse>('/capsules', http.RequestMethod.POST, payload)
  }

  static async sendCode(payload: SendCodeRequest): Promise<SendCodeResponse> {
    return await ApiService.request<SendCodeResponse>('/user/send-code', http.RequestMethod.POST, payload)
  }

  static async register(payload: RegisterRequest): Promise<RegisterResponse> {
    return await ApiService.request<RegisterResponse>('/user/register', http.RequestMethod.POST, payload)
  }

  static async login(payload: LoginRequest): Promise<LoginResponse> {
    return await ApiService.request<LoginResponse>('/user/login', http.RequestMethod.POST, payload)
  }

  static async getAgreement(type: 'agreement' | 'privacy'): Promise<AgreementResponse> {
    return await ApiService.request<AgreementResponse>(`/agreement/content?type=${type}`, http.RequestMethod.GET)
  }

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
      bodyParts.push(`--${boundary}`)
      bodyParts.push(`Content-Disposition: form-data; name="file"; filename="${filename}"`)
      bodyParts.push('Content-Type: application/octet-stream')
      bodyParts.push('')
      bodyParts.push(base64Content)
      bodyParts.push(`--${boundary}--`)
      bodyParts.push('')
      
      const body: string = bodyParts.join('\r\n')
      
      const response: http.HttpResponse = await client.request(ApiService.buildUrl('/file/upload'), {
        method: http.RequestMethod.POST,
        header: ApiService.buildHeaders({
          'Content-Type': `multipart/form-data; boundary=${boundary}`
        }),
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

  static async aiPolish(payload: AiPolishRequest): Promise<AiPolishResponse> {
    return await ApiService.request<AiPolishResponse>('/ai/polish', http.RequestMethod.POST, payload)
  }

  static async aiAsr(payload: AiAsrRequest): Promise<AiAsrResponse> {
    return await ApiService.request<AiAsrResponse>('/ai/asr', http.RequestMethod.POST, payload)
  }

  static async getCapsules(campus: string): Promise<CapsuleListResponse[]> {
    return await ApiService.request<CapsuleListResponse[]>(`/capsules?campus=${campus}`, http.RequestMethod.GET)
  }

  static async getNearbyCapsules(latitude: number, longitude: number, radius: number): Promise<CapsuleListResponse[]> {
    return await ApiService.request<CapsuleListResponse[]>(
      `/capsules/nearby?latitude=${latitude}&longitude=${longitude}&radius=${radius}`, 
      http.RequestMethod.GET
    )
  }

  static async getEmotionStream(updatedAfter?: string): Promise<EmotionStreamResponse> {
    const url = updatedAfter 
      ? `/map/emotion-stream?updatedAfter=${updatedAfter}` 
      : '/map/emotion-stream'
    return await ApiService.request<EmotionStreamResponse>(url, http.RequestMethod.GET)
  }

  static async getComments(capsuleId: string): Promise<CommentResponse[]> {
    return await ApiService.request<CommentResponse[]>(`/capsules/${capsuleId}/comments`, http.RequestMethod.GET)
  }

  static async addComment(capsuleId: string, text: string): Promise<AddCommentResponse> {
    const body: AddCommentBody = { text }
    return await ApiService.request<AddCommentResponse>(
      `/capsules/${capsuleId}/comments`, 
      http.RequestMethod.POST, 
      body
    )
  }

  static async toggleFavorite(capsuleId: string): Promise<FavoriteResponse> {
    return await ApiService.request<FavoriteResponse>(
      `/capsules/${capsuleId}/favorite`, 
      http.RequestMethod.POST
    )
  }

  static async getUserProfile(): Promise<UserProfile> {
    return await ApiService.request<UserProfile>('/user/profile', http.RequestMethod.GET)
  }

  static async updateUserProfile(payload: UpdateProfileRequest): Promise<UserProfile> {
    return await ApiService.request<UserProfile>('/user/profile', http.RequestMethod.PUT, payload)
  }

  static async updatePassword(payload: UpdatePasswordRequest): Promise<void> {
    return await ApiService.request<void>('/user/password', http.RequestMethod.PUT, payload)
  }

  static async getUserStats(): Promise<UserStats> {
    return await ApiService.request<UserStats>('/user/stats', http.RequestMethod.GET)
  }

  static async getUserCapsules(): Promise<UserCapsule[]> {
    return await ApiService.request<UserCapsule[]>('/user/capsules', http.RequestMethod.GET)
  }

  static async getUserFavorites(): Promise<UserCapsule[]> {
    return await ApiService.request<UserCapsule[]>('/user/favorites', http.RequestMethod.GET)
  }

  static async getUserMoodDistribution(): Promise<MoodDistribution[]> {
    return await ApiService.request<MoodDistribution[]>('/user/mood-distribution', http.RequestMethod.GET)
  }

  static async getAiMoodReport(): Promise<AiMoodReport> {
    return await ApiService.request<AiMoodReport>('/ai/mood-report', http.RequestMethod.GET)
  }
}
