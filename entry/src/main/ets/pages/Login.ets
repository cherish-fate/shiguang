import { router, promptAction } from '@kit.ArkUI'
import { LoginTheme } from './models/ThemeConstants'
import { AuthState } from '../services/UserSessions'
import { ApiService } from '../services/MockApiService'

@Entry
@Component
struct LoginPage {
  @State private phone: string = ''
  @State private verifyCode: string = ''
  @State private agreed: boolean = false
  @State private busy: boolean = false
  @State private codeSeconds: number = 0
  @State private agreementDialogVisible: boolean = false
  @State private agreementContent: string = ''
  @State private agreementType: 'agreement' | 'privacy' = 'agreement'
  @State private agreementTitle: string = ''
  private tickHandle: number = -1

  aboutToDisappear(): void {
    this.clearCodeTimer()
  }

  private clearCodeTimer(): void {
    if (this.tickHandle >= 0) {
      clearInterval(this.tickHandle)
      this.tickHandle = -1
    }
  }

  private maskPhone(phone: string): string {
    const p = phone.trim()
    if (p.length !== 11) {
      return p
    }
    return `${p.substring(0, 3)}****${p.substring(7)}`
  }

  private validatePhone(): boolean {
    const p = this.phone.trim()
    if (p.length < 11) {
      promptAction.showToast({ message: '请输入 11 位手机号',textColor:Color.Red })
      return false
    }
    return true
  }

  private async onRequestCode(): Promise<void> {
    if (this.codeSeconds > 0 || this.busy) {
      return
    }
    if (!this.validatePhone()) {
      return
    }
    this.busy = true
    try {
      await ApiService.sendCode({ phone: this.phone.trim() })
      promptAction.showToast({ message: '验证码已发送' })
      this.codeSeconds = 60
      this.clearCodeTimer()
      this.tickHandle = setInterval((): void => {
        this.codeSeconds--
        if (this.codeSeconds <= 0) {
          this.clearCodeTimer()
        }
      }, 1000)
    } catch (error) {
      console.error('Failed to send code:', error)
    } finally {
      this.busy = false
    }
  }

  private onHuaweiOneClick(): void {
    promptAction.showToast({ message: '华为账号登录功能暂未开放' })
  }

  private async onLoginRegister(): Promise<void> {
    if (!this.validatePhone()) {
      return
    }
    if (this.verifyCode.trim().length < 4) {
      promptAction.showToast({ message: '请输入验证码',textColor:Color.Red })
      return
    }
    if (!this.agreed) {
      promptAction.showToast({ message: '请阅读并同意《用户协议》和《隐私政策》',textColor:Color.Red })
      return
    }
    if (this.busy) {
      return
    }
    this.busy = true
    try {
      const response = await ApiService.login({
        phone: this.phone.trim(),
        code: this.verifyCode.trim()
      })
      await AuthState.saveLoginState(
        response.token,
        response.userId,
        response.nickname,
        this.maskPhone(this.phone)
      )
      ApiService.setAuthToken(response.token)
      promptAction.showToast({ message: '登录成功' })
      router.back()
    } catch (error) {
      console.error('Failed to login:', error)
    } finally {
      this.busy = false
    }
  }

  private async openUserAgreement(): Promise<void> {
    await this.showAgreement('agreement')
  }

  private async openPrivacy(): Promise<void> {
    await this.showAgreement('privacy')
  }

  private async showAgreement(type: 'agreement' | 'privacy'): Promise<void> {
    try {
      this.agreementType = type
      this.agreementTitle = type === 'agreement' ? '用户协议' : '隐私政策'
      const response = await ApiService.getAgreement(type)
      this.agreementContent = response.content
      this.agreementDialogVisible = true
    } catch (error) {
      console.error('Failed to get agreement:', error)
      promptAction.showToast({ message: '加载协议失败' })
    }
  }

