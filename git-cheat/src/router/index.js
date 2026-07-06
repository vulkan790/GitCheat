import { createRouter, createWebHistory } from 'vue-router'

import HomePage from '../pages/HomePage.vue'
import CommandPage from '../pages/CommandPage.vue'

const routes = [
    {
        path: '/',
        name: 'home',
        component: HomePage
    },
    {
        path: '/command/:slug',
        name: 'command',
        component: CommandPage
    },
]

export const router = createRouter({
    history: createWebHistory(),
    routes,
})