import { router, Router } from "@kit.ArkUI"

/**
 * 主导航底栏：与寻宝页 Index 底栏视觉一致（透明叠底、左右留白、白底圆形「+」）。
 */
export enum MainTabBarSlot {
  HOME = 0,
  MINE = 1
}
@Entry
@Component
export struct MainTabBar {
  /** 当前高亮 Tab */
  @Prop activeSlot: MainTabBarSlot = MainTabBarSlot.HOME
  /**
   * true：左侧寻宝 + 媒体图标，右侧「我的」+ 媒体图标。
   * false：左侧首页符号 +「首页」，右侧「我的」符号（样式仍与 Index 底栏一致）。
   */
  @Prop treasureHomeStyle: boolean = true
  @State private fabScale: number = 1.0

  onHomeClick: () => void = (): void => {
    router.pushUrl({url:'pages/Index'})
  }
  onPublishClick: () => void = (): void => {}
  onMineClick: () => void = (): void => {}

  private leftActive(): boolean {
    return this.activeSlot === MainTabBarSlot.HOME
  }

  private rightActive(): boolean {
    return this.activeSlot === MainTabBarSlot.MINE
  }

  /** 与 Index 一致：选中白色，未选中灰色 */
  private tabTone(active: boolean): ResourceColor {
    return active ? Color.White : '#9CA3AF'
  }

  build() {
    Row() {
      Column() {

          Image($r('app.media.index_find'))
            .width(30)
            .margin({ bottom: 7 })
            .fillColor(this.tabTone(this.leftActive()))
          Text('寻宝')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.tabTone(this.leftActive()))

      }
      .onClick((): void => this.onHomeClick())

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(80)
          .height(80)
          .fill(Color.Transparent)
          .stroke(Color.White)
          .strokeOpacity(0.3)
          .strokeWidth(7)
          .scale({ x: this.fabScale, y: this.fabScale })

        Button('+')
          .width(78)
          .height(78)
          .fontSize(38)
          .fontColor('#111827')
          .backgroundColor('#FFFFFF')
          .borderRadius(39)
          .scale({ x: this.fabScale, y: this.fabScale })
          .onClick((): void => this.onPublishClick())
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              animateTo({ duration: 90, curve: Curve.Sharp }, () => {
                this.fabScale = 0.94
              })
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              animateTo({ duration: 150, curve: Curve.EaseInOut }, () => {
                this.fabScale = 1.0
              })
            }
          })
      }
      .margin({ top: -40 })
      .onClick(()=>{
        router.pushUrl({url:'pages/PublishCapsulePage'})
      })

      Blank()

      Column() {
        if (this.treasureHomeStyle) {
          Image($r('app.media.index_mine'))
            .width(30)
            .margin({ bottom: 7 })
            .fillColor(this.tabTone(this.rightActive()))
          Text('我的')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.tabTone(this.rightActive()))
        } else {
          SymbolGlyph($r('sys.symbol.person_crop_circle_fill'))
            .fontSize(30)
            .margin({ bottom: 7 })
            .fontColor([this.tabTone(this.rightActive())])
          Text('我的')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.tabTone(this.rightActive()))
        }
      }
      .onClick((): void => this.onMineClick())
    }
    .width('100%')
    .padding({ left: 28, right: 28, bottom: 24 })
  }
}
