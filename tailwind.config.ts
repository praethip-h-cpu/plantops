import type { Config } from 'tailwindcss';
const config: Config = { content: ['./app/**/*.{js,ts,jsx,tsx}'], theme: { extend: { colors: { ink: '#172329', teal: '#147d73', paper: '#f5f7f5' } } }, plugins: [] };
export default config;
