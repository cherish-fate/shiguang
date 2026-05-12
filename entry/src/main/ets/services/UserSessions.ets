import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const PREFERENCES_NAME = 'auth_preferences'
const KEY_TOKEN = 'auth_token'
const KEY_USER_ID = 'user_id'
const KEY_NICKNAME = 'nickname'
const KEY_PHONE_MASKED = 'phone_masked'
const KEY_IS_LOGGED_IN = 'is_logged_in'

export class AuthState {
  private static preferences: preferences.Preferences | null = null

  static isLoggedIn: boolean = false
  static isGuest: boolean = false
  static userId: string = ''
  static nickname: string = '拾光旅人'
  static phoneMasked: string = ''
  static token: string = ''
  static capsuleCount: number = 12
  static likeCount: number = 48
  static footprintCount: number = 7

  static async init(context: common.Context): Promise<void> {
    try {
      AuthState.preferences = await preferences.getPreferences(context, PREFERENCES_NAME)
      AuthState.token = (await AuthState.preferences.get(KEY_TOKEN, '')) as string
      AuthState.userId = (await AuthState.preferences.get(KEY_USER_ID, '')) as string
      AuthState.nickname = (await AuthState.preferences.get(KEY_NICKNAME, '拾光旅人')) as string
      AuthState.phoneMasked = (await AuthState.preferences.get(KEY_PHONE_MASKED, '')) as string
      AuthState.isLoggedIn = (await AuthState.preferences.get(KEY_IS_LOGGED_IN, false)) as boolean
    } catch (error) {
      console.error('Failed to init auth state:', error)
    }
  }

  static async saveLoginState(token: string, userId: string, nickname: string, phoneMasked: string): Promise<void> {
    AuthState.token = token
    AuthState.userId = userId
    AuthState.nickname = nickname
    AuthState.phoneMasked = phoneMasked
    AuthState.isLoggedIn = true
    AuthState.isGuest = false

    if (AuthState.preferences) {
      await AuthState.preferences.put(KEY_TOKEN, token)
      await AuthState.preferences.put(KEY_USER_ID, userId)
      await AuthState.preferences.put(KEY_NICKNAME, nickname)
      await AuthState.preferences.put(KEY_PHONE_MASKED, phoneMasked)
      await AuthState.preferences.put(KEY_IS_LOGGED_IN, true)
      await AuthState.preferences.flush()
    }
  }

  static async clearLoginState(): Promise<void> {
    AuthState.token = ''
    AuthState.userId = ''
    AuthState.nickname = '拾光旅人'
    AuthState.phoneMasked = ''
    AuthState.isLoggedIn = false
    AuthState.isGuest = false

    if (AuthState.preferences) {
      await AuthState.preferences.delete(KEY_TOKEN)
      await AuthState.preferences.delete(KEY_USER_ID)
      await AuthState.preferences.delete(KEY_NICKNAME)
      await AuthState.preferences.delete(KEY_PHONE_MASKED)
      await AuthState.preferences.delete(KEY_IS_LOGGED_IN)
      await AuthState.preferences.flush()
    }
  }
}
