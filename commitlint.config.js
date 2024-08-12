/* eslint-disable no-undef */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {        
    'type-enum': [     
      2,         
      'always',
        [            
          'fix',
          'to',
          'feat',   
          'docs', 
          'style', 
          'refactor',              
          'test',
          'chore',        
          'merge',
       ]
    ]
  }   
}