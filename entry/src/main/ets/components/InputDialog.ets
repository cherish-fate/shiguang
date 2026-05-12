
import { promptAction } from '@kit.ArkUI'

export interface InputDialogParams {
  title: string;
  message: string;
  placeholder: string;
  defaultValue?: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: (value: string) => void;
  onCancel?: () => void;
}

@CustomDialog
export struct InputDialog {
  controller: CustomDialogController
  title: string = ''
  message: string = ''
  placeholder: string = ''
  defaultValue: string = ''
  confirmText: string = '确定'
  cancelText: string = '取消'
  onConfirm: (value: string) => void = (value: string) => {}
  onCancel?: () => void = () => {}

  @State private inputValue: string = ''

  aboutToAppear(): void {
    this.inputValue = this.defaultValue
  }

  build() {
    Column() {
      Column({ space: 16 }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Text(this.message)
          .fontSize(14)
          .fontColor('#666666')

        TextInput({ placeholder: this.placeholder, text: this.inputValue })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .fontSize(16)
          .onChange((value: string) => {
            this.inputValue = value
          })

        Row({ space: 12 }) {
          Button(this.cancelText)
            .width(140)
            .height(44)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .fontSize(16)
            .borderRadius(8)
            .onClick(() => {
              if (this.onCancel) {
                this.onCancel()
              }
              this.controller.close()
            })

          Button(this.confirmText)
            .width(140)
            .height(44)
            .backgroundColor('#7C3AED')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .borderRadius(8)
            .onClick(() => {
              const value = this.inputValue.trim()
              if (value === '') {
                promptAction.showToast({ message: '请输入内容' })
                return
              }
              this.onConfirm(value)
              this.controller.close()
            })
        }
      }
      .width('100%')
      .padding({ top: 24, right: 24, bottom: 24, left: 24 })
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('85%')
  }
}

// 工具函数：显示输入对话框
export function showInputDialog(params: InputDialogParams): void {
  const dialogController = new CustomDialogController({
    builder: InputDialog({
      title: params.title,
      message: params.message,
      placeholder: params.placeholder,
      defaultValue: params.defaultValue || '',
      confirmText: params.confirmText || '确定',
      cancelText: params.cancelText || '取消',
      onConfirm: params.onConfirm,
      onCancel: params.onCancel
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    offset: { dx: 0, dy: 0 }
  })
  dialogController.open()
}