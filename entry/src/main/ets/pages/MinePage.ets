import { router, promptAction } from '@kit.ArkUI'
import { AuthState } from '../services/UserSessions'
import { ApiService, UserProfile, PublishedCapsulesResponse, FavoriteCapsulesResponse, EmotionDistributionResponse, EmotionDistributionItem, WeeklyReportResponse, WeekRange, MoodTrend, PublishedCapsuleItem, FavoriteCapsuleItem } from '../services/ApiService'
import { LoginTheme } from './models/ThemeConstants'
import { MainTabBar, MainTabBarSlot } from './components/MainTabBar'

/** 个人页二级 Tab：发布 / 收藏 / 情绪 / 足迹 */
enum MineSubTab {
  PUBLISH = 0,
  FAVORITES = 1,
  MOOD = 2,
  FOOTPRINTS = 3
}

interface MoodTagInfo {
  label: string
  emoji: Resource
  bg: ResourceColor
}

const moodTagMap: Record<string, MoodTagInfo> = {
  'anxiety': { label: '焦虑', emoji: $r('app.media.mine_anxiety'), bg: '#F3E8FF' },
  'romance': { label: '浪漫', emoji: $r('app.media.mine_romance'), bg: '#FCE7F3' },
  'vitality': { label: '活力', emoji: $r('app.media.mine_happy'), bg: '#FEF9C3' },
  'geek': { label: '极客', emoji: $r('app.media.mine_calm'), bg: '#DBEAFE' },
  'calm': { label: '平静', emoji: $r('app.media.mine_calm'), bg: '#DBEAFE' },
  'lone': { label: '孤独', emoji: $r('app.media.mine_alone'), bg: '#F3F4F6' },
  'happy': { label: '快乐', emoji: $r('app.media.mine_happy'), bg: '#FEF9C3' }
}

const moodBarColors: Record<string, ResourceColor> = {
  '平静': '#3B82F6',
  '快乐': '#fff5d161',
  '焦虑': '#ffbf83f5',
  '浪漫': '#fff789bf',
  '孤独': '#9CA3AF',
  '活力': '#FBBF24',
  '极客': '#8B5CF6'
}

@Entry
@Component
struct MinePage {
  @State private subTab: MineSubTab = MineSubTab.PUBLISH
  @State private publishGridMode: boolean = true
  @State private notifyEnabled: boolean = true
  
  @State private userProfile: UserProfile = { userId: 0, phone: '', nickname: '', avatar: '' }
  @State private capsuleCount: number = 0
  @State private favoriteCount: number = 0
  @State private locationCount: number = 0
  @State private publishedCapsules: PublishedCapsulesResponse | null = null
  @State private favoriteCapsules: FavoriteCapsulesResponse | null = null
  @State private emotionDistribution: EmotionDistributionItem[] = []
  @State private weeklyReport: WeeklyReportResponse = {
    weekRange: { startDate: '', endDate: '' },
    summary: '',
    trend: { risingMoods: [], fallingMoods: [] },
    suggestions: []
  }
  @State private topMoodTags: string[] = []
  @State private isLoading: boolean = true

  aboutToAppear(): void {
    this.loadUserData()
  }

  private async loadUserData(): Promise<void> {
    this.isLoading = true
    try {
      const results = await Promise.all([
        ApiService.getUserProfile(),
        ApiService.getPublishedCapsules(),
        ApiService.getFavoriteCapsules(),
        ApiService.getEmotionDistribution(),
        ApiService.getWeeklyReport()
      ])

      this.userProfile = results[0] as UserProfile
      this.publishedCapsules = results[1] as PublishedCapsulesResponse
      this.favoriteCapsules = results[2] as FavoriteCapsulesResponse
      const distResp = results[3] as EmotionDistributionResponse
      this.emotionDistribution = distResp.distribution
      this.capsuleCount = distResp.totalCapsules
      this.favoriteCount = (results[2] as FavoriteCapsulesResponse).pagination.total
      this.locationCount = 0
      this.weeklyReport = results[4] as WeeklyReportResponse

      this.topMoodTags = distResp.topThreeTags
    } catch (error) {
      console.error('Failed to load user data:', error)
      this.loadDefaultData()
    } finally {
      this.isLoading = false
    }
  }

  

