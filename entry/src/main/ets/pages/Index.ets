import { router } from '@kit.ArkUI'

import {FloatingCardsBySine} from './components/FloatingCardsBySine'
@Entry
@Component
struct Index {
  @State scaleValue:number=1.0
  @State isSelected:boolean=true
  private openPublishPage(): void {
    router.pushUrl({
      url: 'pages/PublishCapsulePage'
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row({ space: 8 }) {
          Image($r('app.media.index_search'))
            .width(20)
            .fillColor('#ff99b8e3')
          Text('正在感知：5个胶囊已发现')
            .fontSize(14)
            .fontColor('#374151')
          Blank()
          Text('漂流站')
            .fontSize(13)
            .fontColor('#2563EB')
            .fontWeight(FontWeight.Medium)
            .onClick((): void => {
              router.pushUrl({ url: 'pages/DriftagePage' })
            })
          Text('🚩')
            .fontSize(16)
            .fontColor('#6B7280')
        }
        .width(340)
        .height(46)
        .margin({ top: 15, left: 20, right: 20 })
        .padding({ left: 14, right: 14 })
        .backgroundColor('#E6FFFFFF')
        .borderRadius(23)
        FloatingCardsBySine()
      }
      .height('100%')
      .width('100%')
      .backgroundImage($r('app.media.index_background'))
      .backgroundImageSize({width:380,height:810})
      .backdropBlur(15)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      Row() {
        Column(){
          Image($r('app.media.index_find'))
            .width(30)
            .fillColor('#fff')
            .margin({bottom:7})
            .fillColor(this.isSelected ? Color.White : '#9CA3AF')
          Text('寻宝')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .fontColor(this.isSelected ? Color.White : '#9CA3AF')
        }
        .onClick(() => {
          this.isSelected = true
        })
        Blank()
        Stack({ alignContent: Alignment.Center }) {
          // 外层透明圆环
          Circle()
            .width(80)
            .height(80)
            .fill(Color.Transparent)
            .stroke(Color.White)
            .strokeOpacity(0.3)
            .strokeWidth(7)
            .scale({ x: this.scaleValue, y: this.scaleValue })

          Button('+')
            .width(78)
            .height(78)
            .fontSize(38)
            .fontColor('#111827')
            .backgroundColor('#FFFFFF')
            .borderRadius(39)
            .onClick(() => this.openPublishPage())
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                animateTo({ duration: 90, curve: Curve.Sharp }, () => {
                  this.scaleValue = 0.94
                })
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                animateTo({ duration: 150, curve: Curve.EaseInOut }, () => {
                  this.scaleValue = 1.0
                })
              }
            })
        }
        .margin({top:-40})


        Blank()
        Column(){
          Image($r('app.media.index_mine'))
            .width(30)
            .fillColor('#fff')
            .margin({bottom:7})
            .fillColor(this.isSelected ? '#9CA3AF': Color.White )
          Text('我的')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#6B7280')
            .fontColor(this.isSelected ? '#9CA3AF': Color.White)
        }
        .onClick(()=>{this.isSelected=false
          router.pushUrl({url:'pages/MinePage'})
        })
      }
      .width('100%')
      .padding({ left: 28, right: 28, bottom: 24 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#E5ECFF')

  }
}