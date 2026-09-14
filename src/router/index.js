import { createRouter, createWebHistory } from 'vue-router'

import TopicPage from '../pages/TopicPage.vue'
import HomePage from '../pages/HomePage.vue'
import CommandPage from '../pages/CommandPage.vue'

const routes = [
    {
        path: '/',
        name: 'home',
        component: HomePage
    },
    {
        path: '/:topic',
        name: 'topic',
        component: TopicPage
    },
    {
        path: '/:topic/:slug',
        name: 'command',
        component: CommandPage
    },
]

export const router = createRouter({
    history: createWebHistory(),
    routes,
})