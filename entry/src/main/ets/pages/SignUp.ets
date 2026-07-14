import { router, promptAction } from '@kit.ArkUI'
import { LoginTheme } from './models/ThemeConstants'
import { AuthState } from '../services/UserSessions'
import { ApiService } from '../services/ApiService'
//import { picker } from '@kit.ArkUI'
import { Permissions } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { picker } from '@kit.CoreFileKit'

@Entry
@Component
struct RegisterPage {
  @State private nickname: string = ''
  @State private phone: string = ''
  @State private verifyCode: string = ''
  @State private password: string = ''
  @State private passwordVisible: boolean = false
  @State private agreed: boolean = false
  @State private busy: boolean = false
  @State private codeSeconds: number = 0
  @State private gradeText: string = ''
  @State private collegeText: string = ''
  @State private gradeIndex: number = 0
  @State private collegeIndex: number = 0
  @State private sheetVisible: boolean = false
  @State private pickerKind: 'grade' | 'college' = 'grade'
  @State private avatarUri: string = ''
  @State private agreementDialogVisible: boolean = false
  @State private agreementContent: string = ''
  @State private agreementType: 'agreement' | 'privacy' = 'agreement'
  @State private agreementTitle: string = ''

  private tickHandle: number = -1
  private readonly gradeOptions: string[] = ['2025级', '2024级', '2023级', '2022级', '已毕业']
  private readonly collegeOptions: string[] = ['计算机学院', '电子信息学院', '经济管理学院', '人文学院', '其他']

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