  @Builder
  private agreementDialog() {
    Column() {
      Text(this.agreementTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16, top: 8 })
      
      Scroll() {
        Text(this.agreementContent || '加载中...')
          .fontSize(14)
          .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .height(400)
      
      Button('关闭')
        .width('100%')
        .margin({ top: 16 })
        .onClick(() => {
          this.agreementDialogVisible = false
        })
    }
    .width('90%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  private logoBlock() {
    Column({ space: 12 }) {

      Image($r('app.media.logo'))
        .width(88)
        .height(88)
        .borderRadius(22)
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [
            [0xD6E9FF, 0.0],
            [0xC7E4FF, 1.0]
          ]
        })
       .shadow({ radius: 16, color: '#22000000', offsetX: 0, offsetY: 8 })
      Text('拾光印记')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(LoginTheme.TITLE)
      Text('记录校园情绪 · 留住美好时光')
        .fontSize(14)
        .fontColor(LoginTheme.SLOGAN)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 24, bottom: 28 })
  }



  @Builder
  private separatorLine() {
    Row() {
      Divider()
        .strokeWidth(1)
        .color(LoginTheme.SEPARATOR_LINE)
        .layoutWeight(1)
      Text('使用手机号登录')
        .fontSize(12)
        .fontColor(LoginTheme.PLACEHOLDER)
        .margin({ left: 12, right: 12 })
      Divider()
        .strokeWidth(0.5)
        .color(LoginTheme.SEPARATOR_LINE)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ top: 8, bottom: 20 })
    .padding({left:10,right:10})
  }

  @Builder
  private phoneField() {
    Row({ space: 10 }) {
      Image($r('app.media.login_phone'))
        .width(20)
        .margin({ left: 12 })
        .fillColor(Color.Grey)
      TextInput({ text: $$this.phone, placeholder: '输入手机号' })
        .layoutWeight(1)
        .height(52)
        .fontSize(16)
        .backgroundColor(Color.White)
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .border({ width: 0 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#fff')
    .borderRadius(26)
    .border({ width: 1, color: LoginTheme.INPUT_BORDER })
  }

  @Builder
  private codeRow() {
    Row({ space: 12 }) {
      Row({ space: 10 }) {
        Image($r('app.media.login_flight'))
          .width(20)
          .margin({ left: 12 })
          .fillColor(Color.Grey)
        TextInput({ text: $$this.verifyCode, placeholder: '验证码' })
          .layoutWeight(1)
          .height(52)
          .fontSize(16)
          .type(InputType.Number)
          .maxLength(8)
          .backgroundColor(Color.White)
          .border({ width: 0 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(26)
      .border({ width: 1, color: LoginTheme.INPUT_BORDER })

      Button(this.codeSeconds > 0 ? `${this.codeSeconds}s` : '获取验证码', { type: ButtonType.Capsule, stateEffect: true })
        .height(52)
        .padding({ left: 14, right: 14 })
        .fontSize(14)
        .fontColor(LoginTheme.BUTTON_DARK)
        .backgroundColor('#fff')
        .border({ width: 1, color: LoginTheme.INPUT_BORDER })
        .enabled(this.codeSeconds <= 0 && !this.busy)
        .constraintSize({ minWidth: 112 })
        .onClick(() => {
          this.onRequestCode()
        })
    }
    .width('100%')
  }

  @Builder
  private agreementRow() {
    Row() {
      Checkbox()
        .select(this.agreed)
        .width(20)
        .height(20)
        .margin({ right: 8 })
        .onChange((v: boolean) => {
          this.agreed = v
        })
      Row() {
        Text('我已阅读并同意 ')
          .fontSize(13)
          .fontColor(LoginTheme.SLOGAN)
        Text('《用户协议》')
          .fontSize(16)
          .fontColor(LoginTheme.LINK)
          .onClick(() => {
            this.openUserAgreement()
          })
        Text(' 和 ')
          .fontSize(13)
          .fontColor(LoginTheme.SLOGAN)
        Text('《隐私政策》')
          .fontSize(16)
          .fontColor(LoginTheme.LINK)
          .onClick(() => {
            this.openPrivacy()
          })
      }
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)

    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ top: 10 })
    .padding({left:-10})
  }

  @Builder
  private loginRegisterButton() {
    Button(this.busy ? '请稍候…' : '立即登录', { type: ButtonType.Capsule, stateEffect: true })
      .width('100%')
      .height(52)
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.Black)
      .linearGradient({
        direction: GradientDirection.Top,
        colors: [
          [0xD6E9FF, 0.0],
          [0xE8F4FF, 1.0]
        ]
      })
      .borderRadius(26)
      .margin({ top: 20 })
      .enabled(!this.busy)
      .onClick(() => {
        this.onLoginRegister()
      })
      .constraintSize({ minHeight: 48 })
      .shadow({ radius: 16, color: '#22000000', offsetX: 0, offsetY: 8 })
    Row(){
      Text('初来乍到？')  .fontSize(15)
      Text('安心注册')  .fontColor(LoginTheme.LINK)
        .onClick(()=>{
          router.pushUrl({url:'pages/SignUp'})
        })
    }
  }


  @Builder
  private footerBlock() {
    Column({ space: 6 }) {
      Text('登录即可发布胶囊、收藏内容')
        .fontSize(12)
        .fontColor(LoginTheme.FOOTER)
        .textAlign(TextAlign.Center)
      Text('支持鸿蒙分布式同步到 PC 端')
        .fontSize(12)
        .fontColor(LoginTheme.FOOTER)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .margin({ top: 12, bottom: 24 })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          this.logoBlock()
          this.separatorLine()

          Column({ space: 14 }) {
            this.phoneField()
            this.codeRow()
            this.agreementRow()
            this.loginRegisterButton()
            // this.guestEntry()
            this.footerBlock()
          }
          .width('100%')
          .constraintSize({ maxWidth: 400 })
          .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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
    .bindContentCover($$this.agreementDialogVisible, this.agreementDialog(), {
      modalTransition: ModalTransition.DEFAULT,
      onDisappear: () => {
        this.agreementDialogVisible = false
      }
    })
  }
}
