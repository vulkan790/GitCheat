import { ref } from 'vue'

export const THEMES = {
    git: {
        accent: '#F05032',
        accentBg: '#3A1206',
        pageBg: '#2D2D2D',
        surface: '#171717',
        border: '#383838',
        text: '#FFFFFF',
        textMuted: '#807F78',
        textDim: '#585858',
        textPlaceholder: '#5C5C5C'
    },

    sql: {
        accent: '#2B9FD8',
        accentBg: '#0A2E3D',
        pageBg: '#2B2F31',
        surface: '#141A1C',
        border: '#374246',
        text: '#FFFFFF',
        textMuted: '#7A8A8E',
        textDim: '#525F63',
        textPlaceholder: '#566468'
    },

    alembic: {
        accent: '#D7DEE5',
        accentBg: '#2B2F35',
        pageBg: '#2B2D33',
        surface: '#14161E',
        border: '#373B48',
        text: '#FFFFFF',
        textMuted: '#7A8094',
        textDim: '#525A6E',
        textPlaceholder: '#565E72'
    },

    docker: {
        accent: '#2496ED',
        accentBg: '#0B2D4A',
        pageBg: '#2A2E34',
        surface: '#141820',
        border: '#363C48',
        text: '#FFFFFF',
        textMuted: '#7A8290',
        textDim: '#525A6A',
        textPlaceholder: '#565E70'
    },

    pytest: {
        accent: '#FFD43B',
        accentBg: '#3D3306',
        pageBg: '#302D28',
        surface: '#1A1712',
        border: '#3F382C',
        text: '#FFFFFF',
        textMuted: '#8A8170',
        textDim: '#5F5847',
        textPlaceholder: '#635C4A'
    },

    vue: {
        accent: '#42B883',
        accentBg: '#0B3A25',
        pageBg: '#2A2F2C',
        surface: '#141A16',
        border: '#374240',
        text: '#FFFFFF',
        textMuted: '#7A8A82',
        textDim: '#525F58',
        textPlaceholder: '#56635C'
    },

    react: {
        accent: '#C21325',
        accentBg: '#2A0A0F',
        pageBg: '#2A2F31',
        surface: '#141A1D',
        border: '#374246',
        text: '#FFFFFF',
        textMuted: '#7A8A90',
        textDim: '#525F66',
        textPlaceholder: '#56636A'
    }
}

export const DEFAULT_THEME = THEMES.git
export const currentTopic = ref('git')

const VAR_MAP = {
    accent: '--accent',
    accentBg: '--accent-bg',
    pageBg: '--page-bg',
    surface: '--surface',
    border: '--border',
    text: '--text',
    textMuted: '--text-muted',
    textDim: '--text-dim',
    textPlaceholder: '--text-placeholder'
}

export function applyTheme(slug)
{
    const t = THEMES[slug] ?? DEFAULT_THEME
    currentTopic.value = THEMES[slug] ? slug : 'git'
    const root = document.documentElement
    for (const [key, cssVar] of Object.entries(VAR_MAP))
        root.style.setProperty(cssVar, t[key])
}