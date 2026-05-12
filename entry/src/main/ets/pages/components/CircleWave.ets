@Entry
@Component
 export struct CircleWave {
  @State circleScale: number = 0.2
  @State circleAlpha: number = 0.6
  @State color:string='#ffc5e0fe'
  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .size({ width: 100, height: 100 })
        .fill(Color.Transparent)      // 内部透明（关键）
        .stroke(this.color)           // 蓝色边框（光环）
        .strokeWidth(8)               // 光环粗细（可调节）
        .scale({ x: this.circleScale, y: this.circleScale })
        .opacity(this.circleAlpha)
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      animateTo({
        curve:Curve.EaseOut,
        duration: 800,
        iterations: -1
      }, () => {
        this.circleScale = 0.5
        this.circleAlpha = 0
      })
    })
  }
}