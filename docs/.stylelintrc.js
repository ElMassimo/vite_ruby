module.exports = {
  extends: [
    'stylelint-config-standard',
  ],
  plugins: [
    'stylelint-order',
  ],
  rules: {
    'no-descending-specificity': null,
    'no-empty-source': null,
    'property-case': null,
    'order/properties-order': [
      ['composes'],
      { unspecified: 'bottomAlphabetical' },
    ],
    'order/order': [
      'at-rules',
      'custom-properties',
      'declarations',
    ],
    'order/properties-alphabetical-order': true,
    'selector-pseudo-element-no-unknown': [
      true,
      {
        ignorePseudoElements: ['v-deep'],
      },
    ],
  },
}
