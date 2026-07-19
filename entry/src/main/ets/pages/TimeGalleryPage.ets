import { router } from '@kit.ArkUI'
import { ApiService, UserCapsule } from '../services/ApiService'

interface TimeGroup {
  month: string
  items: UserCapsule[]
}

interface MoodTagInfo {
  label: string
  bg: string
  fontColor: string
  icon: string
}

const moodTagMap: Record<string, MoodTagInfo> = {
  'anxiety': { label: '焦虑蓝', bg: '#FFEAF2FE', fontColor: '#2563EB', icon: '💙' },
  'romance': { label: '浪漫粉', bg: '#FFFCE7F3', fontColor: '#DB2777', icon: '🌸' },
  'vitality': { label: '活力黄', bg: '#FFFEF3C7', fontColor: '#D97706', icon: '☀️' },
  'geek': { label: '极客紫', bg: '#FFF3E8FF', fontColor: '#7C3AED', icon: '💡' },
  'calm': { label: '平静青', bg: '#FFF0FDF4', fontColor: '#0D9488', icon: '🌿' },
  'lone': { label: '孤独灰', bg: '#FFF3F4F6', fontColor: '#475569', icon: '🌙' },
  'happy': { label: '快乐', bg: '#FFFEF9C3', fontColor: '#CA8A04', icon: '😊' }
}

const labelToKeyMap: Record<string, string> = {
  '焦虑蓝': 'anxiety',
  '浪漫粉': 'romance',
  '活力黄': 'vitality',
  '极客紫': 'geek',
  '平静青': 'calm',
  '孤独灰': 'lone',
  '快乐': 'happy'
}

const chineseMoodToKeyMap: Record<string, string> = {
  '焦虑': 'anxiety',
  '浪漫': 'romance',
  '活力': 'vitality',
  '极客': 'geek',
  '平静': 'calm',
  '孤独': 'lone',
  '快乐': 'happy'
}

