import { router, promptAction } from '@kit.ArkUI'
//import { geolocation } from '@kit.LocationKit'
import { geoLocationManager } from '@kit.LocationKit';
import { CapsuleMapMarker } from './components/CapsuleMapMarker'
import { ApiService, CapsuleListResponse, EmotionStreamResponse, EmotionStreamItem, CommentResponse } from '../services/MockApiService'
import {
  CampusId,
  CampusBounds,
  DEFAULT_CAMPUS_BOUNDS,
  MapPosition,
  MapCapsuleMarker,
  AnonymousReplyItem,
  MoodKind,
  haloColorForMood,
  moodKindFromPublishTag
} from './models/ArMapModels'

/** 判定「附近」的最大距离（米），可与定位结果联动调整 */
const NEARBY_RADIUS_METERS: number = 100

/** 悬浮情绪按钮初始位置（vp，左上锚点） */
const EMOTION_FAB_INIT_X: number = 286
const EMOTION_FAB_INIT_Y: number = 156
interface CampusBoundss {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
}
interface CampusBoundsMap {
  jinming: CampusBounds;
  minglun?: CampusBounds;  // 可选，如果后续需要添加明伦校区
}

@Entry
@Component
struct ArTreasureMapPage {
  @State private campus: CampusId = 'jinming'
  @State private capsules: MapCapsuleMarker[] = []
  @State private showDetailSheet: boolean = false
  @State private selectedCapsuleId: string = ''
  @State private replyDraft: string = ''
  @State private loading: boolean = false

  @State private emotionPanelExpanded: boolean = false
  @State private emotionFabX: number = EMOTION_FAB_INIT_X
  @State private emotionFabY: number = EMOTION_FAB_INIT_Y
  @State private panDidMove: boolean = false
  private panBaseX: number = 0
  private panBaseY: number = 0

  @State private currentLatitude: number = 0
  @State private currentLongitude: number = 0
  @State private emotionStream: EmotionStreamItem[] = []
  @State private lastUpdateTime: string = ''

  aboutToAppear(): void {
    this.getCurrentLocation()
    this.loadEmotionStream()
  }

  // private async getCurrentLocation(): Promise<void> {
  //   try {
  //     const location = await geolocation.getCurrentLocation({
  //       timeoutMs: 10000,
  //       enableHighAccuracy: true
  //     })
  //     const loc = location as geolocation.Location
  //     this.currentLatitude = loc.latitude
  //     this.currentLongitude = loc.longitude
  //     this.loadNearbyCapsules()
  //   } catch (error) {
  //     console.error('Failed to get location:', error)
  //     promptAction.showToast({ message: '定位失败，使用默认数据' })
  //     this.loadCapsules()
  //   }
  // }
  private async getCurrentLocation(): Promise<void> {
    try {
      // 1. 检查定位是否开启（防止直接抛异常）
      if (!geoLocationManager.isLocationEnabled()) {
        promptAction.showToast({ message: '请先开启定位服务' });
        // 这里不 return，让后续逻辑走默认数据
      }

      // 2. 使用正确的 API：geoLocationManager.getCurrentLocation
      const location = await geoLocationManager.getCurrentLocation({
        // priority: 定位优先级，ACCURACY 代表高精度（GPS），LOW_POWER 代表省电（网络）
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        // scenario: 使用场景，NAVIGATION 适合快速移动场景
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION,
        // 超时时间，单位毫秒，对应你原来的 timeoutMs
        timeoutMs: 10000
      });

      // 3. location 本身就是 Location 类型，不需要强制转换
      this.currentLatitude = location.latitude;
      this.currentLongitude = location.longitude;

      // 4. 获取到位置后加载附近胶囊
      this.loadNearbyCapsules();
    } catch (error) {
      console.error('Failed to get location:', error);
      promptAction.showToast({ message: '定位失败，使用默认数据' });

      // 定位失败时回退到普通加载（全量数据）
      this.loadCapsules();
    }
  }

