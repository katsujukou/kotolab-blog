/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.purs", "./src/**/*.js"],
  theme: {
    extend: {},
    backgroundSize: {
      '140%': '140%',
      '60%': '60%'
    },
    fontFamily: {
      yomogi: [
        "Yomogi"
      ]
    }
  },
  plugins: [],
}

