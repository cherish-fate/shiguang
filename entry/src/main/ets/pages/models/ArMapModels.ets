// /**
//  * AR 寻宝地图：胶囊与情绪流数据模型及演示数据
//  */
//
// export type CampusId = 'jinming' | 'minglun'
//
// export class CampusBounds {
//   minLat: number
//   maxLat: number
//   minLng: number
//   maxLng: number
//
//   constructor(minLat: number, maxLat: number, minLng: number, maxLng: number) {
//     this.minLat = minLat
//     this.maxLat = maxLat
//     this.minLng = minLng
//     this.maxLng = maxLng
//   }
// }
//
// export interface MapPosition {
//   x: number
//   y: number
// }
//
// export class CampusBoundsManager {
//   private bounds: Record<string, CampusBounds>
//
//   constructor() {
//     this.bounds = {}
//     this.bounds['jinming'] = new CampusBounds(34.8100, 34.8200, 114.3000, 114.3200)
//   }
//
//   getBounds(campusId: string): CampusBounds {
//     return this.bounds[campusId] || this.bounds['jinming']
//   }
// }
//
// export const DEFAULT_CAMPUS_BOUNDS = new CampusBoundsManager()
//
// export type MoodKind = 'anxiety' | 'romance' | 'vitality' | 'geek'
//
// //匿名回复
// export interface AnonymousReplyItem {
//   id: string
//   text: string
//   timeAgo: string
// }
//
// /** 地图上的胶囊弹窗（含相对地图百分比坐标，便于 Stack 定位） */
// export interface MapCapsuleMarker {
//   id: string
//   campus: CampusId
//   moodKind: MoodKind
//   /** 与发布页心境文案对齐：焦虑蓝 / 浪漫粉 / 活力黄 / 极客紫 */
//   moodLabel: string
//   moodEmoji: Resource
//   locationName: string
//   content: string
//   timeAgo: string
//   latitude: number
//   longitude: number
//   /** 相对当前模拟用户位置的直线距离（米） */
//   distanceMeters: number
//   lightCount: number
//   isLitByMe: boolean
//   replies: AnonymousReplyItem[]
// }
//
// //情绪流
// export interface EmotionStreamCard {
//   placeName: string
//   capsuleCount: number
//   mainEmotionLabel: string
//   mainEmotionColor: string
//   tags: string[]
// }
//
// /** 光标环颜色：焦虑蓝、浪漫紫、活力黄、极客紫 */
// export function haloColorForMood(kind: MoodKind): string {
//   switch (kind) {
//     case 'anxiety':
//       return '#2563EB'
//     case 'romance':
//       return '#A855F7'
//     case 'vitality':
//       return '#EAB308'
//     case 'geek':
//     default:
//       return '#7C3AED'
//   }
// }
//
// export function moodKindFromPublishTag(tag: string): MoodKind {
//   if (tag.includes('焦虑')) {
//     return 'anxiety'
//   }
//   if (tag.includes('浪漫')) {
//     return 'romance'
//   }
//   if (tag.includes('活力')) {
//     return 'vitality'
//   }
//   return 'geek'
// }
//
// function demoReplies(): AnonymousReplyItem[] {
//   return [
//     { id: 'r1', text: '加油！你一定可以的', timeAgo: '1小时前' },
//     { id: 'r2', text: '我也在焦虑，一起努力吧', timeAgo: '30分钟前' }
//   ]
// }
//
// /** 金明校区演示胶囊 */
// export function jinmingMarkers(): MapCapsuleMarker[] {
//   return [
//     {
//       id: 'jm1',
//       campus: 'jinming',
//       moodKind: 'anxiety',
//       moodLabel: '焦虑',
//       moodEmoji: $r('app.media.mine_anxiety'),
//       locationName: '图书馆',
//       content: '考试周快到了，图书馆座位好难抢啊...希望这次能顺利通过',
//       timeAgo: '2小时前',
//       latitude: 34.8158,
//       longitude: 114.3084,
//       distanceMeters: 25,
//       lightCount: 23,
//       isLitByMe: false,
//       replies: demoReplies()
//     },
//     {
//       id: 'jm2',
//       campus: 'jinming',
//       moodKind: 'romance',
//       moodLabel: '浪漫',
//       moodEmoji: $r('app.media.mine_romance'),
//       locationName: '明德湖',
//       content: '夕阳下的湖面特别温柔，想和你一起走一圈。',
//       timeAgo: '5小时前',
//       latitude: 34.8158,
//       longitude: 114.3110,
//       distanceMeters: 50,
//       lightCount: 18,
//       isLitByMe: false,
//       replies: []
//     },
//     {
//       id: 'jm3',
//       campus: 'jinming',
//       moodKind: 'vitality',
//       moodLabel: '活力',
//       moodEmoji: $r('app.media.mine_happy'),
//       locationName: '操场',
//       content: '跑完五公里，整个人都通透了！',
//       timeAgo: '1天前',
//       latitude: 34.8132,
//       longitude: 114.3144,
//       distanceMeters: 80,
//       lightCount: 31,
//       isLitByMe: false,
//       replies: []
//     },
//     {
//       id: 'jm4',
//       campus: 'jinming',
//       moodKind: 'geek',
//       moodLabel: '极客',
//       moodEmoji: $r('app.media.map_computer'),
//       locationName: '计算机学院',
//       content: '终于把那个内存泄漏定位到了，庆祝一下。',
//       timeAgo: '3小时前',
//       latitude: 34.8136,
//       longitude: 114.3076,
//       distanceMeters: 15,
//       lightCount: 12,
//       isLitByMe: false,
//       replies: []
//     }
//   ]
// }
//
// /** 明伦校区演示胶囊（图三：较少点位） */
// export function minglunMarkers(): MapCapsuleMarker[] {
//   return [
//     {
//       id: 'ml1',
//       campus: 'minglun',
//       moodKind: 'romance',
//       moodLabel: '浪漫',
//       moodEmoji: $r('app.media.mine_romance'),
//       locationName: '梧桐大道',
//       content: '落叶的时候这条路像电影一样。',
//       timeAgo: '6小时前',
//       latitude: 34.8160,
//       longitude: 114.3060,
//       distanceMeters: 45,
//       lightCount: 9,
//       isLitByMe: false,
//       replies: []
//     },
//     {
//       id: 'ml2',
//       campus: 'minglun',
//       moodKind: 'vitality',
//       moodLabel: '活力',
//       moodEmoji: $r('app.media.mine_happy'),
//       locationName: '操场',
//       content: '新生杯决赛太燃了！',
//       timeAgo: '4小时前',
//       latitude: 34.8145,
//       longitude: 114.3130,
//       distanceMeters: 90,
//       lightCount: 22,
//       isLitByMe: false,
//       replies: []
//     }
//   ]
// }
//
// export function emotionStreamForCampus(c: CampusId): EmotionStreamCard[] {
//   if (c === 'jinming') {
//     return [
//       {
//         placeName: '图书馆',
//         capsuleCount: 45,
//         mainEmotionLabel: '焦虑',
//         mainEmotionColor: '#2563EB',
//         tags: ['焦虑', '考试', '复习', '压力']
//       },
//       {
//         placeName: '明德湖',
//         capsuleCount: 32,
//         mainEmotionLabel: '浪漫',
//         mainEmotionColor: '#fffb65b7',
//         tags: ['浪漫', '夕阳', '美好', '温柔']
//       },
//       {
//         placeName: '体育场',
//         capsuleCount: 28,
//         mainEmotionLabel: '活力',
//         mainEmotionColor: '#fffdc702',
//         tags: ['活力', '运动', '快乐', '健康']
//       },
//       {
//         placeName: '计算机学院',
//         capsuleCount: 56,
//         mainEmotionLabel: '极客',
//         mainEmotionColor: '#ffc27bff',
//         tags: ['极客', '代码', 'Bug', '熬夜']
//       },
//       {
//         placeName: '食堂',
//         capsuleCount: 19,
//         mainEmotionLabel: '快乐',
//         mainEmotionColor: '#ffff8a06',
//         tags: ['快乐', '美食', '聚会', '友谊']
//       }
//
//     ]
//   }
//   return [
//     {
//       placeName: '梧桐大道',
//       capsuleCount: 28,
//       mainEmotionLabel: '浪漫',
//       mainEmotionColor: '#A855F7',
//       tags: ['浪漫', '落叶', '漫步']
//     },
//     {
//       placeName: '操场',
//       capsuleCount: 19,
//       mainEmotionLabel: '活力',
//       mainEmotionColor: '#EAB308',
//       tags: ['活力', '比赛', '青春']
//     }
//   ]
// }