  private async loadNearbyCapsules(): Promise<void> {
    this.loading = true
    try {
      const response = await ApiService.getNearbyCapsules(
        this.currentLatitude,
        this.currentLongitude,
        NEARBY_RADIUS_METERS
      )
      this.capsules = response
        .filter(item => !item.isPrivate)
        .map(item => this.convertToMapMarker(item))
    } catch (error) {
      console.error('Failed to load nearby capsules:', error)
      this.capsules = this.getDefaultMarkers()
      promptAction.showToast({ message: '加载附近胶囊失败，显示本地数据' })
    } finally {
      this.loading = false
    }
  }

  private async loadCapsules(): Promise<void> {
    this.loading = true
    try {
      const response = await ApiService.getCapsules(this.campus)
      this.capsules = response
        .filter(item => !item.isPrivate)
        .map(item => this.convertToMapMarker(item))
    } catch (error) {
      console.error('Failed to load capsules:', error)
      this.capsules = this.getDefaultMarkers()
      promptAction.showToast({ message: '加载胶囊失败，显示本地数据' })
    } finally {
      this.loading = false
    }
  }

  private async loadEmotionStream(): Promise<void> {
    try {
      const response: EmotionStreamResponse = await ApiService.getEmotionStream(this.lastUpdateTime)
      if (response.items && response.items.length > 0) {
        this.emotionStream = response.items
        if (response.items.length > 0) {
          this.lastUpdateTime = response.items[0].updatedAt
        }
      }
    } catch (error) {
      console.error('Failed to load emotion stream:', error)
    }
  }

  private convertMapPctToLat(x: number): number {
    const bounds: CampusBounds = DEFAULT_CAMPUS_BOUNDS.getBounds(this.campus)
    return bounds.maxLat - (x / 100) * (bounds.maxLat - bounds.minLat)
  }

  private convertMapPctToLng(y: number): number {
    const bounds: CampusBounds = DEFAULT_CAMPUS_BOUNDS.getBounds(this.campus)
    return bounds.minLng + (y / 100) * (bounds.maxLng - bounds.minLng)
  }

  private convertLatLngToMapPct(latitude: number, longitude: number): MapPosition {
    const bounds: CampusBounds = DEFAULT_CAMPUS_BOUNDS.getBounds(this.campus)

    const x = ((longitude - bounds.minLng) / (bounds.maxLng - bounds.minLng)) * 100
    const y = ((bounds.maxLat - latitude) / (bounds.maxLat - bounds.minLat)) * 100

    return {
      x: Math.max(5, Math.min(95, x)),
      y: Math.max(5, Math.min(95, y))
    }
  }

  private convertToMapMarker(item: CapsuleListResponse): MapCapsuleMarker {
    const moodKind = moodKindFromPublishTag(item.moodTag)
    return {
      id: item.id,
      campus: this.campus,
      moodKind: moodKind,
      moodLabel: this.getMoodLabel(moodKind),
      moodEmoji: this.getMoodEmoji(moodKind),
      locationName: item.location,
      content: item.content,
      timeAgo: this.formatTimeAgo(item.createdAt),
      latitude: item.latitude,
      longitude: item.longitude,
      distanceMeters: item.distanceMeters,
      lightCount: item.likes,
      isLitByMe: false,
      replies: []
    }
  }

  private getMoodLabel(kind: MoodKind): string {
    switch (kind) {
      case 'anxiety': return '焦虑'
      case 'romance': return '浪漫'
      case 'vitality': return '活力'
      case 'geek': return '极客'
      default: return '未知'
    }
  }

  private getMoodEmoji(kind: MoodKind): Resource {
    switch (kind) {
      case 'anxiety': return $r('app.media.mine_anxiety')
      case 'romance': return $r('app.media.mine_romance')
      case 'vitality': return $r('app.media.mine_happy')
      case 'geek': return $r('app.media.map_computer')
      default: return $r('app.media.mine_anxiety')
    }
  }