  private loadDefaultData(): void {
    this.userProfile = {
      userId: 0,
      nickname: AuthState.nickname || '用户',
      phone: '',
      avatar: ''
    } as UserProfile
    this.capsuleCount = 4
    this.favoriteCount = 4
    this.locationCount = 8
    this.emotionDistribution = [
      { mood: '平静', count: 12, percentage: 35 } as EmotionDistributionItem,
      { mood: '快乐', count: 8, percentage: 24 } as EmotionDistributionItem,
      { mood: '焦虑', count: 6, percentage: 18 } as EmotionDistributionItem,
      { mood: '浪漫', count: 4, percentage: 12 } as EmotionDistributionItem,
      { mood: '孤独', count: 3, percentage: 9 } as EmotionDistributionItem
    ]
    this.topMoodTags = ['平静', '快乐', '浪漫']
    this.weeklyReport = {
      weekRange: { startDate: '', endDate: '' } as WeekRange,
      summary: '本周你的情绪整体偏平静，焦虑指数较上周下降；建议在忙碌日程中保留小块放松时间，有助于维持正向循环。',
      trend: { risingMoods: [] as string[], fallingMoods: [] as string[] } as MoodTrend,
      suggestions: [] as string[]
    } as WeeklyReportResponse
  }

  private getMoodInfo(moodTag: string): MoodTagInfo {
    return moodTagMap[moodTag.toLowerCase()] || { label: moodTag, emoji: $r('app.media.mine_calm'), bg: '#DBEAFE' }
  }

  private getMoodEmoji(label: string): Resource {
    const moodInfo = moodTagMap[label.toLowerCase()]
    return moodInfo ? moodInfo.emoji : $r('app.media.mine_calm')
  }

  private getMoodBg(label: string): ResourceColor {
    const moodInfo = moodTagMap[label.toLowerCase()]
    return moodInfo ? moodInfo.bg : '#DBEAFE'
  }

  private formatTimeAgo(dateStr: string): string {
    const now = new Date()
    const date = new Date(dateStr)
    const diffMs = now.getTime() - date.getTime()
    const diffMins = Math.floor(diffMs / 60000)
    const diffHours = Math.floor(diffMins / 60)
    const diffDays = Math.floor(diffHours / 24)
    
    if (diffMins < 1) return '刚刚'
    if (diffMins < 60) return `${diffMins}分钟前`
    if (diffHours < 24) return `${diffHours}小时前`
    if (diffDays < 30) return `${diffDays}天前`
    return dateStr.substring(0, 10)
  }

  private openLogin(): void {
    router.pushUrl({ url: 'pages/Login' }).catch((): void => {
      promptAction.showToast({ message: '请配置页面路由 pages/Login' })
    })
  }

  private goHome(): void {
    router.back()
  }

  private openPublish(): void {
    router.pushUrl({ url: 'pages/PublishCapsulePage' }).catch((): void => {
      promptAction.showToast({ message: '请配置页面路由 pages/PublishCapsulePage' })
    })
  }


