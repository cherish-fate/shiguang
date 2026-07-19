import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { ApiService, CapsuleData } from '../services/ApiService'

interface FloatingCapsule {
  id: string
  emoji: string
  baseX: number
  baseY: number
  amplitudeX: number
  amplitudeY: number
  omegaX: number
  omegaY: number
  phaseX: number
  phaseY: number
  glowColor: string
  backgroundColor: string
  moodTag: string
}

interface MoodStyle {
  color: string
  icon: string
  glowColor: string
  backgroundColor: string
}

interface Position {
  baseX: number
  baseY: number
}

const MOOD_STYLES: Record<string, MoodStyle> = {
  '焦虑': { color: '#ffeaf2fe', icon: '💙', glowColor: '#ff98bbf5', backgroundColor: '#ffd7e6fb' },
  '浪漫': { color: '#fffcecf4', icon: '🌸', glowColor: '#fff8c9e8', backgroundColor: '#fffcecf4' },
  '活力': { color: '#fffcf7e6', icon: '☀️', glowColor: '#fff5e689', backgroundColor: '#fffbf2d3' },
  '快乐': { color: '#fffcf7e6', icon: '☀️', glowColor: '#fff5e689', backgroundColor: '#fffbf2d3' },
  '极客': { color: '#fff6eefe', icon: '💡', glowColor: '#ffba7cf8', backgroundColor: '#ffe7d8f7' },
  '平静': { color: '#fff0faf7', icon: '🌿', glowColor: '#ff9bf7d6', backgroundColor: '#ffd9fbf1' },
  '孤独': { color: '#fff5f7fa', icon: '🌙', glowColor: '#ff858687', backgroundColor: '#ffcbcdd0' }
}

interface CapsuleDetail {
  id: string
  moodTag: string
  content: string
  location: string
  createdAt: string
  likes: number
  isLiked: boolean
  isFavorited: boolean
  color: string
  icon: string
  comments: CommentItem[]
}

interface CommentItem {
  id: string
  text: string
  createdAt: string
}

