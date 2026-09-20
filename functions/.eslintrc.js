module.exports = {
  root: true,
  env: { es6: true, node: true },
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  parser: "@typescript-eslint/parser",
  parserOptions: { project: ["tsconfig.json"], sourceType: "module" },
  plugins: ["@typescript-eslint"],
  ignorePatterns: ["lib/**/*", "node_modules/**/*"],
  rules: {
    "@typescript-eslint/no-unused-vars": "error",
  },
};
