import {CircleWave} from './CircleWave'
@Component
export struct CapsuleMapMarker {
  @Prop haloColor: string = '#2563EB'
  @Prop distanceMeters: number = 0
  @Prop showDistanceLabel: boolean = true
  onMarkerClick: () => void = (): void => {}
  @State private jumpY: number = 0
  @State private haloOpacity: number = 0.12
  /** true：处于跳起阶段（光晕较强）；false：落下（光晕较弱） */
  @State private bounceUp: boolean = false
  private cycleTimer: number = -1

  aboutToAppear(): void {
    this.cycleTimer = setInterval((): void => {
      this.bounceUp = !this.bounceUp
      animateTo({ duration: 420, curve: Curve.EaseInOut }, () => {
        if (this.bounceUp) {
          this.jumpY = -7
          this.haloOpacity = 0.88
        } else {
          this.jumpY = 0
          this.haloOpacity = 0.1
        }
      })
    }, 860) as number
  }

  aboutToDisappear(): void {
    if (this.cycleTimer >= 0) {
      clearInterval(this.cycleTimer)
      this.cycleTimer = -1
    }
  }

  build() {
    Column({ space: 1 }) {
      Stack({ alignContent: Alignment.Center }) {
        CircleWave({color:this.haloColor})


        Image($r('app.media.map_capsule'))
          .width(20)
          .height(20)
          .padding(4)
          .borderRadius(10)
          .backgroundColor('#fff')
      }
      .width(40)
      .height(40)
      .translate({ y: this.jumpY })

      if (this.showDistanceLabel) {
        Text(`${this.distanceMeters}m`)
          .fontSize(8)
          .fontColor(Color.White)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
          .backgroundColor('#CC000000')
          .borderRadius(8)
      }
    }
    .onClick((): void => {
      this.onMarkerClick()
    })
  }
}