  @Builder
  private ProfileCard() {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Column() {
            if (this.userProfile.avatar) {
              Image(this.userProfile.avatar)
                .width(40)
            } else {
              Image($r('app.media.mine_avatar'))
                .width(40)
            }
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#ffcce4fe')
          .justifyContent(FlexAlign.Center)

          Column() {
            Image($r('app.media.mine_camera'))
              .width(20)
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor('#ffcaefff')
          .justifyContent(FlexAlign.Center)
          .margin({ right: -2, bottom: -2 })
        }
        .width(72)
        .height(72)

        Column({ space: 8 }) {
          Row({ space: 6 }) {
            Text(this.userProfile.nickname || '用户')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')
            Image($r('app.media.signup_edit'))
              .width(14)
              .fillColor('#8a8a8a')
          }
          Text('拾光印记用户')
            .fontSize(13)
            .fontColor('#6B7280')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.topMoodTags, (tag: string) => {
              Row() {
                Image(this.getMoodEmoji(tag))
                  .width(18)
                Text(tag)
                  .fontSize(11)
              }
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.getMoodBg(tag))
              .borderRadius(10)
              .margin({ right: 6, bottom: 4 })
            }, (tag: string) => tag)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row() {
        this.StatColumn($r('app.media.signup_position'), `${this.capsuleCount}`, '胶囊')
        this.StatColumn($r('app.media.signup_collect'), `${this.favoriteCount}`, '收藏')
        this.StatColumn($r('app.media.signup_achi'), `${this.locationCount}`, '成就')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 8 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(24)
    .shadow({ radius: 16, color: '#33000000', offsetX: 0, offsetY: 6 })
  }

  @Builder
  private StatColumn(icon: Resource,  num: string, label: string) {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(40)
          .height(40)
          .fill('#F8FAFC')
        Image(icon)
          .width(20)
      }
      Text(num)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
    }
    .layoutWeight(1)
  }

  @Builder
  private SubTabBar() {
    Row() {
      this.SubTabItem('发布', MineSubTab.PUBLISH)
      this.SubTabItem('收藏', MineSubTab.FAVORITES)
      this.SubTabItem('情绪', MineSubTab.MOOD)
    }
    .width('100%')
    .padding(6)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .justifyContent(FlexAlign.SpaceAround)
    .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  private SubTabItem(title: string, tab: MineSubTab) {
    Text(title)
      .fontSize(this.subTab === tab ?19:16)
      .fontWeight(this.subTab === tab ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.subTab === tab ? '#ff1f2131' : '#6B7280')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .borderRadius(14)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
      .onClick((): void => {
        this.subTab = tab
      })
  }

  @Builder
  private PublishedCapsuleCard(item: PublishedCapsuleItem) {
    Column({ space: 8 }) {
      Row() {
        Row() {
          Image(this.getMoodEmoji(item.mood))
            .width(18)
          Text(item.mood)
            .fontSize(11)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.getMoodBg(item.mood))
        .borderRadius(10)
        .margin({ right: 6, bottom: 4 })
        Blank()
        SymbolGlyph(item.isPrivate ? $r('sys.symbol.lock_fill') : $r('app.media.default_avater'))
          .fontSize(16)
          .fontColor(['#9CA3AF'])
      }
      .width('100%')

      Text(item.content)
        .fontSize(13)
        .fontColor('#374151')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)

      Row({ space: 4 }) {
        Image($r('app.media.signup_position'))
          .width(12)
          .fillColor('#ffa4a8a9')
        Text(item.location)
          .fontSize(11)
          .fontColor('#9CA3AF')
        Text('·')
          .fontSize(11)
          .fontColor('#D1D5DB')
        Text(item.timeAgo)
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .width('100%')

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Image($r('app.media.signup_collect')).width(12)
          Text(`${item.visibilityLabel}`).fontSize(12).fontColor('#6B7280')
        }
      }

      Row() {
        Blank()
        Text('编辑')
          .fontSize(13)
          .fontColor('#2563EB')
          .margin({ right: 12 })
          .onClick((): void => {
            promptAction.showToast({ message: '编辑（演示）' })
          })
        Text('删除')
          .fontSize(13)
          .fontColor('#EF4444')
          .onClick((): void => {
            promptAction.showToast({ message: '删除（演示）' })
          })
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 8, color: '#12000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  private CapsuleCard(item: PublishedCapsuleItem) {
    this.PublishedCapsuleCard(item)
  }

  private defaultWeeklyReport(): WeeklyReportResponse {
    const weekRange: WeekRange = { startDate: '', endDate: '' }
    const trend: MoodTrend = { risingMoods: [] as string[], fallingMoods: [] as string[] }
    const suggestions: string[] = []
    const report: WeeklyReportResponse = { weekRange: weekRange, summary: '', trend: trend, suggestions: suggestions }
    return report
  }

  private getMoodLabel(moodTag: string): string {
    const moodInfo = moodTagMap[moodTag.toLowerCase()]
    return moodInfo ? moodInfo.label : moodTag
  }

  private getMoodBarColor(label: string): ResourceColor {
    return moodBarColors[label] || '#3B82F6'
  }

  @Builder
  private PublishSection() {
    Column({ space: 14 }) {
      Row() {
        Text('我发布的胶囊')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ff89898c')
        Blank()
        Row({ space: 8 }) {
          Image($r('app.media.signup_grid'))
            .width(20)
            .fillColor(this.publishGridMode ? '#ff7795f8' : '#9CA3AF')
            .onClick((): void => {
              this.publishGridMode = true
            })
          Image($r('app.media.signup_show'))
            .width(23)
            .fillColor(!this.publishGridMode ? '#ff7795f8' : '#9CA3AF')
            .onClick((): void => {
              this.publishGridMode = false
            })
        }
      }
      .width('100%')

      if (!this.publishedCapsules || this.publishedCapsules.items.length === 0) {
        Column({ space: 12 }) {
          Image($r('app.media.mine_avatar'))
            .width(60)
            .opacity(0.5)
          Text('还没有发布胶囊')
            .fontSize(14)
            .fontColor('#9CA3AF')
          Button('去发布')
            .width(120)
            .height(40)
            .backgroundColor('#ff7795f8')
            .fontColor(Color.White)
            .borderRadius(20)
            .onClick(() => this.openPublish())
        }
        .width('100%')
        .padding(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
      } else if (this.publishGridMode) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.publishedCapsules!.items, (item: PublishedCapsuleItem) => {
            Column() {
              this.PublishedCapsuleCard(item)
            }
            .margin({ bottom: 10 })
            .width('48%')
          }, (item: PublishedCapsuleItem) => `${item.capsuleId}`)
        }
        .width('100%')
      } else {
        Column({ space: 12 }) {
          ForEach(this.publishedCapsules!.items, (item: PublishedCapsuleItem) => {
            this.PublishedCapsuleCard(item)
          }, (item: PublishedCapsuleItem) => `${item.capsuleId}`)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private FavoritesSection() {
    Column({ space: 14 }) {
      Row() {
        Text('我收藏的胶囊')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ff89898c')
      }
      .width('100%')

      if (!this.favoriteCapsules || this.favoriteCapsules.items.length === 0) {
        Column({ space: 12 }) {
          Image($r('app.media.signup_collect'))
            .width(60)
            .opacity(0.5)
          Text('还没有收藏胶囊')
            .fontSize(14)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .padding(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
      } else {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.favoriteCapsules!.items, (item: FavoriteCapsuleItem) => {
            Column() {
              this.FavoriteCapsuleCard(item)
            }
            .width('48%')
          }, (item: FavoriteCapsuleItem) => `${item.capsuleId}`)
        }
        .width('100%')

        Row({ space: 10 }) {
          SymbolGlyph($r('app.media.default_avater'))
            .fontSize(20)
            .fontColor(['#A78BFA'])
          Text('收藏的胶囊支持跨端同步到 PC')
            .fontSize(13)
            .fontColor('#6B7280')
            .layoutWeight(1)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#fffdfbff')
        .borderRadius(16)
      }
    }
    .width('100%')
  }

  @Builder
  private MoodSection() {
    Column({ space: 14 }) {
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('✨')
            .fontSize(16)
          Text('AI 情绪周报')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ff141a28')
        }
        Text(this.weeklyReport.summary || '本周你的情绪整体偏平静，焦虑指数较上周下降；建议在忙碌日程中保留小块放松时间，有助于维持正向循环。')
          .fontSize(13)
          .fontColor('#ff141a28')
          .lineHeight(22)

        if (this.weeklyReport.suggestions && this.weeklyReport.suggestions.length > 0) {
          Column({ space: 8 }) {
            Text('💡 建议')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#ff141a28')
            ForEach(this.weeklyReport.suggestions, (suggestion: string, idx: number) => {
              Text(`${idx + 1}. ${suggestion}`)
                .fontSize(12)
                .fontColor('#6B7280')
            }, (suggestion: string, idx: number) => `suggestion_${idx}`)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .borderRadius(20)
      .backgroundColor('#fff')

      Column({ space: 14 }) {
        Text('近 7 天情绪分布')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')

        ForEach(this.emotionDistribution, (row: EmotionDistributionItem, idx: number) => {
          Row({ space: 10 }) {
            Text(row.mood)
              .fontSize(13)
              .fontColor('#374151')
              .width(40)
            Progress({
              value: row.percentage,
              total: 100,
              type: ProgressType.Linear
            })
              .layoutWeight(1)
              .height(8)
              .color(this.getMoodBarColor(row.mood))
              .backgroundColor('#F3F4F6')
            Text(`${row.count} 次 · ${row.percentage}%`)
              .fontSize(11)
              .fontColor('#6B7280')
              .width(72)
              .textAlign(TextAlign.End)
          }
          .width('100%')
        }, (row: EmotionDistributionItem, idx: number) => `mood_${idx}_${row.mood}`)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })

      Column({ space: 10 }) {
        Text('高频情绪标签')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.emotionDistribution.slice(0, 5), (item: EmotionDistributionItem, i: number) => {
            Text(`${item.mood} (${item.count})`)
              .fontSize(12)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.getMoodBg(item.mood))
              .borderRadius(12)
              .margin({ right: 8, bottom: 8 })
              .fontColor('#374151')
          }, (item: EmotionDistributionItem, i: number) => `tag_${i}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(20)
      .alignItems(HorizontalAlign.Start)
      .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
    }
    .width('100%')
  }

  @Builder
  private FootprintsSection() {
    Column({ space: 14 }) {
      Column() {
        Column({ space: 8 }) {
          Image($r('app.media.signup_feet'))
            .width(25)
          Text('足迹地图')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1E3A8A')
            .width('100%')
            .textAlign(TextAlign.Center)
          Text('展示你发布过的胶囊点位')
            .fontSize(13)
            .fontColor('#64748B')
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 20, bottom: 16, left: 16, right: 16 })
        .linearGradient({
          angle: 180,
          colors: [['#DBEAFE', 0.0], ['#ffcbe5fe', 1.0]]
        })

        Row() {
          this.FootStatCell('23', '打卡点')
          this.FootStatCell('8', '区域')
          this.FootStatCell('1.2km', '总距离')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      }
      .width('100%')
      .clip(true)
      .borderRadius(20)
      .shadow({ radius: 10, color: '#14000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
  }

  @Builder
  private FavoriteCapsuleCard(item: FavoriteCapsuleItem) {
    Column({ space: 8 }) {
      Row() {
        Row() {
          Image(this.getMoodEmoji(item.mood))
            .width(18)
          Text(item.mood)
            .fontSize(11)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.getMoodBg(item.mood))
        .borderRadius(10)
        .margin({ right: 6, bottom: 4 })
        Blank()
        SymbolGlyph(item.isPrivate ? $r('sys.symbol.lock_fill') : $r('app.media.default_avater'))
          .fontSize(16)
          .fontColor(['#9CA3AF'])
      }
      .width('100%')

      Text(item.title)
        .fontSize(13)
        .fontColor('#374151')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 4 }) {
        Image($r('app.media.signup_position'))
          .width(12)
          .fillColor('#ffa4a8a9')
        Text(item.location)
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 8, color: '#12000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  private FootStatCell(value: string, label: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
    }
    .layoutWeight(1)
  }

  @Builder
  private DistributedCard() {
    Column({ space: 12 }) {
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.link'))
          .fontSize(14)
          .fontColor(['#64748B'])
        Text('鸿蒙分布式')
          .fontSize(14)
          .fontColor('#64748B')
      }
      .width('100%')

      Row({ space: 12 }) {
        Column() {
          Image($r('app.media.signup_compu'))
            .width(22)
            .fillColor('#94A3B8')
        }
        .width(48)
        .height(48)
        .backgroundColor('#F1F5F9')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        Column({ space: 4 }) {
          Text('PC 端连接')
            .fontSize(15)
            .fontColor('#111827')
          Text('未连接')
            .fontSize(12)
            .fontColor('#9CA3AF')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.signup_nowife'))
          .width(22)
          .fillColor('#8a8a8a')
      }
      .width('100%')
      .padding(14)
      .borderRadius(14)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 16, color: '#33000000', offsetX: 0, offsetY: 6 })
  }

  @Builder
  private SettingsCard() {
    Column() {
      this.SettingToggleRow()
      this.SettingNavRow($r('sys.symbol.lock_fill'), '隐私设置')
      this.SettingNavRow($r('sys.symbol.gearshape_fill'), '账号设置')
      this.SettingNavRow($r('sys.symbol.questionmark_circle_fill'), '帮助与反馈')
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius:16, color:'#33000000', offsetX:0, offsetY:6 })
  }


  @Builder
  private SettingToggleRow() {
    Row() {
      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.bell_fill'))
          .fontSize(20)
          .fontColor(['#8a8a8a'])
        Text('消息通知')
          .fontSize(15)
          .fontColor('#111827')
      }
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.notifyEnabled })
        .selectedColor('#ffcce6ff')
        .onChange((isOn: boolean) => {
          this.notifyEnabled = isOn
        })
    }
    .width('100%')
    .padding(14)

  }

  @Builder
  private SettingNavRow(icon: Resource, title: string) {
    Row() {
      Row({ space: 12 }) {
        SymbolGlyph(icon)
          .fontSize(20)
          .fontColor(['#8a8a8a'])
        Text(title)
          .fontSize(15)
          .fontColor('#111827')
      }
      Blank()
      Image($r('app.media.signup_right'))
        .width(14)

    }
    .width('100%')
    .padding(14)
    .onClick((): void => {
      router.pushUrl({url:'pages/AccountSettingsPage'})
    })
  }

  @Builder
  private LogoutBlock() {
    Row({ space: 8 }) {
      Text('退出登录')
        .fontSize(16)
        .fontColor('#EF4444')
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 16, color: '#33000000', offsetX: 0, offsetY: 6 })
    .onClick((): void => {
      AuthState.clearLoginState()
      this.userProfile = { userId: 0, nickname: '', phone: '', avatar: '' } as UserProfile
      this.capsuleCount = 0
      this.favoriteCount = 0
      this.locationCount = 0
      this.emotionDistribution = []
      this.publishedCapsules = null
      this.favoriteCapsules = null
      router.pushUrl({ url: 'pages/Login' })
    })
  }

  @Builder
  private FooterVersion() {
    Column({ space: 6 }) {
      Text('拾光印记 v1.0.0')
        .fontSize(12)
        .fontColor('#9CA3AF')
      Text('基于鸿蒙分布式技术')
        .fontSize(11)
        .fontColor('#CBD5E1')
    }
    .width('100%')
    .padding({ top: 8, bottom: 24 })
  }

  @Builder
  private ScrollMainBody() {
    Column({ space: 14 }) {
      Row({space:100}) {
        Image($r('app.media.send_back'))
          .width(30)
          .height(30)
          .onClick((): void => this.goHome())
        Text('我的')
          .fontColor(LoginTheme.BUTTON_DARK)
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
      }
      .width('100%')
      .padding({ top: 8 })


      this.ProfileCard()
      this.SubTabBar()

      if (this.subTab === MineSubTab.PUBLISH) {
        this.PublishSection()
      } else if (this.subTab === MineSubTab.FAVORITES) {
        this.FavoritesSection()
      } else if (this.subTab === MineSubTab.MOOD) {
        this.MoodSection()
      } else {
        this.FootprintsSection()
      }

      this.DistributedCard()
      this.SettingsCard()
      this.LogoutBlock()
      this.FooterVersion()
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    Column() {
      Scroll() {
        this.ScrollMainBody()
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      MainTabBar({
        activeSlot: MainTabBarSlot.MINE,
        treasureHomeStyle: false,
        onHomeClick: (): void => {
          this.goHome()
        },
        onPublishClick: (): void => {
          this.openPublish()
        },
        onMineClick: (): void => {}
      })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        [0xE8F4FF, 0.4],
        [0xD6E9FF, 0.7],
        [0xC7E4FF, 1.0]
      ]
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