  private validateForm(): boolean {
    if (this.nickname.trim().length < 2) {
      promptAction.showToast({ message: '请输入至少 2 个字的昵称',textColor:Color.Red })
      return false
    }
    if (!this.gradeText) {
      promptAction.showToast({ message: '请选择年级',textColor:Color.Red })
      return false
    }
    if (!this.collegeText) {
      promptAction.showToast({ message: '请选择学院',textColor:Color.Red })
      return false
    }
    const p = this.phone.trim()
    if (p.length !== 11) {
      promptAction.showToast({ message: '请输入 11 位手机号',textColor:Color.Red })
      return false
    }
    if (this.verifyCode.trim().length < 4) {
      promptAction.showToast({ message: '请输入验证码',textColor:Color.Red })
      return false
    }
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码不少于 6 位',textColor:Color.Red })
      return false
    }
    if (!this.agreed) {
      promptAction.showToast({ message: '请阅读并同意《用户协议》和《隐私政策》',textColor:Color.Red })
      return false
    }
    return true
  }

  private async onRequestCode(): Promise<void> {
    if (this.codeSeconds > 0 || this.busy) {
      return
    }
    const p = this.phone.trim()
    if (p.length !== 11) {
      promptAction.showToast({ message: '请先填写 11 位手机号',textColor:Color.Red })
      return
    }
    this.busy = true
    try {
      await ApiService.sendCode({ phone: p, type: 'register' })
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

  private async onRegister(): Promise<void> {
    if (!this.validateForm() || this.busy) {
      return
    }
    this.busy = true
    try {
      const response = await ApiService.register({
        avatar: this.avatarUri,
        nickname: this.nickname.trim(),
        phone: this.phone.trim(),
        code: this.verifyCode.trim(),
        password: this.password,
        grade: this.gradeText,
        college: this.collegeText,
        agreeProtocol: this.agreed
      })
      await AuthState.saveLoginState(
        response.token,
        String(response.userInfo.userId),
        response.userInfo.nickname,
        this.maskPhone(this.phone)
      )
      ApiService.setAuthToken(response.token)
      promptAction.showToast({ message: '注册成功' })
      router.back()
    } catch (error) {
      console.error('Failed to register:', error)
    } finally {
      this.busy = false
    }
  }

  private openGradePicker(): void {
    this.pickerKind = 'grade'
    this.sheetVisible = true
  }

  private openCollegePicker(): void {
    this.pickerKind = 'college'
    this.sheetVisible = true
  }

  private confirmPicker(): void {
    if (this.pickerKind === 'grade') {
      this.gradeText = this.gradeOptions[this.gradeIndex]
    } else {
      this.collegeText = this.collegeOptions[this.collegeIndex]
    }
    this.sheetVisible = false
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

  private async onAvatarTap(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      })
      if (result.photoUris && result.photoUris.length > 0) {
        this.avatarUri = result.photoUris[0]
      }
    } catch (error) {
      const err = error as BusinessError
      if (err.code === 201) {
        promptAction.showToast({ message: '请授予相册权限' })
      }
      console.error('Failed to pick photo:', error)
    }
  }

  private goLogin(): void {
    router.pushUrl({url:'pages/Login'})
  }

  @Builder
  private headerBrand() { //图标
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(98)
          .height(98)
          .borderRadius(49)
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [
              [0xD6E9FF, 0.0],
              [0xC7E4FF, 1.0]
            ]
          })

        Image($r('app.media.logo'))
          .width(84)
          .height(84)
          .borderRadius(42)
      }
      .width(92)
      .height(92)

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
    .margin({bottom: 20 })
  }

  @Builder
  private avatarBlock() {  //上传头像
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.avatarUri) {
          Image(this.avatarUri)
            .width(88)
            .height(88)
            .borderRadius(44)
            .objectFit(ImageFit.Cover)
        } else {
          Column()
            .width(88)
            .height(88)
            .borderRadius(44)
            .backgroundColor('#fff3f4f6')
          Image($r('app.media.signup_camera'))
            .width(30)
            .fillColor('#ff9da4b0')
        }
      }
      .width(88)
      .height(88)
      .onClick(() => {
        this.onAvatarTap()
      })
      .constraintSize({ minHeight: 48, minWidth: 48 })

      Text('点击上传头像')
        .fontSize(13)
        .fontColor(LoginTheme.PLACEHOLDER)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 20 })
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
  private fieldRow(icon: Resource, plholder: string) { //昵称 电话
    Row() {
      Image(icon)
        .width(22)
        .margin({ left: 10 })
      TextInput({ text:this.nickname, placeholder: plholder })
        .layoutWeight(1)
        .height(52)
        .fontSize(16)
        .maxLength(16)
        .placeholderColor(LoginTheme.PLACEHOLDER)
        .backgroundColor(LoginTheme.INPUT_BG)
        .border({ width: 0 })
        .padding({ right: 16 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .backgroundColor(LoginTheme.INPUT_BG)
    .borderRadius(16)
    .border({ width: 1, color: LoginTheme.INPUT_BORDER })

  }

  @Builder
  private nicknameField() {
    this.fieldRow($r('app.media.signup_name'),'请输入昵称')
  }

  //学院年级
  @Builder
  private selectRow(icon: Resource, placeholder: string, which: 'grade' | 'college', onTap: () => void){
    Row({ space: 15 }) {
      Image(icon)
        .width(22)
        .margin({ left: 10 })
      Text((which === 'grade' ? this.gradeText : this.collegeText) || placeholder)
        .layoutWeight(1)
        .fontSize(16)
        .fontColor((which === 'grade' ? this.gradeText : this.collegeText) ? LoginTheme.TITLE : LoginTheme.PLACEHOLDER)
        .textAlign(TextAlign.Start)
      Blank()
      Image('app.media.signup_down')
        .width(18)
        .margin({ right: 14 })
    }
    .width('100%')
    .height(52)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(LoginTheme.INPUT_BG)
    .borderRadius(16)
    .border({ width: 1, color: LoginTheme.INPUT_BORDER })
    .constraintSize({ minHeight: 48 })
    .onClick(onTap)
  }

  @Builder
  private phoneField() {
    Row() {
      Image($r('app.media.signup_phone'))
        .width(22)
        .margin({ left: 10 })
      TextInput({ text: $$this.phone, placeholder: '请输入手机号' })
        .layoutWeight(1)
        .height(52)
        .fontSize(16)
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .placeholderColor(LoginTheme.PLACEHOLDER)
        .backgroundColor(LoginTheme.INPUT_BG)
        .border({ width: 0 })
        .padding({ right: 16 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .backgroundColor(LoginTheme.INPUT_BG)
    .borderRadius(16)
    .border({ width: 1, color: LoginTheme.INPUT_BORDER })
  }

  //验证码
  @Builder
  private codeRow() {
    Row({ space: 12 }) {
      Row() {
        Image($r('app.media.signup_security'))
          .width(22)
          .margin({ left: 10 })
        TextInput({ text: $$this.verifyCode, placeholder: '验证码' })
          .layoutWeight(1)
          .height(52)
          .fontSize(16)
          .placeholderColor(LoginTheme.PLACEHOLDER)
          .type(InputType.Number)
          .maxLength(8)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding({ right: 8 })
          .accessibilityText('验证码输入框')
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(LoginTheme.INPUT_BG)
      .borderRadius(16)
      .border({ width: 1, color: LoginTheme.INPUT_BORDER })

      Button({ type: ButtonType.Normal }) {
        Text(this.codeSeconds > 0 ? `${this.codeSeconds}s` : '获取验证码')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
      }
      .height(52)
      .padding({ left: 14, right: 14 })
      .border({ width: 1, color: LoginTheme.INPUT_BORDER })
      .borderRadius(26)
      .backgroundColor(LoginTheme.INPUT_BG)
      .enabled(this.codeSeconds <= 0 && !this.busy)
      .constraintSize({ minWidth: 112, minHeight: 48 })
      .accessibilityText('获取验证码')
      .onClick(() => {
        this.onRequestCode()
      })
    }
    .width('100%')
  }

   //登录密码
  @Builder
  private passwordField() {
    Column({ space: 6 }) {
      Row() {
        Image($r('app.media.signup_password'))
          .width(22)
          .margin({ left: 10 })
        TextInput({ text: $$this.password, placeholder: '设置登录密码' })
          .layoutWeight(1)
          .height(52)
          .fontSize(16)
          .placeholderColor(LoginTheme.PLACEHOLDER)
          .type(this.passwordVisible ? InputType.Normal : InputType.Password)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .accessibilityText('密码输入框')

        Image(this.passwordVisible ? $r('app.media.signup_eye') : $r('sys.symbol.eye'))
          .width(22)
          .margin({ right: 4 })
          .onClick(() => {
            this.passwordVisible = !this.passwordVisible
          })
          .accessibilityText(this.passwordVisible ? '隐藏密码' : '显示密码')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .backgroundColor(LoginTheme.INPUT_BG)
      .borderRadius(16)
      .border({ width: 1, color: LoginTheme.INPUT_BORDER })
      .constraintSize({ minHeight: 52 })

      Text('密码不少于6位')
        .fontSize(10)
        .fontColor(LoginTheme.PLACEHOLDER)
        .margin({ left: 4 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

   //用户协议和隐私政策
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
      Flex({wrap:FlexWrap.Wrap}) {
        Text('我已阅读并同意')
          .fontSize(13)
          .fontColor(LoginTheme.SLOGAN)
        Text('《用户协议》')
          .fontSize(16)
          .fontColor(LoginTheme.LINK)
          .onClick(() => {
            this.openUserAgreement()
          })
        Text('和')
          .fontSize(13)
          .fontColor(LoginTheme.SLOGAN)
        Text('《隐私政策》')
          .fontSize(16)
          .fontColor(LoginTheme.LINK)
          .onClick(() => {
            this.openPrivacy()
          })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: 10 })
    .padding({left:-30})
  }

   //立即注册
  @Builder
  private submitButton() {
    Button(this.busy ? '提交中…' : '立即注册', { type: ButtonType.Capsule, stateEffect: true })
      .width('100%')
      .height(52)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor(LoginTheme.BUTTON_DARK)
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
      .constraintSize({ minHeight: 48 })
      .accessibilityText('立即注册')
      .onClick(() => {
        this.onRegister()
      })
  }

  //提示
  @Builder
  private loginLink() {
    Row({ space: 0 }) {
      Text('已有账号？')
        .fontSize(15)
        .fontColor(LoginTheme.SLOGAN)
      Text('溜去登录')
        .fontSize(15)
        .fontColor(LoginTheme.LINK)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.goLogin()
        })
    }
    .margin({ top: 16, bottom: 8 })
    .padding({ top: 8, bottom: 8 })
    .constraintSize({ minHeight: 48 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private footerBlock() {
    Column({ space: 6 }) {
      Text('登录即可发布贴文、收藏内容')
        .fontSize(12)
        .fontColor(LoginTheme.FOOTER)
        .textAlign(TextAlign.Center)
      Text('支持鸿蒙分布式同步到 PC 端')
        .fontSize(12)
        .fontColor(LoginTheme.FOOTER)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .margin({ top: 15, bottom: 24 })
  }

  //选择弹窗
  @Builder
  private pickerSheetContent() {
    Column({ space: 16 }) {
      Text(this.pickerKind === 'grade' ? '选择年级' : '选择学院')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(LoginTheme.TITLE)
        .width('100%')
        .textAlign(TextAlign.Center)

      if (this.pickerKind === 'grade') {
        TextPicker({ range: this.gradeOptions, selected: this.gradeIndex })
          .defaultPickerItemHeight(44)
          .canLoop(false)
          .onChange((_: string | string[], index: number | number[]) => {
            const idx = Array.isArray(index) ? (index[0] as number) : (index as number)
            this.gradeIndex = idx
          })
          .width('100%')
          .height(200)
      } else {
        TextPicker({ range: this.collegeOptions, selected: this.collegeIndex })
          .defaultPickerItemHeight(44)
          .canLoop(false)
          .onChange((_: string | string[], index: number | number[]) => {
            const idx = Array.isArray(index) ? (index[0] as number) : (index as number)
            this.collegeIndex = idx
          })
          .width('100%')
          .height(200)
      }

      Button('确定', { type: ButtonType.Capsule })
        .width('100%')
        .height(48)
        .fontColor(Color.White)
        .onClick(() => {
          this.confirmPicker()
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 24 })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          Row() {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(44)
                .height(44)
                .borderRadius(22)
                .backgroundColor('#33FFFFFF')
              Image($r('app.media.send_back'))
                .width(30)
                .height(30)
                .onClick(()=>{
                  router.back()
                })

            }
            .width(44)
            .height(44)
            .onClick(() => {
              router.back()
            })
            .accessibilityText('返回')
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ left: 8, top: 8 })
          .constraintSize({ minHeight: 48 })

          Column() {
            this.headerBrand()

            Column({ space: 14 }) {
              this.avatarBlock()
              this.nicknameField()
              this.selectRow($r('app.media.signup_grade'), '请选择年级',  'grade', (): void => {
                 this.openGradePicker()
              })
              this.selectRow($r('app.media.signup_sdept'), '请选择学院',  'college', (): void => {
                this.openCollegePicker()
              })
              this.phoneField()
              this.codeRow()
              this.passwordField()
              this.agreementRow()
              this.submitButton()
              this.loginLink()
            }
            .width('100%')
            .padding({
              top: 28,
              bottom: 28,
              left: 20,
              right: 20
            })
            .borderRadius(32)
            .backgroundColor(Color.White)
            .shadow({
              radius: 24,
              color: '#22000000',
              offsetX: 0,
              offsetY: 12
            })

            this.footerBlock()
          }
          .width('100%')
          .constraintSize({ maxWidth: 400 })
          .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
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
    .bindSheet($$this.sheetVisible, this.pickerSheetContent(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: true,
      showClose: true,
      preferType: SheetType.BOTTOM
    })
    .bindContentCover($$this.agreementDialogVisible, this.agreementDialog(), {
      modalTransition: ModalTransition.DEFAULT,
      onDisappear: () => {
        this.agreementDialogVisible = false
      }
    })
  }
}
