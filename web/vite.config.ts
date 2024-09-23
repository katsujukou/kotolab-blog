import { defineConfig } from "vite";
import path from "node:path";

export default defineConfig({
  server: {
    host: true
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname),
    }
  }
})