/**
 * AR 寻宝地图：胶囊与情绪流数据模型及演示数据
 */

export type CampusId = 'jinming' | 'minglun'

export class CampusBounds {
  minLat: number
  maxLat: number
  minLng: number
  maxLng: number

  constructor(minLat: number, maxLat: number, minLng: number, maxLng: number) {
    this.minLat = minLat
    this.maxLat = maxLat
    this.minLng = minLng
    this.maxLng = maxLng
  }
}

export interface MapPosition {
  x: number
  y: number
}

export interface CampusBoundsMap {
  jinming: CampusBounds;
  minglun?: CampusBounds;
}

export class CampusBoundsManager {
  // 直接初始化，避免在构造函数中使用对象字面量赋值
  private bounds: CampusBoundsMap = {
    jinming: new CampusBounds(34.8100, 34.8200, 114.3000, 114.3200)
  }

  constructor() {
    // 如果需要在构造函数中添加其他校区，使用条件判断
    // 空构造函数或保留用于未来扩展
  }

  getBounds(campusId: string): CampusBounds {
    if (campusId === 'jinming') {
      return this.bounds.jinming
    }
    // 如果有明伦校区数据，可以在这里添加
    // if (campusId === 'minglun' && this.bounds.minglun) {
    //   return this.bounds.minglun
    // }
    return this.bounds.jinming
  }
}

