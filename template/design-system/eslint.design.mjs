// eslint.config.mjs에 펼쳐 넣어 사용: export default [...yourConfig, ...designRules];
// JS/TS 안의 하드코딩 색상·radius를 에러로 잡는다. tokens.ts는 제외.

const HEX = '/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/';
const RGB = '/^(rgb|rgba|hsl|hsla)\\(/';

export const designRules = [
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    ignores: ['**/design/tokens.ts'],
    rules: {
      'no-restricted-syntax': [
        'error',
        {
          selector: `Literal[value=${HEX}]`,
          message: 'hex 색 대신 design/tokens.ts의 colors를 쓰세요.',
        },
        {
          selector: `Literal[value=${RGB}]`,
          message: '색 함수 대신 design/tokens.ts의 colors를 쓰세요.',
        },
        {
          selector: "Property[key.name='borderRadius'] > Literal[raw=/^[0-9]+$/]",
          message: 'borderRadius 숫자 대신 design/tokens.ts의 radius를 쓰세요.',
        },
        {
          selector: "Property[key.name='fontWeight'] > Literal[value!=/^(400|600|700)$/]",
          message: 'fontWeight는 400/600/700만 씁니다. type 토큰을 쓰세요.',
        },
      ],
    },
  },
];

export default designRules;
