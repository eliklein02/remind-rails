const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/javascripts/**/*.js",
    "./app/assets/stylesheets/**/*.css",
  ],
  theme: {
    extend: {},
  },
};