export const DEFAULT_CAMPUS_BOUNDS = new CampusBoundsManager()

export type MoodKind = 'anxiety' | 'romance' | 'vitality' | 'geek'

// 匿名回复
export interface AnonymousReplyItem {
  id: string
  text: string
  timeAgo: string
}

/** 地图上的胶囊弹窗（含相对地图百分比坐标，便于 Stack 定位） */
export interface MapCapsuleMarker {
  id: string
  campus: CampusId
  moodKind: MoodKind
  /** 与发布页心境文案对齐：焦虑蓝 / 浪漫粉 / 活力黄 / 极客紫 */
  moodLabel: string
  moodEmoji: Resource
  locationName: string
  content: string
  timeAgo: string
  latitude: number
  longitude: number
  /** 相对当前模拟用户位置的直线距离（米） */
  distanceMeters: number
  lightCount: number
  isLitByMe: boolean
  replies: AnonymousReplyItem[]
}

// 情绪流
export interface EmotionStreamCard {
  placeName: string
  capsuleCount: number
  mainEmotionLabel: string
  mainEmotionColor: string
  tags: string[]
}

/** 光标环颜色：焦虑蓝、浪漫紫、活力黄、极客紫 */
export function haloColorForMood(kind: MoodKind): string {
  switch (kind) {
    case 'anxiety':
      return '#2563EB'
    case 'romance':
      return '#A855F7'
    case 'vitality':
      return '#EAB308'
    case 'geek':
    default:
      return '#7C3AED'
  }
}

export function moodKindFromPublishTag(tag: string): MoodKind {
  if (tag.includes('焦虑')) {
    return 'anxiety'
  }
  if (tag.includes('浪漫')) {
    return 'romance'
  }
  if (tag.includes('活力')) {
    return 'vitality'
  }
  return 'geek'
}

function demoReplies(): AnonymousReplyItem[] {
  const replies: AnonymousReplyItem[] = [
    { id: 'r1', text: '加油！你一定可以的', timeAgo: '1小时前' },
    { id: 'r2', text: '我也在焦虑，一起努力吧', timeAgo: '30分钟前' }
  ]
  return replies
}

