import "./index.css";
let main;
if (import.meta.env.VITE_ENV === "local") {
  import("../output/Kotolab.Blog.Web/index.js")
    .then(({ main }) => main())
}
else {
  import("../output-es/Kotolab.Blog.Web/index.js")
    .then(({ main }) => main())
}