import { router, promptAction } from '@kit.ArkUI'
import { ApiService, CapsuleType, PublishCapsuleRequest } from '../services/MockApiService'
//import { picker } from '@kit.MediaLibraryKit'
//import { audio } from '@kit.MultimediaKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { audio } from '@kit.AudioKit'
import { picker } from '@kit.CoreFileKit'

interface MoodTheme {
  pageBg: string
  accent: string
  selectedTagBg: string
  tagBorder: string
  unselectedText: string
}

const MOOD_THEMES: Record<string, MoodTheme> = {
  '# 焦虑蓝': {
    pageBg: '#ffeaf2fe',
    accent: '#2563EB',
    selectedTagBg: '#ffeff5ff',
    tagBorder: '#ffeff5ff',
    unselectedText: '#334155'
  },
  '# 浪漫粉': {
    pageBg: '#fffcecf4',
    accent: '#DB2777',
    selectedTagBg: '#fffdf1fa',
    tagBorder: '#fffdf1f9',
    unselectedText: '#6B7280'
  },
  '# 活力黄': {
    pageBg: '#fffcf7e6',
    accent: '#D97706',
    selectedTagBg: '#fffefbe7',
    tagBorder: '#fffefbe8',
    unselectedText: '#6B7280'
  },
  '# 极客紫': {
    pageBg: '#fff6eefe',
    accent: '#7C3AED',
    selectedTagBg: '#fffaf5ff',
    tagBorder: '#fffaf5ff',
    unselectedText: '#6B7280'
  },
  '# 平静青': {
    pageBg: '#fff0faf7',
    accent: '#0D9488',
    selectedTagBg: '#fff5fbf9',
    tagBorder: '#fff5fbf9',
    unselectedText: '#6B7280'
  },
  '# 孤独灰': {
    pageBg: '#fff5f7fa',
    accent: '#475569',
    selectedTagBg: '#fff9fafb',
    tagBorder: '#fff9fafb',
    unselectedText: '#6B7280'
  }
}

@Entry
@Component
struct PublishCapsulePage {
  @State contentType: CapsuleType = 'text'
  @State content: string = ''
  @State selectedMood: string = '# 焦虑蓝'
  @State submitting: boolean = false
  @State location: string = ''
  @State isPrivate: boolean = false
  @State attachments: string[] = []
  @State isRecording: boolean = false
  @State aiPolishing: boolean = false
  @State aiSuggestion: string = ''
  private readonly moods: string[] = ['# 焦虑蓝', '# 浪漫粉', '# 活力黄', '# 极客紫','# 平静青', '# 孤独灰']
  private audioCapturer: audio.AudioCapturer | null = null

  private themeFor(mood: string): MoodTheme {
    const t = MOOD_THEMES[mood]
    return t ?? MOOD_THEMES['# 极客紫']
  }

  private currentTheme(): MoodTheme {
    return this.themeFor(this.selectedMood)
  }