@CustomDialog
struct CapsuleDetailDialog {
  @State private capsuleDetails: CapsuleDetail = {
    id: '',
    moodTag: '',
    content: '',
    location: '',
    createdAt: '',
    likes: 0,
    isLiked: false,
    isFavorited: false,
    color: '#FFF8E7',
    icon: '🌙',
    comments: []
  }
  controller: CustomDialogController=new CustomDialogController({
    builder: CapsuleDetailDialog({
      detail: this.capsuleDetails,
      onLike: () => {},
      onFavorite: ()=>{},
      onAddComment: ()=> {}
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    offset: { dx: 0, dy: 0 },
    customStyle: true
  })
  detail: CapsuleDetail = {
    id: '',
    moodTag: '',
    content: '',
    location: '',
    createdAt: '',
    likes: 0,
    isLiked: false,
    isFavorited: false,
    color: '#FFF8E7',
    icon: '🌙',
    comments: []
  }
  onLike: (id: string) => void = () => {}
  onFavorite: (id: string) => void = () => {}
  onAddComment: (id: string, text: string) => void = () => {}

  @State activeTab: string = 'content'
  @State commentInput: string = ''
  @State isLiked: boolean = false
  @State likeCount: number = 0
  @State isFavorited: boolean = false
  @State comments: CommentItem[] = []

  aboutToAppear(): void {
    this.isLiked = this.detail.isLiked
    this.likeCount = this.detail.likes
    this.isFavorited = this.detail.isFavorited
    this.comments = [...this.detail.comments]
  }

  build() {
    Column() {
        Row() {
          Row({ space: 8 }) {
            Text(this.detail.icon)
              .fontSize(18)
            Text(this.detail.moodTag)
              .fontSize(14)
              .fontColor('#333333')
          }
          .padding({ left: 12, right: 16, top: 6, bottom: 6 })
          .backgroundColor(this.detail.color)
          .borderRadius(20)

          Blank()

          Image($r('app.media.pop_up_close'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.controller.close()
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20,bottom:10})

        Row({space:15}) {
          Text('胶囊内容')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.activeTab === 'content' ? '#FFFFFF' : '#666666')
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .backgroundColor(this.activeTab === 'content' ? '#4A88FF' : '#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              this.activeTab = 'content'
            })

          Text(`留言(${this.comments.length})`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.activeTab === 'comments' ? '#FFFFFF' : '#666666')
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .backgroundColor(this.activeTab === 'comments' ? '#4A88FF' : '#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              this.activeTab = 'comments'
            })
        }
        //.padding({ top:80,left: 20, right: 20 })


      Scroll() {
        Column({ space: 16 }) {
          if (this.activeTab === 'content') {
            Column() {
              Text(this.detail.content)
                .fontSize(15)
                .fontColor('#333333')
                .lineHeight(28)
                .textAlign(TextAlign.Start)
            }
            .padding(16)
            .backgroundColor('#F8FAFC')
            .borderRadius(12)

            Row({ space: 20 }) {
              Row({ space: 6 }) {
                Text('📍')
                  .fontSize(14)
                Text(this.detail.location)
                  .fontSize(13)
                  .fontColor('#666666')
              }

              Row({ space: 6 }) {
                Text('📅')
                  .fontSize(14)
                Text(this.formatDate(this.detail.createdAt))
                  .fontSize(13)
                  .fontColor('#666666')
              }
            }

            Row({ space: 16 }) {
              Button() {
                Row({ space: 8 }) {
                  Image( $r('app.media.driftage_like'))
                    .width(18)
                    .height(18)
                    .fillColor(this.isLiked ? '#FF9F43' : '#999999')
                  Text('匿名点赞')
                    .fontSize(14)
                    .fontColor(this.isLiked ? '#FF9F43' : '#666666')
                }
              }
              .width('45%')
              .height(44)
              .backgroundColor(this.isLiked ? '#fff9e5cd' : '#F5F5F5')
              .borderRadius(22)
              .onClick(() => {
                this.isLiked = !this.isLiked
                this.likeCount += this.isLiked ? 1 : -1
                this.onLike(this.detail.id)
              })

              Button() {
                Row({ space: 8 }) {
                  Image(this.isFavorited ? $r('app.media.signup_collect') : $r('app.media.signup_collect'))
                    .width(18)
                    .height(18)
                    .fillColor(this.isFavorited ? '#FF4757' : '#999999')
                  Text('收藏')
                    .fontSize(14)
                    .fontColor(this.isFavorited ? '#FF4757' : '#666666')
                }
              }
              .width('45%')
              .height(44)
              .backgroundColor(this.isFavorited ? '#fff5c6be' : '#F5F5F5')
              .borderRadius(22)
              .onClick(() => {
                this.isFavorited = !this.isFavorited
                this.onFavorite(this.detail.id)
              })
            }
          } else {
            Column({ space: 12 }) {
              ForEach(this.comments, (comment: CommentItem) => {
                Column() {
                  Text(this.formatDate(comment.createdAt))
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ top: 4 })

                  Text(comment.text)
                    .fontSize(14)
                    .fontColor('#333333')
                    .padding(12)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)


                }
              }, (comment: CommentItem) => comment.id)

              if (this.comments.length === 0) {
                Column() {
                  Text('暂无留言')
                    .fontSize(14)
                    .fontColor('#999999')
                    .padding(40)
                }
              }
            }
          }
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 100 })
      }

      if (this.activeTab === 'comments') {
        Row({ space: 12 }) {
          TextInput({ placeholder: '写下你的留言...', text: this.commentInput })
            .width(250)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .fontSize(14)
            .onChange((value: string) => {
              this.commentInput = value
            })

          Button('发送')
            .width(80)
            .height(44)
            .backgroundColor('#4A88FF')
            .fontColor('#FFFFFF')
            .fontSize(14)
            .borderRadius(22)
            .onClick(() => {
              if (this.commentInput.trim() === '') {
                promptAction.showToast({ message: '请输入留言内容' })
                return
              }
              this.onAddComment(this.detail.id, this.commentInput)
              this.comments.push({
                id: `c${Date.now()}`,
                text: this.commentInput,
                createdAt: new Date().toISOString()
              })
              this.commentInput = ''
            })
        }
        .padding({ left: 10, right: 10, bottom: 20 })
        .backgroundColor('#FFFFFF')
      }
    }
    .padding({top:30})
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr)
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}月${day}日`
  }
}

@Entry
@Component
struct DriftagePage {
  @State private tick: number = 0
  private timerId: number = 0
  @State private pressedId: string = ''
  @State private selectedCapsuleId: string = ''
  private likedSet: Set<string> = new Set()
  private favoritedSet: Set<string> = new Set()
  @State private capsuleDetail: CapsuleDetail = {
    id: '',
    moodTag: '',
    content: '',
    location: '',
    createdAt: '',
    likes: 0,
    isLiked: false,
    isFavorited: false,
    color: '#FFF8E7',
    icon: '🌙',
    comments: []
  }

  @State private capsules: FloatingCapsule[] = []

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.tick += 16
    }, 16)
    this.loadCapsules()
  }

  private async loadCapsules(): Promise<void> {
    try {
      const result = await ApiService.listCapsules({})
      const newCapsules: FloatingCapsule[] = []
      const positions: Position[] = [
        { baseX: 20, baseY: 50 },
        { baseX: 250, baseY: 90 },
        { baseX: 30, baseY: 270 },
        { baseX: 190, baseY: 230 },
        { baseX: 240, baseY: 370 },
        { baseX: 90, baseY: 410 },
        { baseX: 150, baseY: 150 },
        { baseX: 60, baseY: 350 },
        { baseX: 220, baseY: 450 },
        { baseX: 40, baseY: 180 }
      ]
      for (let i = 0; i < result.list.length && i < positions.length; i++) {
        const capsule = result.list[i]
        const moodStyle = this.getMoodStyle(capsule.mood)
        const pos = positions[i]
        newCapsules.push({
          id: String(capsule.id),
          emoji: moodStyle.icon,
          baseX: pos.baseX,
          baseY: pos.baseY,
          amplitudeX: 10 + Math.random() * 5,
          amplitudeY: 5 + Math.random() * 4,
          omegaX: 0.0015 + Math.random() * 0.0007,
          omegaY: 0.0023 + Math.random() * 0.0005,
          phaseX: Math.random() * Math.PI * 2,
          phaseY: Math.random() * Math.PI * 2,
          glowColor: moodStyle.glowColor,
          backgroundColor: moodStyle.backgroundColor,
          moodTag: capsule.mood
        })
      }
      this.capsules = newCapsules
    } catch (error) {
      console.error('Failed to load capsules:', error)
    }
  }

  aboutToDisappear(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId)
      this.timerId = 0
    }
  }

  private currentX(item: FloatingCapsule): number {
    return item.baseX + item.amplitudeX * Math.sin(item.omegaX * this.tick + item.phaseX)
  }

  private currentY(item: FloatingCapsule): number {
    return item.baseY + item.amplitudeY * Math.sin(item.omegaY * this.tick + item.phaseY)
  }

  private currentScale(item: FloatingCapsule): number {
    return this.pressedId === item.id ? 0.92 : 1
  }

  private createCommentItem(id: string, text: string, createdAt: string): CommentItem {
    const item: CommentItem = {
      id: id,
      text: text,
      createdAt: createdAt
    }
    return item
  }

  private getMoodStyle(moodTag: string): MoodStyle {
    const style: MoodStyle | undefined = MOOD_STYLES[moodTag]
    return style ?? { color: '#FFF8E7', icon: '🌙', glowColor: '#ffcccccc', backgroundColor: '#FFF8E7' }
  }

  private async openCapsuleDetail(capsuleId: string): Promise<void> {
    const id = parseInt(capsuleId)
    if (isNaN(id)) return
    try {
      const capsule = await ApiService.getCapsuleDetail(id)
      const replies = await ApiService.getReplies(id)
      const commentItems: CommentItem[] = replies.list.map(c => this.createCommentItem(String(c.id), c.content, c.createdAt))
      const moodStyle: MoodStyle = this.getMoodStyle(capsule.mood)
      this.capsuleDetail = {
        id: String(capsule.id),
        moodTag: capsule.mood,
        content: capsule.summary,
        location: capsule.location,
        createdAt: new Date(capsule.timestamp).toISOString(),
        likes: 0,
        isLiked: this.likedSet.has(String(capsule.id)),
        isFavorited: this.favoritedSet.has(String(capsule.id)),
        color: moodStyle.color,
        icon: moodStyle.icon,
        comments: commentItems
      }
      this.dialogController.open()
    } catch (error) {
      console.error('Failed to load capsule detail:', error)
    }
  }

  private handleLike(capsuleId: string): void {
    if (this.likedSet.has(capsuleId)) {
      this.likedSet.delete(capsuleId)
    } else {
      this.likedSet.add(capsuleId)
    }
  }

  private handleFavorite(capsuleId: string): void {
    if (this.favoritedSet.has(capsuleId)) {
      this.favoritedSet.delete(capsuleId)
    } else {
      this.favoritedSet.add(capsuleId)
    }
  }

  private async handleAddComment(capsuleId: string, text: string): Promise<void> {
    const id = parseInt(capsuleId)
    if (isNaN(id)) return
    await ApiService.addReply(id, text)
  }

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CapsuleDetailDialog({
      detail: this.capsuleDetail,
      onLike: (id: string) => this.handleLike(id),
      onFavorite: (id: string) => this.handleFavorite(id),
      onAddComment: (id: string, text: string) => this.handleAddComment(id, text)
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    offset: { dx: 0, dy: 0 },
    customStyle: true
  })

  @Builder
  private buildCapsule(item: FloatingCapsule) {
    Stack() {

      Row()
        .width(76)
        .height(96)
        .borderRadius(43)
        .backgroundColor(item.backgroundColor)
        .shadow({
          radius: 15,
          color: `${item.glowColor}`,
          offsetX: 0,
          offsetY: 0
        })

      Column({ space: 8 }) {

        Text(item.emoji)
          .fontSize(32)
          .margin({ top: 8 })

        Row()
          .width(10)
          .height(10)
          .backgroundColor(item.glowColor)
          .borderRadius(5)
          .opacity(0.8)
      }
      .width(80)
      .height(100)
      .borderRadius(45)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(item.backgroundColor)
      .opacity(0.7)
      .shadow({
        radius: 20,
        color: `${item.glowColor}`,
        offsetX: 0,
        offsetY: 0
      })
    }
    .position({ x: this.currentX(item), y: this.currentY(item) })
    .scale({
      x: this.currentScale(item),
      y: this.currentScale(item),
      z: 1,
      centerX: '50%',
      centerY: '50%'
    })
    .animation({
      duration: this.pressedId === item.id ? 100 : 260,
      curve: this.pressedId === item.id ? Curve.Sharp : Curve.EaseInOut
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: 90, curve: Curve.Sharp }, () => {
          this.pressedId = item.id
        })
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        if (this.pressedId === item.id) {
          animateTo({ duration: 280, curve: Curve.EaseInOut }, () => {
            this.pressedId = ''
          })
        }
      }
    })
    .onClick(() => {
      this.openCapsuleDetail(item.id)
    })
  }

  build() {
    Stack(){
    Image($r('app.media.driftage_background'))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.send_back'))
          .width(40)
          .height(40)
          .padding(8)
          .fillColor(Color.White)
          .onClick(() => router.back())
        Text('漂流站')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ left: 90 })
        Blank()
      }
      .width('100%')
      .padding({ top: 14, left: 12, right: 12 })

      Column({ space: 8 }) {
        Text('每一枚胶囊，都在等待有缘人捞起')
          .fontSize(14)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)

        Row() {
          Row({ space: 8 }) {
            Row()
              .width(8)
              .height(8)
              .backgroundColor('#4A88FF')
              .borderRadius(4)
              .animation({
                duration: 1000,
                iterations: -1,
                curve: Curve.EaseInOut,
                delay: 0
              })
              .onAppear(() => {
              })

            Text('AI正在为你匹配情绪相近的胶囊')
              .fontSize(13)
              .fontColor('#FFFFFF')
          }
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8
          })
          .backgroundColor('rgba(61, 128, 255, 0.30)')
          .borderRadius(20)
        }
      }

      Stack() {
        ForEach(this.capsules, (item: FloatingCapsule) => {
          this.buildCapsule(item)
        }, (item: FloatingCapsule) => item.id)
      }
      .flexGrow(1)
      .width('100%')

      Text('点击胶囊即可捞取')
        .fontSize(13)
        .fontColor('rgba(14, 0, 0, 0.87)')
        .padding({ bottom: 40 })
        .textAlign(TextAlign.Center)

    }
    .width('100%')
    .height('100%')
    // .linearGradient({
    //   direction: GradientDirection.Bottom,
    //   colors: [
    //     [0xE8F4FF, 0.4],
    //     [0xD6E9FF, 0.7],
    //     [0xC7E4FF, 1.0]
    //   ]
    // })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

}