  private formatTimeAgo(dateString: string): string {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMins / 60)
    const diffDays = Math.floor(diffHours / 24)

    if (diffMins < 1) return '刚刚'
    if (diffMins < 60) return `${diffMins}分钟前`
    if (diffHours < 24) return `${diffHours}小时前`
    if (diffDays < 7) return `${diffDays}天前`
    return dateString.substring(0, 10)
  }

  private getDefaultMarkers(): MapCapsuleMarker[] {
    interface DefaultLocation {
      name: string
      x: number
      y: number
      distance: number
    }
    const markers: MapCapsuleMarker[] = []
    const defaultLocations: DefaultLocation[] = [
      { name: '图书馆', x: 42, y: 48, distance: 25 },
      { name: '明德湖', x: 55, y: 42, distance: 50 },
      { name: '操场', x: 72, y: 68, distance: 80 },
      { name: '计算机学院', x: 38, y: 62, distance: 15 }
    ]
    defaultLocations.forEach((loc: DefaultLocation, index: number) => {
      const kinds: MoodKind[] = ['anxiety', 'romance', 'vitality', 'geek']
      const kind: MoodKind = kinds[index % kinds.length]
      markers.push({
        id: `default_${index}`,
        campus: this.campus,
        moodKind: kind,
        moodLabel: this.getMoodLabel(kind),
        moodEmoji: this.getMoodEmoji(kind),
        locationName: loc.name,
        content: '这是一个拾光胶囊，记录着校园里的美好时光...',
        timeAgo: '1小时前',
        latitude: this.convertMapPctToLat(loc.x),
        longitude: this.convertMapPctToLng(loc.y),
        distanceMeters: loc.distance,
        lightCount: Math.floor(Math.random() * 30) + 5,
        isLitByMe: false,
        replies: []
      })
    })
    return markers
  }

  private switchCampus(next: CampusId): void {
    if (this.campus === next) {
      return
    }
    this.campus = next
    this.showDetailSheet = false
    this.selectedCapsuleId = ''
    this.loadCapsules()
  }

  private selectedCapsule(): MapCapsuleMarker | undefined {
    return this.capsules.find((c: MapCapsuleMarker) => c.id === this.selectedCapsuleId)
  }

  private nearbyList(): MapCapsuleMarker[] {
    return this.capsules.filter((c: MapCapsuleMarker) => c.distanceMeters <= NEARBY_RADIUS_METERS)
  }

  private async openCapsule(id: string): Promise<void> {
    const hit: MapCapsuleMarker | undefined = this.capsules.find((c: MapCapsuleMarker) => c.id === id)
    if (!hit) {
      return
    }
    this.selectedCapsuleId = id
    this.showDetailSheet = true
    this.replyDraft = ''
    await this.loadComments(id)
  }

  private async loadComments(capsuleId: string): Promise<void> {
    try {
      const comments: CommentResponse[] = await ApiService.getComments(capsuleId)
      this.capsules = this.capsules.map((c: MapCapsuleMarker) => {
        if (c.id !== capsuleId) {
          return c
        }
        const replies: AnonymousReplyItem[] = comments.map((comment: CommentResponse) => {
          const reply: AnonymousReplyItem = {
            id: comment.id,
            text: comment.text,
            timeAgo: this.formatTimeAgo(comment.createdAt)
          }
          return reply
        })
        const updatedCapsule: MapCapsuleMarker = {
          id: c.id,
          campus: c.campus,
          moodKind: c.moodKind,
          moodLabel: c.moodLabel,
          moodEmoji: c.moodEmoji,
          locationName: c.locationName,
          content: c.content,
          timeAgo: c.timeAgo,
          latitude: c.latitude,
          longitude: c.longitude,
          distanceMeters: c.distanceMeters,
          lightCount: c.lightCount,
          isLitByMe: c.isLitByMe,
          replies: replies
        }
        return updatedCapsule
      })
    } catch (error) {
      console.error('Failed to load comments:', error)
    }
  }

  private closeSheet(): void {
    this.showDetailSheet = false
    this.selectedCapsuleId = ''
  }

  /** 将悬浮层限制在可视区域内（vp，近似屏宽用于 clamp） */
  private clampFabPosition(x: number, y: number): void {
    const maxX: number = 360
    const maxY: number = 780
    const fabW: number = this.emotionPanelExpanded ? 258 : 52
    const fabH: number = 52
    this.emotionFabX = Math.min(Math.max(8, x), maxX - fabW)
    this.emotionFabY = Math.min(Math.max(80, y), maxY - fabH)
  }

  private async lightUp(c: MapCapsuleMarker): Promise<void> {
    if (!this.selectedCapsuleId) {
      return
    }
    try {
      const response = await ApiService.toggleFavorite(c.id)
      if (response.success) {
        c.isLitByMe = response.favorited
        if (response.favorited) {
          c.lightCount = c.lightCount + 1
          promptAction.showToast({ message: '收藏成功' })
        } else {
          c.lightCount = Math.max(0, c.lightCount - 1)
          promptAction.showToast({ message: '取消收藏' })
        }
      }
    } catch (error) {
      console.error('Failed to toggle favorite:', error)
      promptAction.showToast({ message: '操作失败，请重试' })
    }
  }

  private async sendAnonymousReply(): Promise<void> {
    const text: string = this.replyDraft.trim()
    if (!text || !this.selectedCapsuleId) {
      return
    }
    try {
      const response = await ApiService.addComment(this.selectedCapsuleId, text)
      if (response.success) {
        const newItem: AnonymousReplyItem = {
          id: response.commentId,
          text,
          timeAgo: '刚刚'
        }
        this.capsules = this.capsules.map((c: MapCapsuleMarker) => {
          if (c.id !== this.selectedCapsuleId) {
            return c
          }
          const merged: AnonymousReplyItem[] = []
          for (let i = 0; i < c.replies.length; i++) {
            merged.push(c.replies[i])
          }
          merged.push(newItem)
          const updatedCapsule: MapCapsuleMarker = {
            id: c.id,
            campus: c.campus,
            moodKind: c.moodKind,
            moodLabel: c.moodLabel,
            moodEmoji: c.moodEmoji,
            locationName: c.locationName,
            content: c.content,
            timeAgo: c.timeAgo,
            latitude: c.latitude,
            longitude: c.longitude,
            distanceMeters: c.distanceMeters,
            lightCount: c.lightCount,
            isLitByMe: c.isLitByMe,
            replies: merged
          }
          return updatedCapsule
        })
        this.replyDraft = ''
        promptAction.showToast({ message: '评论成功' })
      }
    } catch (error) {
      console.error('Failed to send reply:', error)
      promptAction.showToast({ message: '评论失败，请重试' })
    }
  }

  @Builder
  private CampusTab(label: string, value: CampusId) {
    Column() {
      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.campus === value ? Color.White : '#1E3A5F')
    }
    .padding({ left: 28, right: 28, top: 12, bottom: 12 })
    .borderRadius(22)
    .linearGradient(this.campus === value ? {
      angle: 90,
      colors: [['#3B82F6', 0.0], ['#93C5FD', 1.0]]
    } : {
      angle: 90,
      colors: [['#FFFFFF', 0.0], ['#E8F2FF', 1.0]]
    })
    .shadow(this.campus === value ? {
      radius: 16,
      color: '#443B82F6',
      offsetX: 0,
      offsetY: 4
    } : {
      radius: 2,
      color: '#15000000',
      offsetX: 0,
      offsetY: 1
    })
    .onClick((): void => {
      this.switchCampus(value)
    })
  }

  @Builder
  private EmotionCard(item: EmotionStreamItem) {
    Column({ space: 8 }) {
      Row() {
        Image($r('app.media.map_position'))
          .width(20)
        Text(item.location)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0F172A')
        Blank()
        Text(`${item.capsuleCount}个`)
          .fontSize(12)
          .fontColor('#64748B')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor('#F1F5F9')
          .borderRadius(10)
      }
      .width('100%')

      Row({ space: 4 }) {
        Text('主要情绪:')
          .fontSize(12)
          .fontColor('#64748B')
        Text(item.moodKeywords[0] || '未知')
          .fontSize(12)
          .fontColor('#5B21B6')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(item.moodKeywords.slice(0, 4), (t: string) => {
          Text(t)
            .fontSize(11)
            .fontColor('#475569')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F8FAFC')
            .borderRadius(10)
            .margin({ right: 6, bottom: 6 })
        }, (t: string) => t)
      }
      .width('100%')
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({
      radius: 10,
      color: '#12000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  private CapsuleDetailSheet(c: MapCapsuleMarker) {
    Column({ space: 0 }) {
      Column()
        .width(40)
        .height(4)
        .borderRadius(2)
        .backgroundColor('#CBD5E1')
        .margin({ top: 10, bottom: 14 })

      Row() {
        Row({ space: 6 }) {
          Image(c.moodEmoji)
            .width(20)
          Text(c.moodLabel)
            .fontSize(14)
            .fontColor('#5B21B6')
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({
          radius: 4,
          color: '#10000000',
          offsetX: 0,
          offsetY: 1
        })

        Blank()

        Button() {
          Image($r('app.media.pop_up_close'))
            .width(16)
        }
        .width(36)
        .height(36)
        .type(ButtonType.Normal)
        .backgroundColor('#F1F5F9')
        .borderRadius(18)
        .onClick((): void => {
          this.closeSheet()
        })
      }
      .width('100%')
      .padding({ left: 4, right: 4 })

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Text('📍')
            .fontSize(12)
          Text(c.locationName)
            .fontSize(13)
            .fontColor('#475569')
        }

        Row({ space: 4 }) {
          Text('🕐')
            .fontSize(12)
          Text(c.timeAgo)
            .fontSize(13)
            .fontColor('#475569')
        }
      }
      .margin({ top: 12, bottom: 14 })
      .width('100%')

      Text(c.content)
        .fontSize(15)
        .fontColor('#1E293B')
        .lineHeight(22)
        .padding(16)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({
          radius: 8,
          color: '#0F000000',
          offsetX: 0,
          offsetY: 2
        })

      Button() {
        Row({ space: 8 }) {
          Image(c.isLitByMe ? $r('app.media.signup_collect'): $r('app.media.map_like'))
           .width(20)
          Text(c.isLitByMe ? `已点亮 (${c.lightCount})` : `点亮胶囊 (${c.lightCount})`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .height(48)
      .margin({ top: 16 })
      .type(ButtonType.Normal)
      .borderRadius(24)
      .linearGradient(c.isLitByMe ? {
        angle: 90,
        colors: [['#EC4899', 0.0], ['#F472B6', 1.0]]
      } : {
        angle: 90,
        colors: [['#3B82F6', 0.0], ['#60A5FA', 1.0]]
      })
      .opacity(1)
      .onClick(async (): Promise<void> => {
        await this.lightUp(c)
      })

      Text('匿名回复')
        .fontSize(13)
        .fontColor('#64748B')
        .width('100%')
        .margin({ top: 20, bottom: 10 })

      Scroll() {
        Column({ space: 10 }) {
          ForEach(c.replies, (r: AnonymousReplyItem) => {
            Column({ space: 6 }) {
              Text(r.text)
                .fontSize(14)
                .fontColor('#334155')
              Text(r.timeAgo)
                .fontSize(11)
                .fontColor('#94A3B8')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
          }, (r: AnonymousReplyItem) => r.id)
        }
        .width('100%')
      }
      .constraintSize({ maxHeight: 180 })

      Row({ space: 10 }) {
        TextInput({ placeholder: '留下匿名回复...', text: this.replyDraft })
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .placeholderColor('#94A3B8')
          .backgroundColor('#F1F5F9')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((v: string) => {
            this.replyDraft = v
          })

        Button() {
          Text('➤')
            .fontSize(18)
            .fontColor(Color.White)
        }
        .width(44)
        .height(44)
        .type(ButtonType.Normal)
        .borderRadius(22)
        .linearGradient({
          angle: 180,
          colors: [['#2563EB', 0.0], ['#38BDF8', 1.0]]
        })
        .onClick(async (): Promise<void> => {
          await this.sendAnonymousReply()
        })
      }
      .margin({ top: 12, bottom: 8 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 24 })
    .borderRadius({ topLeft: 22, topRight: 22 })
    .linearGradient({
      angle: 180,
      colors: [['#EFF6FF', 0.0], ['#FFFFFF', 0.55], ['#F8FAFC', 1.0]]
    })
    .shadow({
      radius: 24,
      color: '#25000000',
      offsetX: 0,
      offsetY: -4
    })
  }

  /** 可拖动悬浮情绪区：展开时自右侧滑出 Scroll，收起时仅保留小图标 */
  /** 可拖动悬浮情绪区：展开时显示面板，收起时显示按钮 */
  @Builder
  private EmotionFloatingLayer() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 展开 → 显示完整可滚动面板
      if (this.emotionPanelExpanded) {
        Column({ space: 8 }) {
          Row({ space: 6 }) {
            Image($r('app.media.map_label'))
              .width(20)
              .fillColor('#ff89bcfc')
            Text('实时情绪流')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
          }

          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.emotionStream, (ec: EmotionStreamItem) => {
                this.EmotionCard(ec)
              }, (ec: EmotionStreamItem) => `${this.campus}_${ec.location}`)
            }
            .width('100%')
          }
          .scrollBar(BarState.Auto)
          .width(220)
          .height(320)
        }
        .padding(10)
        .backgroundColor(Color.Transparent)
        .borderRadius(16)
        .borderWidth(2)
        .borderColor('#ffc0e2fe')
        .shadow({ radius:16, color:'#33000000', offsetX:0, offsetY:6 })
        .gesture(
          PanGesture({ fingers: 1, distance: 1 })
            .onActionStart((_) => {
              this.panBaseX = this.emotionFabX
              this.panBaseY = this.emotionFabY
            })
            .onActionUpdate((event) => {
              this.clampFabPosition(
                this.panBaseX + event.offsetX,
                this.panBaseY + event.offsetY
              )
            })
        )
        // 点击面板关闭
        .onClick(() => {
          this.emotionPanelExpanded = false
        })
      }
      // 收起 → 只显示悬浮按钮
      else {
        Column() {
          Image($r('app.media.map_label'))
            .width(20)
            .fillColor('#fff')
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .borderRadius(24)
        .linearGradient({ angle: 135, colors: [['#3B82F6', 0], ['#93C5FD', 1]] })
        .shadow({ radius: 12, color: '#443B82F6', offsetX: 0, offsetY: 4 })
        // 点击按钮打开
        .onClick(() => {
          this.emotionPanelExpanded = true
        })
        // 只给按钮加拖动手势（不干扰点击）
        .gesture(
          PanGesture({ fingers: 1, distance: 1 })
            .onActionStart((_) => {
              this.panBaseX = this.emotionFabX
              this.panBaseY = this.emotionFabY
            })
            .onActionUpdate((event) => {
              this.clampFabPosition(
                this.panBaseX + event.offsetX,
                this.panBaseY + event.offsetY
              )
            })
        )
      }
    }
    .position({ x: this.emotionFabX, y: this.emotionFabY })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        /** —— 顶栏 —— */
        Row() {
          Image($r('app.media.send_back'))
            .width(40)
            .height(40)
            .padding(8)
            .fillColor('#1E3A5F')
            .onClick((): void => {
              router.back()
            })

          Text('AR 寻宝地图')
            .layoutWeight(1)
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
            .textAlign(TextAlign.Center)

        }
        .width('100%')
        .padding({ left: 8, right: 12, top: 8, bottom: 4 })

        /** 校区切换 */
        Row({ space: 14 }) {
          this.CampusTab('金明校区', 'jinming')
          this.CampusTab('明伦校区', 'minglun')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 4 })

        /** 地图全宽，高度占满剩余空间 */
        Stack({ alignContent: Alignment.TopStart }) {
          Image(this.campus === 'jinming' ?$r('app.media.map_jm') : $r('app.media.map_ml'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .borderRadius(16)

          ForEach(this.capsules, (cap: MapCapsuleMarker) => {
            Stack({ alignContent: Alignment.TopStart }) {
              CapsuleMapMarker({
                haloColor: haloColorForMood(cap.moodKind),
                distanceMeters: cap.distanceMeters,
                showDistanceLabel: true,
                onMarkerClick: (): void => {
                  this.openCapsule(cap.id)
                }
              })
            }
            .width(52)
            .height(58)
            .position({
              x: `${this.convertLatLngToMapPct(cap.latitude, cap.longitude).x}%`,
              y: `${this.convertLatLngToMapPct(cap.latitude, cap.longitude).y}%`
            })
            .translate({ x: '-50%', y: '-50%' })
          }, (cap: MapCapsuleMarker) => cap.id)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 12, right: 12 })
        .clip(true)

        /** 附近胶囊 */
        Column({ space: 8 }) {
          Row() {
            Row({ space: 6 }) {
              Image($r('app.media.map_flight'))
                .width(14)
                .fillColor('#2563EB')
              Text('附近胶囊')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')
            }

            Blank()

            Text(`${this.nearbyList().length} 个可探索`)
              .fontSize(12)
              .fontColor('#64748B')
          }
          .width('100%')

          List({ space: 10 }) {
            ForEach(this.nearbyList(), (nc: MapCapsuleMarker) => {
              ListItem() {
                Row({ space: 8 }) {
                  Image($r('app.media.map_capsule'))
                    .width(25)
                  Text(`${nc.locationName} · ${nc.distanceMeters}m`)
                    .fontSize(13)
                    .fontColor('#334155')
                }
                .padding({ left: 10, right: 10, top: 10, bottom: 10 })
                .backgroundColor('#FFFFFF')
                .borderRadius(20)
                .shadow({
                  radius: 6,
                  color: '#10000000',
                  offsetX: 0,
                  offsetY: 1
                })
                .onClick((): void => {
                  this.openCapsule(nc.id)
                })
              }
            }, (nc: MapCapsuleMarker) => `near_${nc.id}`)
          }
          .listDirection(Axis.Horizontal)
          .width('100%')
          .height(52)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .padding({
          left: 10,
          right: 10,
          top: 10,
          bottom: 14
        })
        .backgroundColor('#ffc6e1ff')
        .borderRadius({ topLeft: 18, topRight: 18 })
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          [0xE8F4FF, 0.4],  // 晴空浅蓝
          [0xD6E9FF, 0.7],  // 柔雾蓝
          [0xC7E4FF, 1.0]   // 奶感浅蓝
        ]
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      /** 悬浮实时情绪流（在详情遮罩之下，避免挡住弹窗） */
      this.EmotionFloatingLayer()

      if (this.showDetailSheet) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#660F172A')
          .onClick((): void => {
            this.closeSheet()
          })

        if (this.selectedCapsuleId !== '') {
          if (this.selectedCapsule() !== undefined) {
            this.CapsuleDetailSheet(this.selectedCapsule() as MapCapsuleMarker)
          }
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