@CustomDialog
struct TimeCapsuleDetailDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: TimeCapsuleDetailDialog({
      capsule: null
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true
  })
  capsule: UserCapsule | null = null

  private getMoodInfo(moodTag: string): MoodTagInfo {
    const cleanTag = moodTag.replace(/^#\s*/, '').trim()
    const keyFromLabel = labelToKeyMap[cleanTag]
    if (keyFromLabel && moodTagMap[keyFromLabel]) {
      return moodTagMap[keyFromLabel]
    }
    const keyFromChinese = chineseMoodToKeyMap[cleanTag]
    if (keyFromChinese && moodTagMap[keyFromChinese]) {
      return moodTagMap[keyFromChinese]
    }
    return moodTagMap[moodTag.toLowerCase()] || { label: cleanTag || moodTag, bg: '#FFEAF2FE', fontColor: '#2563EB', icon: '💙' }
  }

  build() {
    Column() {
      if (this.capsule !== null) {
        Column({ space: 0 }) {
          Stack() {
            Column()
              .width(120)
              .height(120)
              .backgroundColor(this.getMoodInfo(this.capsule.moodTag).bg)
              .opacity(0.5)
              .borderRadius(60)
              .position({ x: -60, y: 60 })
              .scale({ x: 1.5, y: 1.5 })

            Column()
              .width(80)
              .height(80)
              .backgroundColor(this.getMoodInfo(this.capsule.moodTag).bg)
              .opacity(0.4)
              .borderRadius(40)
              .position({ x: 150, y: 80 })

            Column() {
              Row() {
                Row({ space: 5 }) {
                  Text(this.getMoodInfo(this.capsule.moodTag).icon)
                    .fontSize(16)
                  Text(this.getMoodInfo(this.capsule.moodTag).label)
                    .fontSize(14)
                    .fontColor(this.getMoodInfo(this.capsule.moodTag).fontColor)
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(Color.White)
                .borderRadius(20)
                .shadow({ radius: 4, color: '#20000000', offsetX: 0, offsetY: 1 })

                Blank()

                Image($r('app.media.pop_up_close'))
                  .width(26)
                  .height(26)
                  .onClick((): void => {
                    this.controller.close()
                  })
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 20 })

              Column({ space: 16 }) {
                Text(this.capsule.content)
                  .fontSize(16)
                  .fontColor('#1F2937')
                  .lineHeight(28)
                  .width('100%')
                  .textAlign(TextAlign.Start)

                Row({ space: 8 }) {
                  Column() {
                    Text('📍')
                      .fontSize(14)
                    Text(this.capsule.location)
                      .fontSize(13)
                      .fontColor('#6B7280')
                  }
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor('#F3F4F6')
                  .borderRadius(12)

                  Column() {
                    Text('📅')
                      .fontSize(14)
                    Text(this.capsule.createdAt)
                      .fontSize(13)
                      .fontColor('#6B7280')
                  }
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor('#F3F4F6')
                  .borderRadius(12)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)

                if (this.capsule.likes !== undefined && this.capsule.likes > 0) {
                  Row({ space: 6 }) {
                    Text('💖')
                      .fontSize(16)
                    Text(`${this.capsule.likes} 人觉得温暖`)
                      .fontSize(13)
                      .fontColor('#9CA3AF')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                }
              }
              .width('100%')
              .padding({ left: 24, right: 24, top: 12, bottom: 24 })
            }
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 24, topRight: 24 })
          .shadow({ radius: 24, color: '#30000000', offsetX: 0, offsetY: -4 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .justifyContent(FlexAlign.End)
    .onClick((): void => {
      this.controller.close()
    })
  }
}

@Component
struct TimelineNode {
  @State private haloScale: number = 1
  @State private haloOpacity: number = 0.6
  private timer: number = -1

  aboutToAppear(): void {
    this.timer = setInterval((): void => {
      this.haloScale = this.haloScale === 1 ? 2.2 : 1
      this.haloOpacity = this.haloOpacity === 0.6 ? 0 : 0.6
    }, 1500)
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  build() {
    Stack() {
      Column()
        .width(14)
        .height(14)
        .backgroundColor('#3B82F6')
        .borderRadius(7)
        .opacity(this.haloOpacity)
        .scale({ x: this.haloScale, y: this.haloScale })
        .animation({ duration: 1500, curve: Curve.EaseInOut })

      Column()
        .width(12)
        .height(12)
        .backgroundColor('#3B82F6')
        .borderRadius(6)
        .border({ width: 2, color: Color.White })
        .shadow({ radius: 6, color: '#803B82F6', offsetX: 0, offsetY: 0 })
    }
    .width(14)
    .height(14)
    .alignContent(Alignment.Center)
  }
}

@Entry
@Component
struct TimeGalleryPage {
  @State private selectedTab: string = '全部'
  @State private allGroups: TimeGroup[] = []
  @State private displayedGroups: TimeGroup[] = []
  @State private isLoading: boolean = true
  @State private isEditMode: boolean = false
  @State private selectedIds: Set<string> = new Set()
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: TimeCapsuleDetailDialog({
      capsule: null
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true
  })

  aboutToAppear(): void {
    this.loadData()
  }

  private async loadData(): Promise<void> {
    this.isLoading = true
    try {
      const result = await ApiService.getUserCapsules({})
      this.allGroups = this.groupByMonth(result.list)
      this.displayedGroups = this.allGroups
    } catch (error) {
      console.error('Failed to load time gallery:', JSON.stringify(error))
      this.allGroups = []
      this.displayedGroups = []
    } finally {
      this.isLoading = false
    }
  }

  private selectTab(tab: string): void {
    this.selectedTab = tab
    if (tab === '全部') {
      this.displayedGroups = this.allGroups
    } else {
      this.displayedGroups = this.allGroups.filter(g => g.month === tab)
    }
  }

  private groupByMonth(capsules: UserCapsule[]): TimeGroup[] {
    const map: Record<string, UserCapsule[]> = {}
    for (const c of capsules) {
      const month = this.extractMonth(c.createdAt)
      if (!map[month]) {
        map[month] = []
      }
      map[month].push(c)
    }
    const result: TimeGroup[] = []
    const keys = Object.keys(map)
    for (const k of keys) {
      result.push({ month: k, items: map[k] })
    }
    return result
  }

  private extractMonth(dateStr: string): string {
    if (!dateStr) return '其他'
    const parts = dateStr.split('-')
    if (parts.length >= 2) {
      return `${parts[0]}年${parseInt(parts[1])}月`
    }
    return '其他'
  }

  private getMoodInfo(moodTag: string): MoodTagInfo {
    const cleanTag = moodTag.replace(/^#\s*/, '').trim()
    const keyFromLabel = labelToKeyMap[cleanTag]
    if (keyFromLabel && moodTagMap[keyFromLabel]) {
      return moodTagMap[keyFromLabel]
    }
    const keyFromChinese = chineseMoodToKeyMap[cleanTag]
    if (keyFromChinese && moodTagMap[keyFromChinese]) {
      return moodTagMap[keyFromChinese]
    }
    return moodTagMap[moodTag.toLowerCase()] || { label: cleanTag || moodTag, bg: '#FFEAF2FE', fontColor: '#2563EB', icon: '💙' }
  }

  private hasImage(item: UserCapsule): boolean {
    return item.images != null && item.images.length > 0
  }

  private getCoverImage(item: UserCapsule): string {
    if (this.hasImage(item)) {
      return item.images[0]
    }
    return ''
  }

  private goBack(): void {
    router.back()
  }

  private openDetail(item: UserCapsule): void {
    this.dialogController.close()
    this.dialogController = new CustomDialogController({
      builder: TimeCapsuleDetailDialog({
        capsule: item
      }),
      alignment: DialogAlignment.Bottom,
      autoCancel: true,
      customStyle: true
    })
    this.dialogController.open()
  }

  private closeDetail(): void {
    this.dialogController.close()
  }

  private toggleSelect(id: string): void {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
    } else {
      this.selectedIds.add(id)
    }
  }

  private exitEditMode(): void {
    this.isEditMode = false
    this.selectedIds.clear()
  }

  private generateNotebook(): void {
    const selectedCapsules: UserCapsule[] = []
    for (const group of this.displayedGroups) {
      for (const item of group.items) {
        if (this.selectedIds.has(item.id)) {
          selectedCapsules.push(item)
        }
      }
    }
    if (selectedCapsules.length === 0) {
      return
    }
    const params: Record<string, string> = {}
    params.capsuleIds = JSON.stringify(Array.from(this.selectedIds))
    router.pushUrl({ url: 'pages/NotebookGeneratePage', params: params })
    this.exitEditMode()
  }

  @Builder
  private MoodTagChip(moodTag: string) {
    Row({ space: 5 }) {
      Text(this.getMoodInfo(moodTag).icon)
        .fontSize(13)
      Text(this.getMoodInfo(moodTag).label)
        .fontSize(12)
        .fontColor(this.getMoodInfo(moodTag).fontColor)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor(this.getMoodInfo(moodTag).bg)
    .borderRadius(14)
  }

  @Builder
  private CapsuleCard(item: UserCapsule) {
    Stack() {
      Column({ space: 10 }) {
        this.MoodTagChip(item.moodTag)

        Text(item.content)
          .fontSize(13)
          .fontColor('#1F2937')
          .lineHeight(20)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Divider()
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(10)
          Text(item.location)
            .fontSize(10)
            .fontColor('#9CA3AF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text('·')
            .fontSize(10)
            .fontColor('#D1D5DB')
          Text(item.createdAt.substring(5, 10))
            .fontSize(10)
            .fontColor('#9CA3AF')
        }
        .width('100%')
      }
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius(14)
      .alignItems(HorizontalAlign.Start)
      .shadow({ radius: 6, color: '#0C000000', offsetX: 0, offsetY: 2 })
      .border({ width: 2, color: this.isEditMode && this.selectedIds.has(item.id) ? '#3B82F6' : Color.Transparent })
      .onClick((): void => {
        if (this.isEditMode) {
          this.toggleSelect(item.id)
        } else {
          this.openDetail(item)
        }
      })
      .gesture(
        LongPressGesture()
          .onAction((): void => {
            if (!this.isEditMode) {
              this.isEditMode = true
              this.selectedIds.add(item.id)
            }
          })
      )

      if (this.isEditMode) {
        Row() {
          if (this.selectedIds.has(item.id)) {
            Stack() {
              Column()
                .width(22)
                .height(22)
                .backgroundColor('#3B82F6')
                .borderRadius(11)
                .shadow({ radius: 4, color: '#803B82F6', offsetX: 0, offsetY: 0 })
              Image($r('app.media.dui'))
                .width(14)
            }
            .alignContent(Alignment.Center)
          } else {
            Column()
              .width(22)
              .height(22)
              .backgroundColor(Color.White)
              .borderRadius(11)
              .border({ width: 2, color: '#9CA3AF' })
          }
        }
        .position({ x: '80%', y: 6 })
      }
    }
    .width('100%')
    .borderRadius(14)
    .clip(true)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Image($r('app.media.send_back'))
            .width(36)
            .height(36)
            .padding(8)
            .onClick((): void => this.goBack())
          Text('时光长廊')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          if (this.isEditMode) {
            Text('取消')
              .fontSize(16)
              .fontColor('#ffff5353')
              .fontWeight(FontWeight.Medium)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .onClick((): void => this.exitEditMode())
          } else {
            Blank()
              .width(36)
          }
        }
        .width('100%')
        .padding({ top: 8, left: 8, right: 8, bottom: 4 })

        Column() {
          Text('6 枚胶囊 · 长按多选生成手账')
            .fontSize(13)
            .fontColor('#6B7280')
        }
        .width('100%')
        .padding({ bottom: 14 })
        .alignItems(HorizontalAlign.Center)

        Row({ space: 10 }) {
          Text('全部')
            .fontSize(14)
            .fontColor(this.selectedTab === '全部' ? Color.White : '#1F2937')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 18, right: 18, top: 8, bottom: 8 })
            .backgroundColor(this.selectedTab === '全部' ? '#ff4b80f5' : Color.White)
            .borderRadius(20)
            .onClick((): void => this.selectTab('全部'))
          ForEach(this.allGroups, (group: TimeGroup) => {
            Text(group.month)
              .fontSize(14)
              .fontColor(this.selectedTab === group.month ? Color.White : '#1F2937')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 18, right: 18, top: 8, bottom: 8 })
              .backgroundColor(this.selectedTab === group.month ? '#3B82F6' : Color.White)
              .borderRadius(20)
              .borderWidth(1)
              .borderColor('#E5E7EB')
              .onClick((): void => this.selectTab(group.month))
          }, (group: TimeGroup) => group.month)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(36)
              .height(36)
              .color('#3B82F6')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.displayedGroups.length === 0) {
          Column({ space: 12 }) {
            Text('🕰️')
              .fontSize(48)
            Text('还没有时光胶囊')
              .fontSize(15)
              .fontColor('#9CA3AF')
            Text('发布你的第一枚胶囊，开启时光长廊')
              .fontSize(13)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 0 }) {
              ForEach(this.displayedGroups, (group: TimeGroup, groupIndex: number) => {
                this.MonthSection(group, groupIndex)
              }, (group: TimeGroup) => group.month)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 100 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')

      if (this.isEditMode) {
        Column() {
          Text(`AI生成手账（已选${this.selectedIds.size}枚）`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width('90%')
        .padding({ top: 14, bottom: 14 })
        .backgroundColor(this.selectedIds.size > 0 ? '#3B82F6' : '#9CA3AF')
        .borderRadius(24)
        .shadow({ radius: 12, color: '#30000000', offsetX: 0, offsetY: 4 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => {
          if (this.selectedIds.size > 0) {
            this.generateNotebook()
          }
        })
        .position({ x: '5%', y: '90%' })
      }
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

  @Builder
  private MonthSection(group: TimeGroup, groupIndex: number) {
    Row() {
      Column() {
        TimelineNode()
        if (groupIndex < this.displayedGroups.length - 1) {
          Column()
            .width(2)
            .layoutWeight(1)
            .backgroundColor('#3B82F6')
            .opacity(0.3)
        }
      }
      .width(14)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 4 })

      Column({ space: 12 }) {
        Text(group.month)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2563EB')
          .margin({ bottom: 4, left: 4 })

        GridRow({ columns: 2, gutter: { x: 10, y: 12 } }) {
          ForEach(group.items, (item: UserCapsule) => {
            GridCol() {
              this.CapsuleCard(item)
            }
          }, (item: UserCapsule) => item.id)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .padding({top:10})
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