/** 金明校区演示胶囊 */
export function jinmingMarkers(): MapCapsuleMarker[] {
  const markers: MapCapsuleMarker[] = [
    {
      id: 'jm1',
      campus: 'jinming',
      moodKind: 'anxiety',
      moodLabel: '焦虑',
      moodEmoji: $r('app.media.mine_anxiety'),
      locationName: '图书馆',
      content: '考试周快到了，图书馆座位好难抢啊...希望这次能顺利通过',
      timeAgo: '2小时前',
      latitude: 34.8158,
      longitude: 114.3084,
      distanceMeters: 25,
      lightCount: 23,
      isLitByMe: false,
      replies: demoReplies()
    },
    {
      id: 'jm2',
      campus: 'jinming',
      moodKind: 'romance',
      moodLabel: '浪漫',
      moodEmoji: $r('app.media.mine_romance'),
      locationName: '明德湖',
      content: '夕阳下的湖面特别温柔，想和你一起走一圈。',
      timeAgo: '5小时前',
      latitude: 34.8158,
      longitude: 114.3110,
      distanceMeters: 50,
      lightCount: 18,
      isLitByMe: false,
      replies: []
    },
    {
      id: 'jm3',
      campus: 'jinming',
      moodKind: 'vitality',
      moodLabel: '活力',
      moodEmoji: $r('app.media.mine_happy'),
      locationName: '操场',
      content: '跑完五公里，整个人都通透了！',
      timeAgo: '1天前',
      latitude: 34.8132,
      longitude: 114.3144,
      distanceMeters: 80,
      lightCount: 31,
      isLitByMe: false,
      replies: []
    },
    {
      id: 'jm4',
      campus: 'jinming',
      moodKind: 'geek',
      moodLabel: '极客',
      moodEmoji: $r('app.media.map_computer'),
      locationName: '计算机学院',
      content: '终于把那个内存泄漏定位到了，庆祝一下。',
      timeAgo: '3小时前',
      latitude: 34.8136,
      longitude: 114.3076,
      distanceMeters: 15,
      lightCount: 12,
      isLitByMe: false,
      replies: []
    }
  ]
  return markers
}

/** 明伦校区演示胶囊（图三：较少点位） */
export function minglunMarkers(): MapCapsuleMarker[] {
  const markers: MapCapsuleMarker[] = [
    {
      id: 'ml1',
      campus: 'minglun',
      moodKind: 'romance',
      moodLabel: '浪漫',
      moodEmoji: $r('app.media.mine_romance'),
      locationName: '梧桐大道',
      content: '落叶的时候这条路像电影一样。',
      timeAgo: '6小时前',
      latitude: 34.8160,
      longitude: 114.3060,
      distanceMeters: 45,
      lightCount: 9,
      isLitByMe: false,
      replies: []
    },
    {
      id: 'ml2',
      campus: 'minglun',
      moodKind: 'vitality',
      moodLabel: '活力',
      moodEmoji: $r('app.media.mine_happy'),
      locationName: '操场',
      content: '新生杯决赛太燃了！',
      timeAgo: '4小时前',
      latitude: 34.8145,
      longitude: 114.3130,
      distanceMeters: 90,
      lightCount: 22,
      isLitByMe: false,
      replies: []
    }
  ]
  return markers
}

export function emotionStreamForCampus(c: CampusId): EmotionStreamCard[] {
  if (c === 'jinming') {
    const stream: EmotionStreamCard[] = [
      {
        placeName: '图书馆',
        capsuleCount: 45,
        mainEmotionLabel: '焦虑',
        mainEmotionColor: '#2563EB',
        tags: ['焦虑', '考试', '复习', '压力']
      },
      {
        placeName: '明德湖',
        capsuleCount: 32,
        mainEmotionLabel: '浪漫',
        mainEmotionColor: '#fffb65b7',
        tags: ['浪漫', '夕阳', '美好', '温柔']
      },
      {
        placeName: '体育场',
        capsuleCount: 28,
        mainEmotionLabel: '活力',
        mainEmotionColor: '#fffdc702',
        tags: ['活力', '运动', '快乐', '健康']
      },
      {
        placeName: '计算机学院',
        capsuleCount: 56,
        mainEmotionLabel: '极客',
        mainEmotionColor: '#ffc27bff',
        tags: ['极客', '代码', 'Bug', '熬夜']
      },
      {
        placeName: '食堂',
        capsuleCount: 19,
        mainEmotionLabel: '快乐',
        mainEmotionColor: '#ffff8a06',
        tags: ['快乐', '美食', '聚会', '友谊']
      }
    ]
    return stream
  }

  const stream: EmotionStreamCard[] = [
    {
      placeName: '梧桐大道',
      capsuleCount: 28,
      mainEmotionLabel: '浪漫',
      mainEmotionColor: '#A855F7',
      tags: ['浪漫', '落叶', '漫步']
    },
    {
      placeName: '操场',
      capsuleCount: 19,
      mainEmotionLabel: '活力',
      mainEmotionColor: '#EAB308',
      tags: ['活力', '比赛', '青春']
    }
  ]
  return stream
}