import { router } from '@kit.ArkUI'
import { ApiService, AiNotebookResponse, AiNotebookSection } from '../services/ApiService'

interface NotebookParams {
  capsuleIds: string
}

@Entry
@Component
struct NotebookGeneratePage {
  @State private isLoading: boolean = true
  @State private errorMessage: string = ''
  @State private notebook: AiNotebookResponse | null = null
  @State private capsuleIds: string[] = []
  @State private dotIndex: number = 0
  private dotTimer: number = -1

  aboutToAppear(): void {
    this.parseParams()
    this.generate()
  }

  aboutToDisappear(): void {
    if (this.dotTimer !== -1) {
      clearInterval(this.dotTimer)
      this.dotTimer = -1
    }
  }

  private parseParams(): void {
    const raw: Object = router.getParams() as Object
    if (!raw) {
      return
    }
    const params: NotebookParams = raw as NotebookParams
    if (!params.capsuleIds) {
      return
    }
    try {
      const parsed: Object = JSON.parse(params.capsuleIds)
      const arr: string[] = parsed as string[]
      if (arr && arr.length > 0) {
        this.capsuleIds = arr
      }
    } catch (error) {
      console.error('Failed to parse capsule ids:', JSON.stringify(error))
    }
  }

  private startDotAnimation(): void {
    if (this.dotTimer !== -1) {
      clearInterval(this.dotTimer)
    }
    this.dotIndex = 0
    this.dotTimer = setInterval((): void => {
      this.dotIndex = (this.dotIndex + 1) % 3
    }, 500)
  }

  private stopDotAnimation(): void {
    if (this.dotTimer !== -1) {
      clearInterval(this.dotTimer)
      this.dotTimer = -1
    }
  }

  private async generate(): Promise<void> {
    if (this.capsuleIds.length === 0) {
      this.errorMessage = '未选择胶囊，请返回重试'
      this.isLoading = false
      return
    }
    this.isLoading = true
    this.errorMessage = ''
    this.startDotAnimation()
    try {
      this.notebook = await ApiService.generateNotebook(this.capsuleIds)
    } catch (error) {
      console.error('Failed to generate notebook:', JSON.stringify(error))
      this.errorMessage = error instanceof Error ? error.message : '生成失败，请重试'
    } finally {
      this.stopDotAnimation()
      this.isLoading = false
    }
  }

  private goBack(): void {
    router.back()
  }

  private getLoadingText(): string {
    let suffix: string = ''
    for (let i = 0; i <= this.dotIndex; i++) {
      suffix += '.'
    }
    return `AI 正在为你整理手账${suffix}`
  }

  @Builder
  private Header() {
    Row() {
      Image($r('app.media.send_back'))
        .width(36)
        .height(36)
        .padding(8)
        .onClick((): void => this.goBack())
      Text('AI 手账')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Blank()
        .width(36)
    }
    .width('100%')
    .padding({ top: 8, left: 8, right: 8, bottom: 4 })
  }

