/**
 * @license Copyright 2016 - 2016 Intel Corporation All Rights Reserved.
 *
 * The source code, information and material ("Material") contained herein is owned by Intel Corporation or its
 * suppliers or licensors, and title to such Material remains with Intel Corporation or its suppliers or
 * licensors. The Material contains proprietary information of Intel or its suppliers and licensors. The
 * Material is protected by worldwide copyright laws and treaty provisions. No part of the Material may be used,
 * copied, reproduced, modified, published, uploaded, posted, transmitted, distributed or disclosed in any way
 * without Intel's prior express written permission. No license under any patent, copyright or other intellectual
 * property rights in the Material is granted to or conferred upon you, either expressly, by implication,
 * inducement, estoppel or otherwise. Any license under such intellectual property rights must be express and
 * approved by Intel in writing.
 *
 * Unless otherwise agreed by Intel in writing, you may not remove or alter this notice or any other notice
 * embedded in Materials by Intel or Intel's suppliers or licensors in any way.
 */
module.exports = function (grunt) {

  /**
   * This will load all grunt tasks in package.json
   * To add a grunt task, just do npm install --save grunt-<task>
   * The task will be available without manually loading it
   */
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    /** jshint config */
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        jshintignore: '.jshintignore',
        reporter: grunt.option('teamcity') ? require('jshint-teamcity') : null
      },
      all: [
        '**/*.js'
      ]
    }
  });

  // Default Task
  grunt.registerTask('default', 'Default Grunt Task', []);
};