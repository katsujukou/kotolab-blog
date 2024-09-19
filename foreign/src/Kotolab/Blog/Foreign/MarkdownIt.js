import markdownit from "markdown-it";

export const md = () => markdownit();
export const renderImpl = (m, src) => m.render(src)