  @Builder
  private LoadingView() {
    Column({ space: 24 }) {
      Stack() {
        Column()
          .width(96)
          .height(96)
          .borderRadius(48)
          .backgroundColor('#FFEFF6FF')
          .opacity(0.6)
          .scale({ x: 1.2, y: 1.2 })

        Column()
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#3B82F6')
          .opacity(0.15)
          .scale({ x: 1.1, y: 1.1 })

        Text('✨')
          .fontSize(40)
      }
      .width(120)
      .height(120)
      .alignContent(Alignment.Center)

      Text(this.getLoadingText())
        .fontSize(15)
        .fontColor('#475569')
        .fontWeight(FontWeight.Medium)

      Text(`已选 ${this.capsuleIds.length} 枚胶囊，正在编织属于你的拾光叙事`)
        .fontSize(12)
        .fontColor('#9CA3AF')

      LoadingProgress()
        .width(36)
        .height(36)
        .color('#3B82F6')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private ErrorView() {
    Column({ space: 16 }) {
      Image($r('app.media.NoteBookGeneratePage_failure'))
        .width(100)
      Text('生成失败')
        .fontSize(16)
        .fontColor('#1F2937')
        .fontWeight(FontWeight.Medium)
      Text(this.errorMessage)
        .fontSize(13)
        .fontColor('#9CA3AF')
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })
      Row({ space: 12 }) {
        Text('返回重选')
          .fontSize(14)
          .fontColor('#475569')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .backgroundColor('#FFF1F5F9')
          .borderRadius(20)
          .onClick((): void => this.goBack())
        Text('重新生成')
          .fontSize(14)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .backgroundColor('#3B82F6')
          .borderRadius(20)
          .onClick((): void => {
            this.generate()
          })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private TagChip(text: string, color: string, bg: string) {
    Text(text)
      .fontSize(12)
      .fontColor(color)
      .fontWeight(FontWeight.Medium)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(bg)
      .borderRadius(14)
  }

  private getSectionIcon(index: number): string {
    const icons: string[] = ['⏰', '📍', '🎨', '🌙']
    return index >= 0 && index < icons.length ? icons[index] : '✨'
  }

  private getDecorIcon(index: number): string {
    const decors: string[] = ['☀️', '⛅', '🌈', '⭐']
    return index >= 0 && index < decors.length ? decors[index] : '✨'
  }

  private getTapeAngle(index: number): number {
    const angles: number[] = [-5, 4, -3, 6]
    return index >= 0 && index < angles.length ? angles[index] : 0
  }

  private getTapeX(index: number): string {
    const positions: string[] = ['18%', '58%', '22%', '62%']
    return index >= 0 && index < positions.length ? positions[index] : '40%'
  }

  @Builder
  private SectionCard(section: AiNotebookSection, accent: string, index: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 纸张主体
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text(section.title)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Blank()
          Text(this.getDecorIcon(index))
            .fontSize(18)
            .opacity(0.6)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // 虚线分隔
        Row()
          .width('100%')
          .height(0)
          .border({ width: 1, color: '#E5D9B8', style: BorderStyle.Dashed })

        Text(section.content)
          .fontSize(14)
          .fontColor('#374151')
          .lineHeight(24)
          .width('100%')
          .textAlign(TextAlign.Start)

        // 页码装饰
        Row() {
          Text(this.getPageLabel(index))
            .fontSize(11)
            .fontColor('#B8A98A')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ top: 20, bottom: 14, left: 16, right: 16 })
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [['#FFFCF7', 0.0], ['#FFF6E6', 1.0]]
      })
      .borderRadius(4)
      .border({ width: 1, color: '#F0E4C8' })
      .shadow({ radius: 12, color: '#1A000000', offsetX: 0, offsetY: 4 })

      // 顶部胶带
      Column()
        .width(72)
        .height(18)
        .backgroundColor(accent)
        .opacity(0.55)
        .rotate({ angle: this.getTapeAngle(index) })
        .position({ x: this.getTapeX(index), y: -8 })

      // 右下角小装饰（情绪色圆点）
      Column()
        .width(8)
        .height(8)
        .borderRadius(4)
        .backgroundColor(accent)
        .opacity(0.4)
        .position({ x: '92%', y: '88%' })
    }
    .width('100%')
  }

  private getPageLabel(index: number): string {
    const total: number = 4
    const page: number = index + 1
    return `- ${page} / ${total} -`
  }

  @Builder
  private NotebookContent() {
    Scroll() {
      Column({ space: 16 }) {
        // 封面卡
        Column({ space: 12 }) {
          Row({ space: 10 }) {
            Text(this.notebook!.moodIcon)
              .fontSize(36)
            Column({ space: 4 }) {
              Text(this.notebook!.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.notebook!.moodColor)
              Text(this.notebook!.date)
                .fontSize(12)
                .fontColor('#6B7280')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Text(this.notebook!.intro)
            .fontSize(14)
            .fontColor('#374151')
            .lineHeight(24)
            .width('100%')
            .textAlign(TextAlign.Start)

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.notebook!.tags, (tag: string) => {
              this.TagChip(tag, this.notebook!.moodColor, this.notebook!.moodBg)
            }, (tag: string) => tag)
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.notebook!.moodBg)
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        // 分区内容
        ForEach(this.notebook!.sections, (section: AiNotebookSection, index: number) => {
          this.SectionCard(section, this.notebook!.moodColor, index)
        }, (section: AiNotebookSection) => section.title)

        Text(this.notebook!.closing)
          .fontSize(13)
          .fontColor('#9CA3AF')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 8, bottom: 8 })

        // 操作按钮
        Row({ space: 14 }) {
          Text('重新生成')
            .fontSize(14)
            .fontColor('#475569')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 26, right: 26, top: 12, bottom: 12 })
            .backgroundColor(Color.White)
            .borderRadius(28)
            .border({ width: 1, color: '#E5E7EB' })
            .shadow({ radius: 8, color: '#0A000000', offsetX: 0, offsetY: 2 })
            .onClick((): void => {
              this.generate()
            })

          Text('完成')
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 36, right: 36, top: 12, bottom: 12 })
            .backgroundColor(this.notebook!.moodColor)
            .borderRadius(28)
            .shadow({ radius: 12, color: '#30' + this.notebook!.moodColor.replace('#', ''), offsetX: 0, offsetY: 4 })
            .onClick((): void => this.goBack())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 8, bottom: 24 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 40 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  build() {
    Stack() {
      Column() {
        this.Header()
        if (this.isLoading) {
          this.LoadingView()
        } else if (this.notebook !== null) {
          this.NotebookContent()
        } else {
          this.ErrorView()
        }
      }
      .width('100%')
      .height('100%')
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
