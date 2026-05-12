import { router } from "@kit.ArkUI"

interface FloatingItem {
  id: string
  label: string
  x: number
  baseY: number
  amplitude: number // 振幅，建议 8~20
  omega: number // 角速度，建议 0.003~0.006
  phase: number // 相位，弧度制，0~2PI
  maxDeg:number
  color: ResourceColor
  fillcolor:ResourceColor
  icon: ResourceStr
}

@Entry
@Component
export struct FloatingCardsBySine {
  @State private tick: number = 0
  private timerId: number = 0
  @State private pressedId: string = ''
  private items: FloatingItem[] = [
    {
      id: '1',
      label: '表白',
      x: 40,
      baseY: 100,
      amplitude: 14,
      omega: 0.0025,
      phase: 0,
      maxDeg:3,
      color: '#FFE6F0',
      fillcolor:'#ffe54151',
      icon: $r('app.media.index_like')
    },
    {
      id: '2',
      label: '吐槽',
      x: 100,
      baseY: 370,
      amplitude: 18,
      omega: 0.0027,
      phase: 1.2,
      maxDeg:5,
      color: '#E8FFF1',
      fillcolor:'#ff46da89',
      icon: $r('app.media.index_message')
    },
    {
      id: '3',
      label: '极客',
      x: 220,
      baseY: 260,
      amplitude: 12,
      omega: 0.0025,
      phase: 2.1,
      maxDeg:7,
      color: '#FFF4D9',
      fillcolor:'#fff9bc20',
      icon: $r('app.media.index_geek')
    }
  ]

  private cardScale(item: FloatingItem): number {
    return this.pressedId === item.id ? 0.92 : 1
  }
  aboutToAppear(): void {
    // 约 60fps
    this.timerId = setInterval(() => {
      this.tick += 16
    }, 16)
  }

  aboutToDisappear(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId)
      this.timerId = 0
    }
  }

  private currentY(item: FloatingItem): number {
    return item.baseY + item.amplitude * Math.sin(item.omega * this.tick + item.phase)
  }

  private autorotation(item: FloatingItem): number {
    return item.maxDeg * (-Math.sin(item.omega * this.tick + item.phase))
  }

  @Builder
  private buildCard(item: FloatingItem) {
    Column() {
      Image(item.icon)
        .fillColor(item.fillcolor)
        .width(36)
        .margin({ top: 10 })

      Text(item.label)
        .width(64)
        .height(20)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .borderRadius(10)
        .backgroundColor('#fff')
        .textAlign(TextAlign.Center)
        .margin({ top: 6 })
    }
    .width(90)
    .height(90)
    .borderRadius(12)
    .backgroundColor(item.color)
    .shadow({ radius: 10, color: '#22000000', offsetX: 0, offsetY: 4 })
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
    .position({ x: item.x, y: this.currentY(item) })
    .rotate({ angle:this.autorotation(item), z: 1,centerX: '50%', centerY: '50%' })
    .scale({
      x: this.cardScale(item),
      y: this.cardScale(item),
      z: 1,
      centerX: '50%',
      centerY: '50%'
    })
    .animation({
      duration: this.pressedId === item.id ? 100 : 260,
      curve: this.pressedId === item.id ? Curve.Sharp : Curve.EaseInOut
    })
    .onClick(()=>{
      router.pushUrl({url:'pages/PublishCapsulePage'})
    })
  }

  build() {
    Stack() {
      ForEach(this.items, (item: FloatingItem) => {
        this.buildCard(item)
      }, (item: FloatingItem) => item.id)
    }
    .width('100%')
    .height('100%')
  }
}



