import { router, promptAction } from '@kit.ArkUI'
import { ApiService, UserProfile, UpdateProfileRequest, UpdatePasswordRequest } from '../services/MockApiService'
import { picker } from '@kit.CoreFileKit';
import { showInputDialog } from '../components/InputDialog'

interface SettingsItemParams {
  leadingIcon: Resource;
  title: string;
  value?: string;
  showArrow: boolean;
  isDanger?: boolean;
  onClick: () => void;
}

@Entry
@Component
struct AccountSettingsPage {
  @State avatarUrl: string = 'app.media.default_avatar'
  @State nickname: string = ''
  @State phone: string = ''
  @State grade: string = ''
  @State college: string = ''
  @State loading: boolean = false

  aboutToAppear(): void {
    this.loadUserProfile()
  }

  private async loadUserProfile(): Promise<void> {
    this.loading = true
    try {
      const profile: UserProfile = await ApiService.getUserProfile()
      this.nickname = profile.nickname
      this.phone = this.maskPhone(profile.phone)
      this.grade = profile.grade
      this.college = profile.college
      this.avatarUrl = profile.avatar || 'app.media.default_avatar'
    } catch (error) {
      console.error('Failed to load user profile:', error)
      promptAction.showToast({ message: '加载用户信息失败' })
    } finally {
      this.loading = false
    }
  }

  private maskPhone(phone: string): string {
    if (phone.length === 11) {
      return phone.substring(0, 3) + '****' + phone.substring(7)
    }
    return phone
  }

