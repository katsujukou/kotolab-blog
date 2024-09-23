/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.purs", "./src/**/*.js"],
  theme: {
    extend: {},
    backgroundSize: {
      '60%': '60%',
      '180%': '180%'
    },
    fontFamily: {
      yomogi: [
        "Yomogi"
      ]
    }
  },
  plugins: [],
}

