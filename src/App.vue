<script setup>
import { computed } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import { currentTopic } from './lib/themes'

import gitLogo from '../src/images/logo.png'
import sqlLogo from '../src/images/logo_sql.png'
import alembicLogo from '../src/images/logo_alembic.png'
import dockerLogo from '../src/images/logo_docker.png'
import pytestLogo from '../src/images/logo_pytest.png'
import vueLogo from '../src/images/logo_vitest.png'
import reactLogo from '../src/images/jest_logo.png'

const LOGOS = {
    git: gitLogo,
    sql: sqlLogo,
    alembic: alembicLogo,
    docker: dockerLogo,
    pytest: pytestLogo,
    vue: vueLogo,
    react: reactLogo
}

const logo = computed(() => LOGOS[currentTopic.value] ?? gitLogo)
</script>

<template>
    <div class="main-content">
        <header class="navbar">
            <RouterLink to="/" class="logo">
                <img :src="logo" />
            </RouterLink>
        </header>
        <main class="container">
            <RouterView />
        </main>
    </div>
</template>