  private async selectMedia(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9
      })
      if (result.photoUris && result.photoUris.length > 0) {
        const uploadedUrls: string[] = []
        for (const uri of result.photoUris) {
          try {
            const response = await ApiService.uploadFile(uri)
            uploadedUrls.push(response.url)
          } catch (error) {
            console.error('Failed to upload file:', error)
          }
        }
        this.attachments = [...this.attachments, ...uploadedUrls]
        promptAction.showToast({ message: `成功上传 ${uploadedUrls.length} 个文件` })
      }
    } catch (error) {
      const err = error as BusinessError
      if (err.code === 201) {
        promptAction.showToast({ message: '请授予相册权限' })
      }
      console.error('Failed to pick media:', error)
    }
  }

  private async startRecording(): Promise<void> {
    if (this.isRecording) {
      await this.stopRecording()
      return
    }
    try {
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      }
      const audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
      const audioCapturerOptions: audio.AudioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: audioCapturerInfo
      }
      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions)
      await this.audioCapturer.start()
      this.isRecording = true
      promptAction.showToast({ message: '开始录音' })
    } catch (error) {
      console.error('Failed to start recording:', error)
      promptAction.showToast({ message: '录音失败，请检查权限' })
    }
  }

  private async stopRecording(): Promise<void> {
    if (!this.audioCapturer || !this.isRecording) {
      return
    }
    try {
      const capturer: audio.AudioCapturer = this.audioCapturer
      await capturer.stop()
      this.isRecording = false
      const bufferSize: number = await capturer.getBufferSize()
      const buffer: Uint8Array = new Uint8Array(bufferSize)
      const readBuffer: ArrayBuffer = await capturer.read(bufferSize, true)
      if (readBuffer && readBuffer.byteLength > 0) {
        const base64Audio: string = this.arrayBufferToBase64(readBuffer)
        const response = await ApiService.aiAsr({ audioBase64: base64Audio })
        this.content += response.text
        promptAction.showToast({ message: '语音转文字成功' })
      }
    } catch (error) {
      console.error('Failed to stop recording:', error)
      this.isRecording = false
    } finally {
      if (this.audioCapturer) {
        this.audioCapturer.release()
        this.audioCapturer = null
      }
    }
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes: Uint8Array = new Uint8Array(buffer)
    const base64Chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    let result: string = ''
    let padding: number = 0

    for (let i: number = 0; i < bytes.length; i += 3) {
      const byte1: number = bytes[i] || 0
      const byte2: number = bytes[i + 1] || 0
      const byte3: number = bytes[i + 2] || 0

      const triple: number = (byte1 << 16) | (byte2 << 8) | byte3

      result += base64Chars[(triple >> 18) & 63]
      result += base64Chars[(triple >> 12) & 63]
      result += base64Chars[(triple >> 6) & 63]
      result += base64Chars[triple & 63]

      if (i + 1 >= bytes.length) padding++
      if (i + 2 >= bytes.length) padding++
    }

    return result.substring(0, result.length - padding) + '=='.substring(0, padding)
  }

  private async aiPolishContent(): Promise<void> {
    if (!this.content.trim()) {
      promptAction.showToast({ message: '请先输入内容' })
      return
    }
    this.aiPolishing = true
    try {
      const response = await ApiService.aiPolish({ content: this.content })
      this.aiSuggestion = response.content
      promptAction.showToast({ message: 'AI润色完成' })
    } catch (error) {
      console.error('Failed to polish content:', error)
    } finally {
      this.aiPolishing = false
    }
  }

  private applyAiSuggestion(): void {
    if (this.aiSuggestion) {
      this.content = this.aiSuggestion
      this.aiSuggestion = ''
    }
  }

  private removeAttachment(index: number): void {
    this.attachments.splice(index, 1)
  }

  private async publishCapsule(): Promise<void> {
    if (!this.content.trim()) {
      promptAction.showToast({ message: '请输入内容' })
      return
    }
    this.submitting = true
    const request: PublishCapsuleRequest = {
      type: this.contentType,
      moodTag: this.selectedMood,
      content: this.content.trim(),
      attachments: this.attachments,
      location: this.location.trim(),
      isPrivate: this.isPrivate
    }
    try {
      await ApiService.publishCapsule(request)
      promptAction.showToast({ message: '发布成功' })
      router.pushUrl({ url: 'pages/ArTreasureMapPage' })
    } catch (_) {
      // Error toast is handled in ApiService.
    } finally {
      this.submitting = false
    }
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Image($r('app.media.send_back'))
          .width(40)
          .height(40)
          .padding(8)
          .onClick(() => router.back())
        Blank()
        Text('发布拾光胶囊')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme().accent)
        Blank()
      }
      .width('100%')
      .padding({ top: 14, left: 12, right: 12 })
      List() {
        ListItem() {
          Column() {
            Column({ space: 12 }) {
              Text('当前心境')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffa4aab8')
                .width('100%')

              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.moods, (mood: string) => {
                  Text(mood)
                    .fontSize(16)
                    .fontColor(this.selectedMood === mood ? this.themeFor(mood).accent : this.themeFor(mood).unselectedText)
                    .padding({
                      left: 14,
                      right: 14,
                      top: 8,
                      bottom: 8
                    })
                    .margin({ right: 10, bottom: 10 })
                    .backgroundColor(this.selectedMood === mood ? this.themeFor(mood).selectedTagBg : '#FFFFFF')
                    .borderWidth(2)
                    .borderColor(this.themeFor(mood).tagBorder)
                    .borderRadius(18)
                    .onClick(() => {
                      animateTo({ duration: 320, curve: Curve.EaseInOut }, () => {
                        this.selectedMood = mood
                      })
                    })
                })
              }
            }
            .padding({ left: 16, right: 16 })
            Column({ space: 12 }) {
              Text('发布地')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffa4aab8')
                .width('100%')

              TextInput({ placeholder: '请输入发布地点', text: this.location })
                .height(50)
                .backgroundColor(Color.Transparent)
                .border({width:0.6,color: this.currentTheme().accent})
                .borderRadius(16)
                .padding({ left: 16, right: 16 })
                .onChange(value => this.location = value)
            }
            .padding({ left: 16, right: 16, top: 10 })

            Column({ space: 14 }) {
              Row({ space: 22 }) {
                Row() {
                  Image($r('app.media.send_text'))
                    .width(18)
                    .fillColor(this.contentType === 'text' ? '#3B5CCC' : '#9CA3AF')
                  Text('文字')
                    .fontSize(18)
                    .fontWeight(this.contentType === 'text' ? FontWeight.Bold : FontWeight.Medium)
                    .fontColor(this.contentType === 'text' ? '#3B5CCC' : '#9CA3AF')

                }
                .onClick(() => this.contentType = 'text')
                Row() {
                Image($r('app.media.send_audio'))
                  .width(18)
                  .fillColor(this.isRecording ? '#EF4444' : '#9CA3AF')
                Text(this.isRecording ? '录音中...' : '语音')
                  .fontSize(18)
                  .fontWeight(this.isRecording ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.isRecording ? '#EF4444' : '#9CA3AF')

                }
                .onClick(() => this.startRecording())
                Row() {
                  Text('设为私密胶囊')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffa4aab8')
                  Toggle({ type: ToggleType.Switch, isOn: this.isPrivate })
                    .selectedColor(this.currentTheme().accent)
                    .onChange(val => this.isPrivate = val)
                }

              }
              .width('100%')
              .alignItems(VerticalAlign.Top)

              TextArea({ placeholder: '写下此刻的拾光印记...', text: this.content })
                .height(180)
                .backgroundColor('#00FFFFFF')
                .fontSize(20)
                 .onChange((value: string) => this.content = value)
              Row() {
                Image($r('app.media.send_picture'))
                  .width(40)
                  .height(40)
                  .padding(8)
                  .borderRadius(8)
                  .backgroundColor('#fff0f3fb')
                  .onClick(() => this.selectMedia())
                Text('添加图片、文件或地点信息')
                  .fontSize(14)
                  .fontColor('#9CA3AF')
                  .margin({ left: 8 })
              }
              .width('100%')
              .onClick(() => this.selectMedia())

              if (this.attachments.length > 0) {
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(this.attachments, (url: string, index: number) => {
                    Stack() {
                      Image(url)
                        .width(80)
                        .height(80)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                      Image($r('app.media.pop_up_close'))
                        .width(20)
                        .height(20)
                        .margin(4)
                        .onClick(() => this.removeAttachment(index))
                    }
                    .width(80)
                    .height(80)
                    .margin({ right: 8, bottom: 8 })
                  }, (url: string) => url)
                }
              }
            }
            .width(320)
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(28)
            .margin({ top: 15, bottom: 25 })

            Column({ space: 10 }) {
              Row({ space: 10 }) {
                Image($r('app.media.send_sparkles'))
                  .width(20)
                  .fillColor(this.currentTheme().accent)
                Text('AI 意图增强')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.currentTheme().accent)
                Button(this.aiPolishing ? '润色中...' : 'AI润色')
                  .fontSize(16)
                  .width(80)
                  .height(40)
                  .fontColor(Color.White)
                  .backgroundColor(this.currentTheme().accent)
                  .borderRadius(20)
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .enabled(!this.aiPolishing)
                  .onClick(() => this.aiPolishContent())
              }

              if (this.aiSuggestion) {
                Column({ space: 8 }) {
                  Text('AI润色建议：')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#5B59C9')
                  Text(this.aiSuggestion)
                    .fontSize(15)
                    .fontStyle(FontStyle.Italic)
                    .fontColor('#7C83A3')
                    .textAlign(TextAlign.Start)
                  Button('应用建议')
                    .fontSize(14)
                    .fontColor(Color.White)
                    .backgroundColor('#5B59C9')
                    .borderRadius(12)
                    .width('100%')
                    .height(40)
                    .onClick(() => this.applyAiSuggestion())
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#fff6faff')
                .borderRadius(12)
              } else {
                Text('点击"AI润色"按钮，让AI帮您优化文字内容')
                  .fontSize(15)
                  .fontStyle(FontStyle.Italic)
                  .fontColor('#7C83A3')
              }
            }
            .width(320)
            .padding(15)
            .margin({ bottom: 25 })
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            Button(){
              Row(){
                Image($r('app.media.send_flight'))
                  .width(25)
                  .margin({right:5})
                Text(this.submitting ? '发布中...' : '埋下拾光胶囊')
                  .fontSize(25)
                  .fontColor('#fff')
                  .fontWeight(800)
              }
            }
              .width('90%')
              .height(56)
              .fontSize(22)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .enabled(!this.submitting)
              .backgroundColor(this.currentTheme().accent)
              .borderRadius(28)
              .onClick(() => this.publishCapsule())
          }
        } // item
      }
      .width('100%')
      .layoutWeight(1)
      .lanes(1, 0)
      .scrollBar(BarState.On)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .backgroundColor(this.currentTheme().pageBg)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