  private async selectAvatar(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      })
      if (result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0]
        try {
          const response = await ApiService.uploadFile(uri)
          const payload: UpdateProfileRequest = { avatar: response.url }
          const profile: UserProfile = await ApiService.updateUserProfile(payload)
          this.avatarUrl = profile.avatar
          promptAction.showToast({ message: '头像更新成功' })
        } catch (error) {
          console.error('Failed to upload avatar:', error)
          promptAction.showToast({ message: '头像更新失败' })
        }
      }
    } catch (error) {
      console.error('Failed to pick avatar:', error)
      promptAction.showToast({ message: '请授予相册权限' })
    }
  }

  private async updateNickname(): Promise<void> {
    showInputDialog({
      title: '修改昵称',
      message: '请输入新昵称',
      placeholder: '请输入昵称',
      defaultValue: this.nickname,
      onConfirm: async (newNickname: string) => {
        if (!newNickname.trim()) {
          promptAction.showToast({ message: '昵称不能为空' })
          return
        }
        try {
          const payload: UpdateProfileRequest = { nickname: newNickname }
          const profile: UserProfile = await ApiService.updateUserProfile(payload)
          this.nickname = profile.nickname
          promptAction.showToast({ message: '昵称修改成功' })
        } catch (error) {
          console.error('Failed to update nickname:', error)
          promptAction.showToast({ message: '昵称修改失败' })
        }
      }
    })
  }

  private async updatePassword(): Promise<void> {
    showInputDialog({
      title: '修改密码',
      message: '请输入原密码',
      placeholder: '原密码',
      confirmText: '下一步',
      onConfirm: async (oldPassword: string) => {
        if (!oldPassword.trim()) {
          promptAction.showToast({ message: '请输入原密码' })
          return
        }
        showInputDialog({
          title: '修改密码',
          message: '请输入新密码',
          placeholder: '新密码',
          onConfirm: async (newPassword: string) => {
            if (!newPassword.trim()) {
              promptAction.showToast({ message: '请输入新密码' })
              return
            }
            if (newPassword.length < 6) {
              promptAction.showToast({ message: '密码长度不能少于6位' })
              return
            }
            try {
              const payload: UpdatePasswordRequest = {
                oldPassword: oldPassword,
                newPassword: newPassword
              }
              await ApiService.updatePassword(payload)
              promptAction.showToast({ message: '密码修改成功' })
            } catch (error) {
              console.error('Failed to update password:', error)
              promptAction.showToast({ message: '密码修改失败，请检查原密码是否正确' })
            }
          }
        })
      }
    })
  }

  private async updateGrade(): Promise<void> {
    showInputDialog({
      title: '修改年级',
      message: '请输入年级',
      placeholder: '例如：2021级',
      defaultValue: this.grade,
      onConfirm: async (newGrade: string) => {
        if (!newGrade.trim()) {
          promptAction.showToast({ message: '年级不能为空' })
          return
        }
        try {
          const payload: UpdateProfileRequest = { grade: newGrade }
          const profile: UserProfile = await ApiService.updateUserProfile(payload)
          this.grade = profile.grade
          promptAction.showToast({ message: '年级修改成功' })
        } catch (error) {
          console.error('Failed to update grade:', error)
          promptAction.showToast({ message: '年级修改失败' })
        }
      }
    })
  }

  private async updateCollege(): Promise<void> {
    showInputDialog({
      title: '修改学院',
      message: '请输入学院名称',
      placeholder: '例如：计算机学院',
      defaultValue: this.college,
      onConfirm: async (newCollege: string) => {
        if (!newCollege.trim()) {
          promptAction.showToast({ message: '学院不能为空' })
          return
        }
        try {
          const payload: UpdateProfileRequest = { college: newCollege }
          const profile: UserProfile = await ApiService.updateUserProfile(payload)
          this.college = profile.college
          promptAction.showToast({ message: '学院修改成功' })
        } catch (error) {
          console.error('Failed to update college:', error)
          promptAction.showToast({ message: '学院修改失败' })
        }
      }
    })
  }

  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
          Image($r('app.media.send_back'))
            .width(24)
            .height(24)
            .onClick(() => router.back())

        // 标题
        Text('账号设置')
          .textAlign(TextAlign.Center)
          .fontSize(25)
          .fontWeight(FontWeight.Medium)
          .margin({left:110})
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })

      // 2. 主体内容区
      Scroll() {
        Column({ space: 12 }) {
          // 卡片1：头像 + 昵称
          Column({ space: 0 }) {
            // 编辑头像
            this.SettingsItem({
              leadingIcon: $r('app.media.mine_avatar'),
              title: '编辑头像',
              showArrow: true,
              onClick: async () => {
                await this.selectAvatar()
              }
            })

            Divider()
              .width('100%')
              .height(1)
              .color('#F0F0F0')
              .margin({ left: 16, right: 16 })

            // 昵称
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_name'),
              title: '昵称',
              value: this.nickname,
              showArrow: true,
              onClick: async () => {
                await this.updateNickname()
              }
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .padding(10)
          // 卡片2：手机号
          Column() {
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_phone'),
              title: '手机号',
              value: this.phone,
              showArrow: true,
              onClick: () => {
                promptAction.showToast({ message: '进入手机号更换页' })
              }
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .padding(10)
          // 卡片3：年级 + 学院
          Column({ space: 0 }) {
            // 年级
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_grade'),
              title: '年级',
              value: this.grade,
              showArrow: true,
              onClick: async () => {
                await this.updateGrade()
              }
            })

            Divider()
              .width('100%')
              .height(1)
              .color('#F0F0F0')
              .margin({ left: 16, right: 16 })

            // 学院
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_sdept'),
              title: '学院',
              value: this.college,
              showArrow: true,
              onClick: async () => {
                await this.updateCollege()
              }
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .padding(10)
          // 卡片4：密码修改 + 账号安全
          Column({ space: 0 }) {
            // 密码修改
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_password'),
              title: '密码修改',
              showArrow: true,
              onClick: async () => {
                await this.updatePassword()
              }
            })

            Divider()
              .width('100%')
              .height(1)
              .color('#F0F0F0')
              .margin({ left: 16, right: 16 })

            // 账号安全
            this.SettingsItem({
              leadingIcon: $r('app.media.signup_security'),
              title: '账号安全',
              showArrow: true,
              onClick: () => {
                promptAction.showToast({ message: '进入账号安全页' })
              }
            })
          }
          .padding(10)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)

          Column() {
            // 卡片5：账号注销（危险操作）
            this.SettingsItem({
              leadingIcon: $r('app.media.accountchange_waring'),
              title: '账号注销',
              showArrow: true,
              isDanger: true,
              onClick: () => {
                promptAction.showDialog({
                  title: '账号注销',
                  message: '注销后所有数据将被永久删除，无法恢复，确定继续吗？',
                  buttons: [
                    { text: '取消', color: '#666666' },
                    { text: '确认注销', color: '#EF4444' }
                  ]
                }).then((result) => {
                  if (result.index === 1) {
                    promptAction.showToast({ message: '账号注销申请已提交' })
                  }
                })
              }
            })
          }
          .padding(10)
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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
  }

  // 通用设置项组件（严格遵循ArkUI组件化规范）
  @Builder
  SettingsItem(params: SettingsItemParams) {
    Row({ space: 12 }) {
      // 左侧图标
      Image(params.leadingIcon)
        .width(24)
        .height(24)
        .fillColor(params.isDanger ? '#EF4444' : '#666666')

      // 标题文本
      Text(params.title)
        .fontSize(16)
        .fontColor(params.isDanger ? '#EF4444' : '#1A1A1A')
        .layoutWeight(1)

      // 右侧值文本
      if (params.value) {
        Text(params.value)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ right: params.showArrow ? 4 : 0 })
      }

      // 右侧箭头
      if (params.showArrow) {
        Image($r('app.media.signup_right'))
          .width(25)
          .height(25)
          .fillColor('#ff6e6e6e')
      }
    }
    .backgroundColor('#fff')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(params.onClick)
  }
}