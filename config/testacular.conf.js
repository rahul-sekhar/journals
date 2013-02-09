basePath = '../';

files = [
  JASMINE,
  JASMINE_ADAPTER,
  'app/assets/javascripts/lib/angular/angular.js',
  'app/assets/javascripts/lib/angular/angular-*.js',
  'test/lib/angular/angular-mocks.js',
  'app/assets/javascripts/**/*.js',
  'test/unit/**/*.js'
];

autoWatch = true;

browsers = ['Chrome'];

junitReporter = {
  outputFile: 'test_out/unit.xml',
  suite: 'unit'
};
