<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
    <div class="main-content">
        <header class="navbar">
            <RouterLink to="/" class="logo">
                <img src="../src/images/logo.png" />
                <p class="logo-name">git cheat</p>
            </RouterLink>
        </header>
        <main class="container">
            <RouterView />
        </main>
    </div>
</template>