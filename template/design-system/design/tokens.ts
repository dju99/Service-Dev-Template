// 디자인 토큰 (JS / React Native용) — tokens.css와 값이 같아야 한다.
// 컴포넌트에서 hex·숫자 값을 직접 쓰지 말고 이 파일을 import한다.
// 사용: const c = colorScheme === 'dark' ? darkColors : lightColors;

export const lightColors = {
  bg: '#F1F3F5',
  surface: '#FFFFFF',
  surfaceSub: '#F7F9FA',
  textPrimary: '#1D1D1F',
  textSecondary: '#676D73',
  textTertiary: '#9AA1A8',
  divider: '#E4E8EC',
  ink: '#1D1D1F',
  onInk: '#FFFFFF',

  primary: '#087D81',
  primaryLight: '#E2F3F3',
  onPrimary: '#FFFFFF',
  accent: '#1EBFC2', // 아이콘·포커스 전용, 텍스트 금지
  heroGradient: ['#087D81', '#1EBFC2', '#8FE3DE'],

  pastel: {
    mint: { bg: '#E0F5F3', ink: '#12A3A0' },
    sky: { bg: '#E3F1FB', ink: '#2F8FD0' },
    lavender: { bg: '#ECEAFB', ink: '#6C5CE7' },
    peach: { bg: '#FDEDE4', ink: '#E8743F' },
    butter: { bg: '#FFF4D9', ink: '#D99A00' },
  },

  status: {
    success: { fg: '#1E9E6A', bg: '#E3F5EC' },
    warning: { fg: '#C98500', bg: '#FFF4D9' },
    danger: { fg: '#D9434A', bg: '#FCEBEC' },
  },
};

export const darkColors: typeof lightColors = {
  bg: '#131A22',
  surface: '#1B242D',
  surfaceSub: '#222D37',
  textPrimary: '#EAF1F5',
  textSecondary: '#A8B8C7',
  textTertiary: '#6F8191',
  divider: '#2A3540',
  ink: '#EAF1F5',
  onInk: '#131A22',

  primary: '#75DCD4',
  primaryLight: 'rgba(117, 220, 212, 0.14)',
  onPrimary: '#0B2E2F',
  accent: '#56D0CB',
  heroGradient: ['#0E5457', '#127F80', '#1E9E9C'],

  pastel: {
    mint: { bg: 'rgba(86, 208, 203, 0.14)', ink: '#56D0CB' },
    sky: { bg: 'rgba(96, 170, 230, 0.14)', ink: '#7DBAEA' },
    lavender: { bg: 'rgba(150, 135, 245, 0.14)', ink: '#A99CF5' },
    peach: { bg: 'rgba(240, 140, 90, 0.14)', ink: '#F2A47C' },
    butter: { bg: 'rgba(245, 190, 60, 0.14)', ink: '#F3C860' },
  },

  status: {
    success: { fg: '#5CD39C', bg: 'rgba(92, 211, 156, 0.14)' },
    warning: { fg: '#F3C25A', bg: 'rgba(243, 194, 90, 0.14)' },
    danger: { fg: '#F27D82', bg: 'rgba(242, 125, 130, 0.14)' },
  },
};

export const radius = { xs: 8, sm: 12, md: 16, lg: 24, full: 999 } as const;

export const space = { 1: 4, 2: 8, 3: 12, 4: 16, 5: 20, 6: 24, 7: 28, 8: 32, screenX: 20 } as const;

export const type = {
  display: { fontSize: 32, lineHeight: 38, fontWeight: '700' },
  titleLg: { fontSize: 24, lineHeight: 32, fontWeight: '700' },
  titleMd: { fontSize: 20, lineHeight: 28, fontWeight: '700' },
  titleSm: { fontSize: 16, lineHeight: 24, fontWeight: '600' },
  body: { fontSize: 15, lineHeight: 22, fontWeight: '400' },
  bodySm: { fontSize: 13, lineHeight: 18, fontWeight: '400' },
  caption: { fontSize: 11, lineHeight: 14, fontWeight: '500' },
} as const;

// 다크 모드에선 card·primary 그림자를 쓰지 않고 surface 명도 차이로 층을 나눈다.
export const shadow = {
  card: { shadowColor: '#131A22', shadowOpacity: 0.06, shadowRadius: 20, shadowOffset: { width: 0, height: 4 }, elevation: 2 },
  float: { shadowColor: '#131A22', shadowOpacity: 0.1, shadowRadius: 32, shadowOffset: { width: 0, height: 8 }, elevation: 6 },
  primary: { shadowColor: '#087D81', shadowOpacity: 0.28, shadowRadius: 20, shadowOffset: { width: 0, height: 8 }, elevation: 6 },
} as const;

export const size = { touchMin: 44, btn: 52, btnSm: 32, iconTile: 40, iconTileLg: 48 } as const;

export const motion = { duration: 200, durationProgress: 600, easing: [0.2, 0.8, 0.2, 1] } as const;
